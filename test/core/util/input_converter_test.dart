import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triva/core/util/input_converter.dart';

void main() {
  InputConverter inputConverter;

  setUp(
    () {
      inputConverter = InputConverter();
    },
  );

  group(
    'stringToUnsignedInt',
    () {
      test(
        'should return an integer when the string represent an unsigned integer',
        () async {
          // arrange
          final str = '124';
          // act
          final result = inputConverter.stringToUnsignedInteger(str);
          // assert
          expect(result, Right(124));
        },
      );

      test(
        'should return a Failure when the string is not an integer',
        () async {
          // arrange
          final str = 'abc';
          // act
          final result = inputConverter.stringToUnsignedInteger(str);
          // assert
          expect(result, Left(InvalidInputFailure()));
        },
      );

      test(
        'should return a Failure when the string is negative',
        () async {
          // arrange
          final str = '-123';
          // act
          final result = inputConverter.stringToUnsignedInteger(str);
          // assert
          expect(result, Left(InvalidInputFailure()));
        },
      );
    },
  );
}
