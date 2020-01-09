import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:triva/core/error/exception.dart';
import 'package:triva/core/error/failures.dart';
import 'package:triva/core/network/network_info.dart';
import 'package:triva/features/number_trivia/data/datasource/number_trivia_local_data_source.dart';
import 'package:triva/features/number_trivia/data/datasource/number_trivia_remote_data_source.dart';
import 'package:triva/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:triva/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:triva/features/number_trivia/domain/entities/number_trivia.dart';

class MockRemoteDataSource extends Mock
    implements NumberTriviaRemoteDataSource {}

class MockLocalDataSource extends Mock implements NumberTriviaLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  NumberTriviaRepositoryImpl repository;
  MockRemoteDataSource mockRemoteDataSource;
  MockLocalDataSource mockLocalDataSource;
  MockNetworkInfo mockNetworkInfo;

  setUp(
    () {
      mockRemoteDataSource = MockRemoteDataSource();
      mockLocalDataSource = MockLocalDataSource();
      mockNetworkInfo = MockNetworkInfo();
      repository = NumberTriviaRepositoryImpl(
        remoteDataSource: mockRemoteDataSource,
        localDataSource: mockLocalDataSource,
        networkInfo: mockNetworkInfo,
      );
    },
  );

  void runTestsOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });
      body();
    });
  }

  void runTestsOffline(Function body) {
    group('device is offline', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });
      body();
    });
  }

  group(
    'GET concrete Number Trivia',
    () {
      final tNumber = 1;
      final tNumberTriviaModel =
          NumberTriviaModel(number: tNumber, text: "test trivia");
      final NumberTrivia tNumberTrivia = tNumberTriviaModel;

      test(
        'should check if the device is connected',
        () async {
          // arrange
          when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
          // act
          repository.getConcreteNumberTrivia(tNumber);
          // assert
          verify(mockNetworkInfo.isConnected);
        },
      );

      runTestsOnline(
        () {
          test(
            'should return remote data when the call to remote data source is successful',
            () async {
              when(mockRemoteDataSource.getConcreteNumberTrivia(any))
                  .thenAnswer((_) async => tNumberTriviaModel);

              final result = await repository.getConcreteNumberTrivia(tNumber);

              verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
              expect(result, equals(Right(tNumberTrivia)));
            },
          );

          test(
            'should cache the data locally when the call to remote data source is successful',
            () async {
              when(mockRemoteDataSource.getConcreteNumberTrivia(any))
                  .thenAnswer((_) async => tNumberTriviaModel);

              await repository.getConcreteNumberTrivia(tNumber);

              verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
              verify(mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel));
            },
          );

          test(
            'should return server failure when the call to remote data source is unsuccessful',
            () async {
              when(mockRemoteDataSource.getConcreteNumberTrivia(any))
                  .thenThrow(SeverException());

              final result = await repository.getConcreteNumberTrivia(tNumber);

              verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
              verifyZeroInteractions(mockLocalDataSource);
              expect(result, equals(Left(ServerFailure())));
            },
          );
        },
      );

      runTestsOffline(
        () {
          test(
            'should return last locally cached data when cached data is present',
            () async {
              when(mockLocalDataSource.getLastNumberTrivia())
                  .thenAnswer((_) async => tNumberTriviaModel);

              final result = await repository.getConcreteNumberTrivia(tNumber);

              verifyZeroInteractions(mockRemoteDataSource);
              verify(mockLocalDataSource.getLastNumberTrivia());
              expect(result, equals(Right(tNumberTrivia)));
            },
          );

          test(
            'should return CacheFailure when there is no cached data present',
            () async {
              when(mockLocalDataSource.getLastNumberTrivia())
                  .thenThrow(CacheException());

              final result = await repository.getConcreteNumberTrivia(tNumber);

              verifyZeroInteractions(mockRemoteDataSource);
              verify(mockLocalDataSource.getLastNumberTrivia());
              expect(result, equals(Left(CacheFailure())));
            },
          );
        },
      );
    },
  );

  group(
    'GET Random Number Trivia',
    () {
      final tNumberTriviaModel =
          NumberTriviaModel(number: 123, text: "test trivia");
      final NumberTrivia tNumberTrivia = tNumberTriviaModel;

      test(
        'should check if the device is connected',
        () async {
          // arrange
          when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
          // act
          repository.getRandomNumberTrivia();
          // assert
          verify(mockNetworkInfo.isConnected);
        },
      );

      runTestsOnline(
        () {
          test(
            'should return remote data when the call to remote data source is successful',
            () async {
              when(mockRemoteDataSource.getRandomNumberTrivia())
                  .thenAnswer((_) async => tNumberTriviaModel);

              final result = await repository.getRandomNumberTrivia();

              verify(mockRemoteDataSource.getRandomNumberTrivia());
              expect(result, equals(Right(tNumberTrivia)));
            },
          );

          test(
            'should cache the data locally when the call to remote data source is successful',
            () async {
              when(mockRemoteDataSource.getRandomNumberTrivia())
                  .thenAnswer((_) async => tNumberTriviaModel);

              await repository.getRandomNumberTrivia();

              verify(mockRemoteDataSource.getRandomNumberTrivia());
              verify(mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel));
            },
          );

          test(
            'should return server failure when the call to remote data source is unsuccessful',
            () async {
              when(mockRemoteDataSource.getRandomNumberTrivia())
                  .thenThrow(SeverException());

              final result = await repository.getRandomNumberTrivia();

              verify(mockRemoteDataSource.getRandomNumberTrivia());
              verifyZeroInteractions(mockLocalDataSource);
              expect(result, equals(Left(ServerFailure())));
            },
          );
        },
      );

      runTestsOffline(
        () {
          test(
            'should return last locally cached data when cached data is present',
            () async {
              when(mockLocalDataSource.getLastNumberTrivia())
                  .thenAnswer((_) async => tNumberTriviaModel);

              final result = await repository.getRandomNumberTrivia();

              verifyZeroInteractions(mockRemoteDataSource);
              verify(mockLocalDataSource.getLastNumberTrivia());
              expect(result, equals(Right(tNumberTrivia)));
            },
          );

          test(
            'should return CacheFailure when there is no cached data present',
            () async {
              when(mockLocalDataSource.getLastNumberTrivia())
                  .thenThrow(CacheException());

              final result = await repository.getRandomNumberTrivia();

              verifyZeroInteractions(mockRemoteDataSource);
              verify(mockLocalDataSource.getLastNumberTrivia());
              expect(result, equals(Left(CacheFailure())));
            },
          );
        },
      );
    },
  );
}
