import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:agendeme/core/core.dart';

class MockInternetConnectionChecker extends Mock
    implements InternetConnectionChecker {}

void main() {
  late NetworkInfoImpl networkInfo;
  late MockInternetConnectionChecker mockConnectionChecker;

  setUp(() {
    mockConnectionChecker = MockInternetConnectionChecker();
    networkInfo = NetworkInfoImpl(mockConnectionChecker);
  });

  group('NetworkInfo', () {
    test('should forward the call to InternetConnectionChecker.hasConnection',
        () async {
      // Arrange
      when(() => mockConnectionChecker.hasConnection)
          .thenAnswer((_) async => true);

      // Act
      final result = await networkInfo.isConnected;

      // Assert
      verify(() => mockConnectionChecker.hasConnection);
      expect(result, true);
    });

    test('should return false when there is no internet connection', () async {
      // Arrange
      when(() => mockConnectionChecker.hasConnection)
          .thenAnswer((_) async => false);

      // Act
      final result = await networkInfo.isConnected;

      // Assert
      verify(() => mockConnectionChecker.hasConnection);
      expect(result, false);
    });

    test('should return false for hasConnection (sync method)', () {
      // Act
      final result = networkInfo.hasConnection;

      // Assert
      expect(result, false);
    });

    test('should forward the onStatusChange stream', () {
      // Arrange
      final testStream = Stream<InternetConnectionStatus>.fromIterable([
        InternetConnectionStatus.connected,
        InternetConnectionStatus.disconnected,
      ]);
      when(() => mockConnectionChecker.onStatusChange)
          .thenAnswer((_) => testStream);

      // Act
      final result = networkInfo.onStatusChange;

      // Assert
      expect(result, equals(testStream));
      verify(() => mockConnectionChecker.onStatusChange);
    });
  });
}
