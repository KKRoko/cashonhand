import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import '../../core/error/failures.dart';
import '../database/database.dart';
import '../models/freezed/year_end_goal.dart';
import 'base_repository.dart';

abstract class IYearEndGoalRepository {
  Future<Either<Failure, YearEndGoal?>> getGoalForYear(int year);
  Future<Either<Failure, int>> createGoal(YearEndGoal goal);
  Future<Either<Failure, bool>> updateGoal(YearEndGoal goal);
  Future<Either<Failure, bool>> deleteGoal(int year);
}

@Injectable(as: IYearEndGoalRepository)
class YearEndGoalRepository extends BaseRepository<YearEndGoal> implements IYearEndGoalRepository {
  final Database _db;

  YearEndGoalRepository(this._db);

  // Convert database model to domain model
  YearEndGoal _convertToModel(YearEndGoalTableData data) {
    return YearEndGoal(
      id: data.id,
      year: data.year,
      needsPercentage: data.needsPercentage,
      wantsPercentage: data.wantsPercentage,
      savingsPercentage: data.savingsPercentage,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  // Convert domain model to database companion for insert
  YearEndGoalsCompanion _convertToCompanion(YearEndGoal goal, {bool isUpdate = false}) {
    if (isUpdate) {
      return YearEndGoalsCompanion(
        id: Value(goal.id),
        year: Value(goal.year),
        needsPercentage: Value(goal.needsPercentage),
        wantsPercentage: Value(goal.wantsPercentage),
        savingsPercentage: Value(goal.savingsPercentage),
        updatedAt: Value(DateTime.now()),
      );
    }

    return YearEndGoalsCompanion.insert(
      year: goal.year,
      needsPercentage: goal.needsPercentage,
      wantsPercentage: goal.wantsPercentage,
      savingsPercentage: goal.savingsPercentage,
    );
  }

  @override
  Future<Either<Failure, YearEndGoal?>> getGoalForYear(int year) {
    return catchError(() async {
      final query = _db.select(_db.yearEndGoals)
        ..where((tbl) => tbl.year.equals(year))
        ..limit(1);

      final result = await query.getSingleOrNull();

      if (result == null) {
        return null;
      }

      return _convertToModel(result);
    });
  }

  @override
  Future<Either<Failure, int>> createGoal(YearEndGoal goal) {
    return catchError(() async {
      final companion = _convertToCompanion(goal);
      final id = await _db.into(_db.yearEndGoals).insert(companion);
      return id;
    });
  }

  @override
  Future<Either<Failure, bool>> updateGoal(YearEndGoal goal) {
    return catchError(() async {
      final companion = _convertToCompanion(goal, isUpdate: true);
      final rowsAffected = await (_db.update(_db.yearEndGoals)
            ..where((tbl) => tbl.id.equals(goal.id)))
          .write(companion);
      return rowsAffected > 0;
    });
  }

  @override
  Future<Either<Failure, bool>> deleteGoal(int year) {
    return catchError(() async {
      final rowsDeleted = await (_db.delete(_db.yearEndGoals)
            ..where((tbl) => tbl.year.equals(year)))
          .go();
      return rowsDeleted > 0;
    });
  }
}
