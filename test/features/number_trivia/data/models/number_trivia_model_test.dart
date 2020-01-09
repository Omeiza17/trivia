import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:triva/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:triva/features/number_trivia/domain/entities/number_trivia.dart';

import '../../../../fixtures/reader.dart';

void main() {
  final tNumberTriviaModel = NumberTriviaModel(number: 1, text: 'Test Text');

  test(
    'should be a subclass of NumberTrivia entity',
    () async {
      expect(tNumberTriviaModel, isA<NumberTrivia>());
    },
  );

  group(
    'fromJson',
    () {
      test(
        'should return a valid model when JSON number is an integer',
        () async {
          final Map<String, dynamic> jsonMap =
              json.decode(fixture('trivia.json'));

          final result = NumberTriviaModel.fromJson(jsonMap);

          expect(result, tNumberTriviaModel);
        },
      );

      test(
        'should return a valid model when JSON number is a Double',
        () async {
          final Map<String, dynamic> jsonMap =
              json.decode(fixture('trivia_double.json'));

          final result = NumberTriviaModel.fromJson(jsonMap);

          expect(result, tNumberTriviaModel);
        },
      );
    },
  );

  group(
    'toJson',
    () {
      test(
        'should return a JSON Map containing the proper data format',
        () async {
          final result = tNumberTriviaModel.toJson();

          expect(result, {
            "text": "Test Text",
            "number": 1,
          });
        },
      );
    },
  );
}
