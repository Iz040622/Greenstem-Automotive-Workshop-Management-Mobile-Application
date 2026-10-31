import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  String uid;

  @HiveField(1)
  String email;

  @HiveField(2)
  String username;

  @HiveField(3)
  String? photoURL;

  @HiveField(4)
  bool emailVerified;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime? lastLogin;

  @HiveField(7)
  String? provider; // 'email' or 'google'

  @HiveField(8)
  String? phoneNumber;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    this.photoURL,
    this.emailVerified = false,
    required this.createdAt,
    this.lastLogin,
    this.provider,
    this.phoneNumber,
  });

  // 从 Map 创建 UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      photoURL: map['photoURL'],
      emailVerified: map['emailVerified'] ?? false,
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
      lastLogin: map['lastLogin'] != null 
          ? DateTime.parse(map['lastLogin']) 
          : null,
      provider: map['provider'],
      phoneNumber: map['phoneNumber'],
    );
  }

  // 转换为 Map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'photoURL': photoURL,
      'emailVerified': emailVerified,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'provider': provider,
      'phoneNumber': phoneNumber,
    };
  }

  // 从 Firebase User 创建 UserModel
  factory UserModel.fromFirebaseUser(dynamic firebaseUser) {
    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      username: firebaseUser.displayName ?? 'User',
      photoURL: firebaseUser.photoURL,
      emailVerified: firebaseUser.emailVerified,
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
    );
  }

  // 复制并更新
  UserModel copyWith({
    String? uid,
    String? email,
    String? username,
    String? photoURL,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? lastLogin,
    String? provider,
    String? phoneNumber,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      username: username ?? this.username,
      photoURL: photoURL ?? this.photoURL,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      provider: provider ?? this.provider,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, username: $username, emailVerified: $emailVerified)';
  }
}

