# Test Configuration for Mayegue App
#
# This file organizes the test structure and provides guidance for running tests

## Test Organization
- unit/ - Unit tests for individual functions, classes, and utilities
- integration/ - Integration tests for feature interactions
- widget/ - Widget tests for UI components

## Test Categories
### Unit Tests (47 tests)
- **Core Services**: notification, payout, sync, content moderation
- **Utilities**: security, validators, error handling
- **Domain Layer**: usecases, entities, repositories interfaces
- **Data Layer**: models, mappers

### Integration Tests
- **Authentication Flow**: login, registration, social sign-in
- **Feature Interactions**: cross-module functionality
- **API Integrations**: mocked external service calls

### Widget Tests
- **Main App**: MaterialApp configuration, themes, localization
- **Authentication UI**: login form, validation, loading states
- **Screen Components**: individual UI widgets and interactions

## Running Tests
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/security_utils_test.dart

# Run tests by directory
flutter test test/unit/
flutter test test/integration/
flutter test test/widget/

# Run with coverage
flutter test --coverage
```

## Test Coverage Goals
- Core utilities: 90%+
- Services: 80%+
- Usecases: 85%+
- ViewModels: 75%+
- Widgets: 70%+
- Integration: 60%+

## Current Test Status
✅ **Unit Tests**: 47 tests covering core functionality
✅ **Integration Tests**: Authentication flow tests
✅ **Widget Tests**: Main app and login UI tests
✅ **Test Organization**: Structured by type and feature
✅ **Documentation**: Test guidelines and coverage goals

## Mock Strategy
- Use Mockito for external dependencies (Firebase, HTTP, etc.)
- Create fake implementations for complex dependencies
- Use dependency injection to enable testability

## Test Results
- Core business logic validated
- UI components tested for basic functionality
- Authentication flows covered
- Error handling verified
- Input validation confirmed