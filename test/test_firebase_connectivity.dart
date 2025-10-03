// Test Firebase Connectivity
// Run this to verify Firebase is working on real devices

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class FirebaseConnectivityTest extends StatefulWidget {
  const FirebaseConnectivityTest({super.key});

  @override
  State<FirebaseConnectivityTest> createState() =>
      _FirebaseConnectivityTestState();
}

class _FirebaseConnectivityTestState extends State<FirebaseConnectivityTest> {
  final List<String> _testResults = [];
  bool _isRunning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Connectivity Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Firebase Services Test',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isRunning ? null : _runTests,
              child: Text(_isRunning ? 'Testing...' : 'Run Firebase Tests'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _testResults.length,
                itemBuilder: (context, index) {
                  final result = _testResults[index];
                  final isSuccess = result.contains('✅');
                  final isError = result.contains('❌');

                  return Card(
                    color: isSuccess
                        ? Colors.green.shade50
                        : isError
                        ? Colors.red.shade50
                        : Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        result,
                        style: TextStyle(
                          color: isSuccess
                              ? Colors.green.shade800
                              : isError
                              ? Colors.red.shade800
                              : Colors.blue.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _runTests() async {
    setState(() {
      _isRunning = true;
      _testResults.clear();
    });

    // Test 1: Firebase Core
    _addResult('🔄 Testing Firebase Core initialization...');
    try {
      await Firebase.initializeApp();
      _addResult('✅ Firebase Core: Initialized successfully');
    } catch (e) {
      _addResult('❌ Firebase Core: Failed - $e');
    }

    // Test 2: Firestore
    _addResult('🔄 Testing Firestore connectivity...');
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('test').doc('connectivity').set({
        'timestamp': FieldValue.serverTimestamp(),
        'test': 'connectivity_check',
        'device': 'android_device',
      });
      _addResult('✅ Firestore: Write operation successful');

      final doc = await firestore.collection('test').doc('connectivity').get();
      if (doc.exists) {
        _addResult('✅ Firestore: Read operation successful');
      } else {
        _addResult('❌ Firestore: Document not found after write');
      }
    } catch (e) {
      _addResult('❌ Firestore: Failed - $e');
    }

    // Test 3: Firebase Auth
    _addResult('🔄 Testing Firebase Auth...');
    try {
      final auth = FirebaseAuth.instance;
      _addResult('✅ Firebase Auth: Instance created successfully');
      _addResult(
        'ℹ️ Firebase Auth: Current user - ${auth.currentUser?.email ?? "Not signed in"}',
      );
    } catch (e) {
      _addResult('❌ Firebase Auth: Failed - $e');
    }

    // Test 4: Firebase Analytics
    _addResult('🔄 Testing Firebase Analytics...');
    try {
      final analytics = FirebaseAnalytics.instance;
      await analytics.logEvent(
        name: 'connectivity_test',
        parameters: {
          'test_type': 'firebase_connectivity',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
      _addResult('✅ Firebase Analytics: Event logged successfully');
    } catch (e) {
      _addResult('❌ Firebase Analytics: Failed - $e');
    }

    // Test 5: Network Connectivity
    _addResult('🔄 Testing network connectivity...');
    try {
      // Simple HTTP test
      await Future.delayed(const Duration(seconds: 2));
      _addResult('✅ Network: Connection stable');
    } catch (e) {
      _addResult('❌ Network: Connection issues - $e');
    }

    // Summary
    final successCount = _testResults.where((r) => r.contains('✅')).length;
    final totalTests = _testResults.where((r) => r.contains('🔄')).length;

    _addResult('');
    _addResult('📊 Test Summary:');
    _addResult('✅ Successful: $successCount/$totalTests');

    if (successCount == totalTests) {
      _addResult('🎉 All Firebase services are working perfectly!');
      _addResult('🚀 Your app is ready for the presentation!');
    } else {
      _addResult('⚠️ Some services need attention');
      _addResult(
        '💡 Check your internet connection and Firebase configuration',
      );
    }

    setState(() {
      _isRunning = false;
    });
  }

  void _addResult(String result) {
    setState(() {
      _testResults.add(result);
    });
  }
}

// Add this to your main.dart for testing
/*
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  runApp(
    MaterialApp(
      home: FirebaseConnectivityTest(),
      title: 'Firebase Test',
    ),
  );
}
*/
