import 'package:dartz/dartz.dart';
import '../../core/error/exception.dart';
import '../../core/error/failures.dart';

abstract class BaseRepository<T> {
  Future<Either<Failure, T>> catchError<T>(Future<T> Function() call) async {
    try {
      final result = await call();
      return Right(result);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}