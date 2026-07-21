class ProfileModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? avatarUrl;
  final String? dob;
  final String? gender;
  final String? address;
  final String membershipBadge;
  final String joinDate;
  final int rewardPoints;
  final double profileCompletion;

  const ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatarUrl,
    this.dob,
    this.gender,
    this.address,
    this.membershipBadge = 'Gold Member',
    this.joinDate = 'July 2026',
    this.rewardPoints = 350,
    this.profileCompletion = 0.8,
  });

  ProfileModel copyWith({
    String? name,
    String? phone,
    String? avatarUrl,
    String? dob,
    String? gender,
    String? address,
    String? membershipBadge,
    String? joinDate,
    int? rewardPoints,
    double? profileCompletion,
  }) {
    return ProfileModel(
      id: id,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      membershipBadge: membershipBadge ?? this.membershipBadge,
      joinDate: joinDate ?? this.joinDate,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      profileCompletion: profileCompletion ?? this.profileCompletion,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'dob': dob,
      'gender': gender,
      'address': address,
      'membershipBadge': membershipBadge,
      'joinDate': joinDate,
      'rewardPoints': rewardPoints,
      'profileCompletion': profileCompletion,
    };
  }

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      avatarUrl: map['avatarUrl']?.toString(),
      dob: map['dob']?.toString(),
      gender: map['gender']?.toString(),
      address: map['address']?.toString(),
      membershipBadge: map['membershipBadge']?.toString() ?? 'Gold Member',
      joinDate: map['joinDate']?.toString() ?? 'July 2026',
      rewardPoints: (map['rewardPoints'] as num?)?.toInt() ?? 350,
      profileCompletion: (map['profileCompletion'] as num?)?.toDouble() ?? 0.8,
    );
  }
}
