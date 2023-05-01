import 'package:chat_app/core/Errors/failer.dart';
import 'package:dartz/dartz.dart';

abstract class Repository {
  Future<Either<ServerFailer, Unit>> createUser();
}
