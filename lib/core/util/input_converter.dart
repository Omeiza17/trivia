import 'package:dartz/dartz.dart';
import 'package:triva/core/error/failures.dart';

class InputConverter {
  Either<Failure, int> stringToUnsignedInteger(String str) {
    try {
      final parse = int.parse(str);
      if (parse < 0) throw FormatException();
      return Right(parse);
    } on FormatException {
      return Left(InvalidInputFailure());
    }
  }
}

class InvalidInputFailure extends Failure {
  @override
  List<Object> get props => [];
}
