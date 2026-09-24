// lib/features/auth/domain/entities/user.dart
import 'package:equatable/equatable.dart';

enum Gender { male, female, other }

class User extends Equatable {
  const User({
    required this.id,
    required this.name,
    required this.mobile,
    required this.hasReward,
    this.gender,
    this.email,
    this.photo,
    this.birthday,
    this.profession,
    this.education,
    this.institution,
    this.address,
    this.pendingRewardProof,
  });

  final int id;
  final String name;
  final String mobile;
  final bool hasReward;
  final Gender? gender;
  final String? email;
  final String? photo;
  final DateTime? birthday;
  final String? profession;
  final String? education;
  final String? institution;
  final String? address;
  final int? pendingRewardProof;

  bool get hasPhoto => photo != null && photo!.isNotEmpty;

  @override
  List<Object?> get props => [
    id,
    name,
    mobile,
    hasReward,
    gender,
    email,
    photo,
    birthday,
    profession,
    education,
    institution,
    address,
    pendingRewardProof,
  ];
}
