import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/dictionary_entry_entity.dart';
import '../repositories/lexicon_repository.dart';

/// Use case for creating a new dictionary entry
class CreateDictionaryEntryUsecase implements UseCase<DictionaryEntryEntity, CreateDictionaryEntryParams> {
  final LexiconRepository repository;

  CreateDictionaryEntryUsecase(this.repository);

  @override
  Future<Either<Failure, DictionaryEntryEntity>> call(CreateDictionaryEntryParams params) async {
    return await repository.createEntry(params.entry);
  }
}

/// Parameters for CreateDictionaryEntryUsecase
class CreateDictionaryEntryParams extends Equatable {
  final DictionaryEntryEntity entry;

  const CreateDictionaryEntryParams({
    required this.entry,
  });

  @override
  List<Object?> get props => [entry];
}

/// Use case for updating a dictionary entry
class UpdateDictionaryEntryUsecase implements UseCase<DictionaryEntryEntity, UpdateDictionaryEntryParams> {
  final LexiconRepository repository;

  UpdateDictionaryEntryUsecase(this.repository);

  @override
  Future<Either<Failure, DictionaryEntryEntity>> call(UpdateDictionaryEntryParams params) async {
    return await repository.updateEntry(params.entry);
  }
}

/// Parameters for UpdateDictionaryEntryUsecase
class UpdateDictionaryEntryParams extends Equatable {
  final DictionaryEntryEntity entry;

  const UpdateDictionaryEntryParams({
    required this.entry,
  });

  @override
  List<Object?> get props => [entry];
}

/// Use case for deleting a dictionary entry
class DeleteDictionaryEntryUsecase implements UseCase<void, DeleteDictionaryEntryParams> {
  final LexiconRepository repository;

  DeleteDictionaryEntryUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteDictionaryEntryParams params) async {
    return await repository.deleteEntry(params.entryId);
  }
}

/// Parameters for DeleteDictionaryEntryUsecase
class DeleteDictionaryEntryParams extends Equatable {
  final String entryId;

  const DeleteDictionaryEntryParams({
    required this.entryId,
  });

  @override
  List<Object?> get props => [entryId];
}

/// Use case for marking entry as verified
class MarkEntryAsVerifiedUsecase implements UseCase<DictionaryEntryEntity, MarkEntryAsVerifiedParams> {
  final LexiconRepository repository;

  MarkEntryAsVerifiedUsecase(this.repository);

  @override
  Future<Either<Failure, DictionaryEntryEntity>> call(MarkEntryAsVerifiedParams params) async {
    return await repository.markAsVerified(params.entryId, params.reviewerId);
  }
}

/// Parameters for MarkEntryAsVerifiedUsecase
class MarkEntryAsVerifiedParams extends Equatable {
  final String entryId;
  final String reviewerId;

  const MarkEntryAsVerifiedParams({
    required this.entryId,
    required this.reviewerId,
  });

  @override
  List<Object?> get props => [entryId, reviewerId];
}

/// Use case for marking entry as rejected
class MarkEntryAsRejectedUsecase implements UseCase<void, MarkEntryAsRejectedParams> {
  final LexiconRepository repository;

  MarkEntryAsRejectedUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(MarkEntryAsRejectedParams params) async {
    return await repository.markAsRejected(params.entryId, params.reviewerId, params.reason);
  }
}

/// Parameters for MarkEntryAsRejectedUsecase
class MarkEntryAsRejectedParams extends Equatable {
  final String entryId;
  final String reviewerId;
  final String reason;

  const MarkEntryAsRejectedParams({
    required this.entryId,
    required this.reviewerId,
    required this.reason,
  });

  @override
  List<Object?> get props => [entryId, reviewerId, reason];
}

/// Use case for getting entries by contributor
class GetEntriesByContributorUsecase implements UseCase<List<DictionaryEntryEntity>, GetEntriesByContributorParams> {
  final LexiconRepository repository;

  GetEntriesByContributorUsecase(this.repository);

  @override
  Future<Either<Failure, List<DictionaryEntryEntity>>> call(GetEntriesByContributorParams params) async {
    return await repository.getEntriesByContributor(params.contributorId, limit: params.limit);
  }
}

/// Parameters for GetEntriesByContributorUsecase
class GetEntriesByContributorParams extends Equatable {
  final String contributorId;
  final int limit;

  const GetEntriesByContributorParams({
    required this.contributorId,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [contributorId, limit];
}