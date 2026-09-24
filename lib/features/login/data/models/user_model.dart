// lib/features/auth/data/models/user_model.dart
import '../../domain/entities/user.dart';

class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.mobile,
    this.email,
    this.photo,
    this.birthday,
    this.profession,
    this.education,
    this.institution,
    this.address,
    this.gender,
    this.hasReward,
    this.pendingRewardProof,
  });

  final int id;
  final String name;
  final String mobile;
  final String? email;
  final String? photo;
  final String? birthday;
  final String? profession;
  final String? education;
  final String? institution;
  final String? address;
  final int? gender;
  final int? hasReward;
  final int? pendingRewardProof;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as int,
    name: json['name'] as String? ?? '',
    mobile: json['mobile'] as String? ?? '',
    email: json['email'] as String?,
    photo: json['photo'] as String?,
    birthday: json['birthday'] as String?,
    profession: json['profession'] as String?,
    education: json['education'] as String?,
    institution: json['institution'] as String?,
    address: json['address'] as String?,
    gender: json['gender'] as int?,
    hasReward: json['has_reward'] as int?,
    pendingRewardProof: json['pending_reward_proof'] as int?,
  );

  User toEntity() => User(
    id: id,
    name: name,
    mobile: mobile,
    hasReward: hasReward == 1,
    gender: _toGender(gender),
    email: email,
    photo: photo,
    birthday: birthday == null ? null : DateTime.tryParse(birthday!),
    profession: profession,
    education: education,
    institution: institution,
    address: address,
    pendingRewardProof: pendingRewardProof,
  );

  static Gender? _toGender(int? value) => switch (value) {
    0 => Gender.male,
    1 => Gender.female,
    null => null,
    _ => Gender.other,
  };
}
