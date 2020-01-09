import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:triva/core/error/failures.dart';
import 'package:triva/core/use_cases/usecase.dart';
import 'package:triva/core/util/input_converter.dart';
import 'package:triva/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:triva/features/number_trivia/domain/use_cases/get_concrete_number_trivia.dart';
import 'package:triva/features/number_trivia/domain/use_cases/get_random_number_trivia.dart';
import 'package:triva/features/number_trivia/presentation/bloc/bloc.dart';

class MockGetConcreteNumberTrivia extends Mock
    implements GetConcreteNumberTrivia {}

class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}

class MockInputConverter extends Mock implements InputConverter {}

void main() {
  NumberTriviaBloc bloc;
  MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  MockInputConverter mockInputConverter;
  setUp(
    () {
      mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
      mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
      mockInputConverter = MockInputConverter();

      bloc = NumberTriviaBloc(
        concrete: mockGetConcreteNumberTrivia,
        random: mockGetRandomNumberTrivia,
        inputConverter: mockInputConverter,
      );
    },
  );

  test(
    'initialState should be empty',
    () async {
      // assert
      expect(bloc.initialState, equals(Empty()));
    },
  );

  group(
    'GetTriviaForConcreteNumber',
    () {
      final tNumberString = '1';
      final tNumberParsed = 1;
      final tNumberTrivia = NumberTrivia(text: 'test trivia', number: 1);

      void setUpMockInputConverterSuccess() =>
          when(mockInputConverter.stringToUnsignedInteger(any))
              .thenReturn(Right(tNumberParsed));

      test(
        'should  call the InputConverter to validate  and converter the string to an unsigned integer',
        () async {
          // arrange
          setUpMockInputConverterSuccess();
          // act
          bloc.add(GetTriviaForConcreteNumber(tNumberString));
          // ensures that the call above is made and completed
          await untilCalled(mockInputConverter.stringToUnsignedInteger(any));
          // assert
          verify(mockInputConverter.stringToUnsignedInteger(tNumberString));
        },
      );

      test(
        'should emit [Error] when the input is invalid',
        () async {
          // arrange
          when(mockInputConverter.stringToUnsignedInteger(any))
              .thenReturn(Left(InvalidInputFailure()));
          // assert later
          final expected = [
            Empty(),
            Error(message: INVALID_INPUT_FAILURE_MESSAGE),
          ];
          expectLater(bloc, emitsInOrder(expected));
          // act
          // use bloc instead of bloc.state as the blocs extends Streams now.
          bloc.add(GetTriviaForConcreteNumber(tNumberString));
        },
      );

      test(
        'should get data from the concrete use case',
        () async {
          // arrange
          setUpMockInputConverterSuccess();
          when(mockGetRandomNumberTrivia(any))
              .thenAnswer((_) async => Right(tNumberTrivia));
          // act
          bloc.add(GetTriviaForConcreteNumber(tNumberString));
          await untilCalled(mockGetConcreteNumberTrivia(any));
          // assert
          verify(mockGetConcreteNumberTrivia(Params(number: tNumberParsed)));
        },
      );

      test(
        'should emit [Loading, Loaded] when data is gotten successfully',
        () async {
          // arrange
          setUpMockInputConverterSuccess();
          when(mockGetConcreteNumberTrivia(any))
              .thenAnswer((_) async => Right(tNumberTrivia));

          // assert later
          final expected = [
            Empty(),
            Loading(),
            Loaded(trivia: tNumberTrivia),
          ];
          expectLater(bloc, emitsInOrder(expected));
          // act
          bloc.add(GetTriviaForConcreteNumber(tNumberString));
        },
      );

      test(
        'should emit [Loading, Error] when getting data fails',
        () async {
          // arrange
          setUpMockInputConverterSuccess();
          when(mockGetConcreteNumberTrivia(any))
              .thenAnswer((_) async => Left(ServerFailure()));

          // assert later
          final expected = [
            Empty(),
            Loading(),
            Error(message: SERVER_FAILURE_MESSAGE),
          ];
          expectLater(bloc, emitsInOrder(expected));
          // act
          bloc.add(GetTriviaForConcreteNumber(tNumberString));
        },
      );

      test(
        'should emit [Loading, Error] with a proper message for the error when getting data fails',
        () async {
          // arrange
          setUpMockInputConverterSuccess();
          when(mockGetConcreteNumberTrivia(any))
              .thenAnswer((_) async => Left(CacheFailure()));

          // assert later
          final expected = [
            Empty(),
            Loading(),
            Error(message: CACHE_FAILURE_MESSAGE),
          ];
          expectLater(bloc, emitsInOrder(expected));
          // act
          bloc.add(GetTriviaForConcreteNumber(tNumberString));
        },
      );
    },
  );

  group(
    'GetTriviaForRandomNumber',
    () {
      final tNumberTrivia = NumberTrivia(text: 'test trivia', number: 1);

      test(
        'should get data from the random use case',
        () async {
          // arrange
          when(mockGetRandomNumberTrivia(NoParams()))
              .thenAnswer((_) async => Right(tNumberTrivia));
          // act
          bloc.add(GetTriviaForRandomNumber());
          await untilCalled(mockGetRandomNumberTrivia(NoParams()));
          // assert
          verify(mockGetRandomNumberTrivia(NoParams()));
        },
      );

      test(
        'should emit [Loading, Loaded] when data is gotten successfully',
        () async {
          // arrange
          when(mockGetRandomNumberTrivia(NoParams()))
              .thenAnswer((_) async => Right(tNumberTrivia));

          // assert later
          final expected = [
            Empty(),
            Loading(),
            Loaded(trivia: tNumberTrivia),
          ];
          expectLater(bloc, emitsInOrder(expected));
          // act
          bloc.add(GetTriviaForRandomNumber());
        },
      );

      test(
        'should emit [Loading, Error] when getting data fails',
        () async {
          // arrange
          when(mockGetRandomNumberTrivia(NoParams()))
              .thenAnswer((_) async => Left(ServerFailure()));

          // assert later
          final expected = [
            Empty(),
            Loading(),
            Error(message: SERVER_FAILURE_MESSAGE),
          ];
          expectLater(bloc, emitsInOrder(expected));
          // act
          bloc.add(GetTriviaForRandomNumber());
        },
      );

      test(
        'should emit [Loading, Error] with a proper message for the error when getting data fails',
        () async {
          // arrange
          when(mockGetRandomNumberTrivia(NoParams()))
              .thenAnswer((_) async => Left(CacheFailure()));

          // assert later
          final expected = [
            Empty(),
            Loading(),
            Error(message: CACHE_FAILURE_MESSAGE),
          ];
          expectLater(bloc, emitsInOrder(expected));
          // act
          bloc.add(GetTriviaForRandomNumber());
        },
      );
    },
  );
}
