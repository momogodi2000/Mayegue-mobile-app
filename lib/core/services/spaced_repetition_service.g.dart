// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spaced_repetition_service.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SpacedRepetitionCardAdapter extends TypeAdapter<SpacedRepetitionCard> {
  @override
  final int typeId = 0;

  @override
  SpacedRepetitionCard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SpacedRepetitionCard(
      id: fields[0] as String,
      word: fields[1] as String,
      translation: fields[2] as String,
      languageCode: fields[3] as String,
      pronunciation: fields[4] as String?,
      partOfSpeech: fields[5] as String?,
      exampleSentences: (fields[6] as List).cast<String>(),
      metadata: (fields[7] as Map).cast<String, dynamic>(),
      easinessFactor: fields[8] as double,
      interval: fields[9] as int,
      repetition: fields[10] as int,
      nextReviewDate: fields[11] as DateTime,
      createdAt: fields[12] as DateTime,
      lastReviewedAt: fields[13] as DateTime?,
      reviewSessions: (fields[14] as List?)?.cast<ReviewSession>(),
    );
  }

  @override
  void write(BinaryWriter writer, SpacedRepetitionCard obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.word)
      ..writeByte(2)
      ..write(obj.translation)
      ..writeByte(3)
      ..write(obj.languageCode)
      ..writeByte(4)
      ..write(obj.pronunciation)
      ..writeByte(5)
      ..write(obj.partOfSpeech)
      ..writeByte(6)
      ..write(obj.exampleSentences)
      ..writeByte(7)
      ..write(obj.metadata)
      ..writeByte(8)
      ..write(obj.easinessFactor)
      ..writeByte(9)
      ..write(obj.interval)
      ..writeByte(10)
      ..write(obj.repetition)
      ..writeByte(11)
      ..write(obj.nextReviewDate)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
      ..write(obj.lastReviewedAt)
      ..writeByte(14)
      ..write(obj.reviewSessions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpacedRepetitionCardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReviewSessionAdapter extends TypeAdapter<ReviewSession> {
  @override
  final int typeId = 1;

  @override
  ReviewSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReviewSession(
      date: fields[0] as DateTime,
      quality: fields[1] as ReviewQuality,
      reviewTimeSeconds: fields[2] as int?,
      pronunciationCorrect: fields[3] as bool?,
      additionalData: (fields[4] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, ReviewSession obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.quality)
      ..writeByte(2)
      ..write(obj.reviewTimeSeconds)
      ..writeByte(3)
      ..write(obj.pronunciationCorrect)
      ..writeByte(4)
      ..write(obj.additionalData);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReviewSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
