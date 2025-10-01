import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mayegue/core/services/terms_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('TermsService', () {
    test('hasAcceptedTerms returns false when terms not accepted', () async {
      final hasAccepted = await TermsService.hasAcceptedTerms();
      expect(hasAccepted, false);
    });

    test('acceptTerms persists acceptance', () async {
      await TermsService.acceptTerms();
      final hasAccepted = await TermsService.hasAcceptedTerms();
      expect(hasAccepted, true);
    });

    test('hasAcceptedTerms returns true after accepting', () async {
      await TermsService.acceptTerms();
      final hasAccepted = await TermsService.hasAcceptedTerms();
      expect(hasAccepted, true);
    });

    test('clearTermsAcceptance resets acceptance state', () async {
      await TermsService.acceptTerms();
      await TermsService.resetTermsAcceptance();
      final hasAccepted = await TermsService.hasAcceptedTerms();
      expect(hasAccepted, false);
    });
  });
}
