import 'package:dartz/dartz.dart';
import 'package:triva/core/error/failures.dart';
import 'package:triva/core/use_cases/usecase.dart';
import 'package:triva/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:triva/features/number_trivia/domain/repositories/number_trivia_repo.dart';

class GetRandomNumberTrivia implements Usecase<NumberTrivia, NoParams> {
  final NumberTriviaRepository repository;

  GetRandomNumberTrivia(this.repository);

  @override
  Future<Either<Failure, NumberTrivia>> call(NoParams params) async {
    return await repository.getRandomNumberTrivia();
  }
}
