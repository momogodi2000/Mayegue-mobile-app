import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import '../viewmodels/ai_viewmodels.dart';

/// AI Chat Widget - Main chat interface
class AiChatWidget extends StatefulWidget {
  const AiChatWidget({super.key});

  @override
  State<AiChatWidget> createState() => _AiChatWidgetState();
}

class _AiChatWidgetState extends State<AiChatWidget> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AiChatViewModel>(
      builder: (context, viewModel, child) {
        final currentConversation = viewModel.currentConversation;

        return Column(
          children: [
            // Chat messages area
            Expanded(
              child: currentConversation == null
                  ? const Center(
                      child: Text('Start a conversation with Mayegue AI'),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: currentConversation.messages.length,
                      itemBuilder: (context, index) {
                        final message = currentConversation.messages[index];
                        return _ChatMessageBubble(message: message);
                      },
                    ),
            ),

            // Message input area
            if (viewModel.isLoading)
              const LinearProgressIndicator()
            else
              _MessageInputArea(
                controller: _messageController,
                onSend: (message, isFromVoice) =>
                    _sendMessage(viewModel, message, isFromVoice),
                enabled: currentConversation != null,
              ),
          ],
        );
      },
    );
  }

  void _sendMessage(
      AiChatViewModel viewModel, String message, bool isFromVoice) {
    if (message.isEmpty || viewModel.currentConversation == null) return;

    // If from voice, add correction prompt
    final processedMessage = isFromVoice
        ? "Please correct any speech-to-text errors and respond in the appropriate Cameroon language: $message"
        : message;

    // TODO: Get user ID from auth
    const userId = 'test-user-id';

    viewModel.sendMessage(
      viewModel.currentConversation!.id,
      processedMessage,
      userId,
    );

    _messageController.clear();

    // Scroll to bottom after sending
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }
}

/// Chat message bubble
class _ChatMessageBubble extends StatefulWidget {
  final dynamic message;

  const _ChatMessageBubble({required this.message});

  @override
  State<_ChatMessageBubble> createState() => _ChatMessageBubbleState();
}

class _ChatMessageBubbleState extends State<_ChatMessageBubble> {
  late FlutterTts _flutterTts;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _initTts();
  }

  void _initTts() async {
    await _flutterTts.setLanguage("en-US"); // TODO: Dynamic language
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  void _speak() async {
    if (_isPlaying) {
      await _flutterTts.stop();
      setState(() => _isPlaying = false);
    } else {
      setState(() => _isPlaying = true);
      await _flutterTts.speak(widget.message.content);
      _flutterTts.setCompletionHandler(() {
        setState(() => _isPlaying = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.sender == 'user';
    final theme = Theme.of(context);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? theme.primaryColor : theme.cardColor,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Text(
                widget.message.content,
                style: TextStyle(
                  color:
                      isUser ? Colors.white : theme.textTheme.bodyLarge?.color,
                ),
              ),
            ),
            if (!isUser) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: _speak,
                icon: Icon(
                  _isPlaying ? Icons.stop : Icons.volume_up,
                  color: theme.primaryColor,
                  size: 20,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Message input area
class _MessageInputArea extends StatefulWidget {
  final TextEditingController controller;
  final Function(String message, bool isFromVoice) onSend;
  final bool enabled;

  const _MessageInputArea({
    required this.controller,
    required this.onSend,
    required this.enabled,
  });

  @override
  State<_MessageInputArea> createState() => _MessageInputAreaState();
}

class _MessageInputAreaState extends State<_MessageInputArea> {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  bool _isListening = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _initTts();
  }

  void _initTts() async {
    await _flutterTts
        .setLanguage("en-US"); // Default, will be changed based on language
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => debugPrint('onStatus: $val'),
        onError: (val) => debugPrint('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _lastWords = val.recognizedWords;
            widget.controller.text = _lastWords;
          }),
          localeId: 'en_US', // TODO: Make dynamic based on selected language
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      if (_lastWords.isNotEmpty) {
        widget.onSend(_lastWords, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              enabled: widget.enabled,
              decoration: const InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: widget.enabled ? _listen : null,
            icon: Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              color: _isListening ? Colors.red : Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: widget.enabled
                ? () => widget.onSend(widget.controller.text, false)
                : null,
            icon: const Icon(Icons.send),
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
}

/// Translation Widget
class TranslationWidget extends StatefulWidget {
  const TranslationWidget({super.key});

  @override
  State<TranslationWidget> createState() => _TranslationWidgetState();
}

class _TranslationWidgetState extends State<TranslationWidget> {
  final TextEditingController _sourceController = TextEditingController();
  String _sourceLanguage = 'fr'; // French
  String _targetLanguage = 'ewondo';

  @override
  void dispose() {
    _sourceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TranslationViewModel>(
      builder: (context, viewModel, child) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Language selectors
              Row(
                children: [
                  Expanded(
                    child: _LanguageSelector(
                      label: 'From',
                      value: _sourceLanguage,
                      onChanged: (value) =>
                          setState(() => _sourceLanguage = value!),
                    ),
                  ),
                  IconButton(
                    onPressed: _swapLanguages,
                    icon: const Icon(Icons.swap_horiz),
                  ),
                  Expanded(
                    child: _LanguageSelector(
                      label: 'To',
                      value: _targetLanguage,
                      onChanged: (value) =>
                          setState(() => _targetLanguage = value!),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              const SizedBox(height: 16),

              // Source text input
              TextField(
                controller: _sourceController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Enter text to translate',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              // Translate button
              ElevatedButton(
                onPressed: viewModel.isLoading ? null : _translate,
                child: viewModel.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Translate'),
              ),

              const SizedBox(height: 16),

              // Translation result
              if (viewModel.currentTranslation != null)
                _TranslationResult(translation: viewModel.currentTranslation!),

              // Error message
              if (viewModel.error != null)
                Text(
                  viewModel.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
            ],
          ),
        );
      },
    );
  }

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLanguage;
      _sourceLanguage = _targetLanguage;
      _targetLanguage = temp;
    });
  }

  void _translate() {
    if (_sourceController.text.trim().isEmpty) return;

    // TODO: Get user ID from auth
    const userId = 'test-user-id';

    context.read<TranslationViewModel>().translate(
          userId: userId,
          sourceText: _sourceController.text.trim(),
          sourceLanguage: _sourceLanguage,
          targetLanguage: _targetLanguage,
        );
  }
}

/// Language selector dropdown
class _LanguageSelector extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String?> onChanged;

  const _LanguageSelector({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: 'fr', child: Text('French')),
            DropdownMenuItem(value: 'en', child: Text('English')),
            DropdownMenuItem(value: 'ewondo', child: Text('Ewondo')),
            DropdownMenuItem(value: 'bafang', child: Text('Bafang')),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}

/// Translation result display
class _TranslationResult extends StatelessWidget {
  final dynamic translation;

  const _TranslationResult({required this.translation});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Translation',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(translation.targetText),
            const SizedBox(height: 8),
            Text(
              'Confidence: ${(translation.confidence * 100).round()}%',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
