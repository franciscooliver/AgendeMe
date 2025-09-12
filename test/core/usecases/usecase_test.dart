import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:agendeme/core/core.dart';

// Mock implementations for testing
class MockUseCase extends UseCase<String, String> {
  final bool shouldSucceed;
  final String? result;
  final Failure? failure;

  MockUseCase({
    this.shouldSucceed = true,
    this.result,
    this.failure,
  });

  @override
  Future<Either<Failure, String>> call(String params) async {
    if (shouldSucceed) {
      return Right(result ?? 'success');
    } else {
      return Left(failure ?? const UnknownFailure(message: 'Mock failure'));
    }
  }
}

class MockSyncUseCase extends SyncUseCase<int, int> {
  final bool shouldSucceed;
  final int? result;
  final Failure? failure;

  MockSyncUseCase({
    this.shouldSucceed = true,
    this.result,
    this.failure,
  });

  @override
  Either<Failure, int> call(int params) {
    if (shouldSucceed) {
      return Right(result ?? params * 2);
    } else {
      return Left(failure ?? const UnknownFailure(message: 'Mock sync failure'));
    }
  }
}

class MockVoidUseCase extends VoidUseCase<String> {
  final bool shouldSucceed;
  final Failure? failure;

  MockVoidUseCase({
    this.shouldSucceed = true,
    this.failure,
  });

  @override
  Future<Either<Failure, void>> call(String params) async {
    if (shouldSucceed) {
      return const Right(null);
    } else {
      return Left(failure ?? const UnknownFailure(message: 'Mock void failure'));
    }
  }
}

class MockNoParamsUseCase extends UseCase<bool, NoParams> {
  final bool shouldSucceed;

  MockNoParamsUseCase({this.shouldSucceed = true});

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    if (shouldSucceed) {
      return const Right(true);
    } else {
      return const Left(UnknownFailure(message: 'Mock no params failure'));
    }
  }
}

void main() {
  group('UseCase', () {
    late MockUseCase mockUseCase;

    setUp(() {
      mockUseCase = MockUseCase();
    });

    test('should return Right when use case succeeds', () async {
      // Arrange
      const testParam = 'test';
      const expectedResult = 'success';
      mockUseCase = MockUseCase(
        shouldSucceed: true,
        result: expectedResult,
      );

      // Act
      final result = await mockUseCase(testParam);

      // Assert
      expect(result, isA<Right<Failure, String>>());
      result.fold(
        (failure) => fail('Should not return failure'),
        (success) => expect(success, equals(expectedResult)),
      );
    });

    test('should return Left when use case fails', () async {
      // Arrange
      const testParam = 'test';
      const expectedFailure = NetworkFailure(message: 'Network error');
      mockUseCase = MockUseCase(
        shouldSucceed: false,
        failure: expectedFailure,
      );

      // Act
      final result = await mockUseCase(testParam);

      // Assert
      expect(result, isA<Left<Failure, String>>());
      result.fold(
        (failure) => expect(failure, equals(expectedFailure)),
        (success) => fail('Should not return success'),
      );
    });
  });

  group('SyncUseCase', () {
    late MockSyncUseCase mockSyncUseCase;

    setUp(() {
      mockSyncUseCase = MockSyncUseCase();
    });

    test('should return Right when sync use case succeeds', () {
      // Arrange
      const testParam = 5;
      const expectedResult = 10;
      mockSyncUseCase = MockSyncUseCase(
        shouldSucceed: true,
        result: expectedResult,
      );

      // Act
      final result = mockSyncUseCase(testParam);

      // Assert
      expect(result, isA<Right<Failure, int>>());
      result.fold(
        (failure) => fail('Should not return failure'),
        (success) => expect(success, equals(expectedResult)),
      );
    });

    test('should return Left when sync use case fails', () {
      // Arrange
      const testParam = 5;
      const expectedFailure = ValidationFailure(message: 'Invalid input');
      mockSyncUseCase = MockSyncUseCase(
        shouldSucceed: false,
        failure: expectedFailure,
      );

      // Act
      final result = mockSyncUseCase(testParam);

      // Assert
      expect(result, isA<Left<Failure, int>>());
      result.fold(
        (failure) => expect(failure, equals(expectedFailure)),
        (success) => fail('Should not return success'),
      );
    });
  });

  group('VoidUseCase', () {
    late MockVoidUseCase mockVoidUseCase;

    setUp(() {
      mockVoidUseCase = MockVoidUseCase();
    });

    test('should return Right(null) when void use case succeeds', () async {
      // Arrange
      const testParam = 'test';
      mockVoidUseCase = MockVoidUseCase(shouldSucceed: true);

      // Act
      final result = await mockVoidUseCase(testParam);

      // Assert
      expect(result, isA<Right<Failure, void>>());
      result.fold(
        (failure) => fail('Should not return failure'),
        (success) => {}, // void return type, nothing to assert
      );
    });

    test('should return Left when void use case fails', () async {
      // Arrange
      const testParam = 'test';
      const expectedFailure = ServerFailure(message: 'Server error');
      mockVoidUseCase = MockVoidUseCase(
        shouldSucceed: false,
        failure: expectedFailure,
      );

      // Act
      final result = await mockVoidUseCase(testParam);

      // Assert
      expect(result, isA<Left<Failure, void>>());
      result.fold(
        (failure) => expect(failure, equals(expectedFailure)),
        (success) => fail('Should not return success'),
      );
    });
  });

  group('NoParams', () {
    test('should have equality', () {
      // Arrange
      const noParams1 = NoParams();
      const noParams2 = NoParams();

      // Assert
      expect(noParams1, equals(noParams2));
      expect(noParams1.hashCode, equals(noParams2.hashCode));
    });

    test('should work with use case', () async {
      // Arrange
      final mockNoParamsUseCase = MockNoParamsUseCase(shouldSucceed: true);
      const noParams = NoParams();

      // Act
      final result = await mockNoParamsUseCase(noParams);

      // Assert
      expect(result, isA<Right<Failure, bool>>());
      result.fold(
        (failure) => fail('Should not return failure'),
        (success) => expect(success, isTrue),
      );
    });
  });
}
