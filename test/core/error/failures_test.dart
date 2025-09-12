import 'package:flutter_test/flutter_test.dart';
import 'package:agendeme/core/core.dart';

void main() {
  group('Failure', () {
    test('should have correct props for equality comparison', () {
      // Arrange
      const failure1 = ServerFailure(
        message: 'Server error',
        code: '500',
        details: 'Internal server error',
      );
      const failure2 = ServerFailure(
        message: 'Server error',
        code: '500',
        details: 'Internal server error',
      );
      const failure3 = ServerFailure(
        message: 'Different error',
        code: '500',
        details: 'Internal server error',
      );

      // Assert
      expect(failure1, equals(failure2));
      expect(failure1, isNot(equals(failure3)));
    });

    test('should generate correct toString', () {
      // Arrange
      const failure = NetworkFailure(
        message: 'No internet connection',
        code: 'NO_INTERNET',
        details: {'timestamp': '2023-01-01'},
      );

      // Act
      final result = failure.toString();

      // Assert
      expect(result, contains('Failure'));
      expect(result, contains('No internet connection'));
      expect(result, contains('NO_INTERNET'));
    });
  });

  group('ServerFailure', () {
    test('should be a subclass of Failure', () {
      // Arrange
      const serverFailure = ServerFailure(message: 'Server error');

      // Assert
      expect(serverFailure, isA<Failure>());
    });

    test('should initialize with correct values', () {
      // Arrange
      const message = 'Internal server error';
      const code = '500';
      const details = 'Database connection failed';

      // Act
      const serverFailure = ServerFailure(
        message: message,
        code: code,
        details: details,
      );

      // Assert
      expect(serverFailure.message, equals(message));
      expect(serverFailure.code, equals(code));
      expect(serverFailure.details, equals(details));
    });
  });

  group('NetworkFailure', () {
    test('should be a subclass of Failure', () {
      // Arrange
      const networkFailure = NetworkFailure(message: 'Network error');

      // Assert
      expect(networkFailure, isA<Failure>());
    });

    test('should initialize with only message', () {
      // Arrange
      const message = 'No internet connection';

      // Act
      const networkFailure = NetworkFailure(message: message);

      // Assert
      expect(networkFailure.message, equals(message));
      expect(networkFailure.code, isNull);
      expect(networkFailure.details, isNull);
    });
  });

  group('CacheFailure', () {
    test('should be a subclass of Failure', () {
      // Arrange
      const cacheFailure = CacheFailure(message: 'Cache error');

      // Assert
      expect(cacheFailure, isA<Failure>());
    });
  });

  group('AuthFailure', () {
    test('should be a subclass of Failure', () {
      // Arrange
      const authFailure = AuthFailure(message: 'Auth error');

      // Assert
      expect(authFailure, isA<Failure>());
    });
  });

  group('ValidationFailure', () {
    test('should be a subclass of Failure', () {
      // Arrange
      const validationFailure = ValidationFailure(message: 'Validation error');

      // Assert
      expect(validationFailure, isA<Failure>());
    });
  });

  group('PermissionFailure', () {
    test('should be a subclass of Failure', () {
      // Arrange
      const permissionFailure = PermissionFailure(message: 'Permission error');

      // Assert
      expect(permissionFailure, isA<Failure>());
    });
  });

  group('UnknownFailure', () {
    test('should be a subclass of Failure', () {
      // Arrange
      const unknownFailure = UnknownFailure(message: 'Unknown error');

      // Assert
      expect(unknownFailure, isA<Failure>());
    });
  });

  group('StorageFailure', () {
    test('should be a subclass of Failure', () {
      // Arrange
      const storageFailure = StorageFailure(message: 'Storage error');

      // Assert
      expect(storageFailure, isA<Failure>());
    });
  });

  group('FirebaseFailure', () {
    test('should be a subclass of Failure', () {
      // Arrange
      const firebaseFailure = FirebaseFailure(message: 'Firebase error');

      // Assert
      expect(firebaseFailure, isA<Failure>());
    });
  });
}
