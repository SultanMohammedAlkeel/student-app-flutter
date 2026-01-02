class UserModel {
  final int? id;
  final String name;
  final String email;
  final String? password; // جعلها nullable لأننا قد لا نستلمها من API
  final String? imageUrl;
  final String? phoneNumber;
  final int? academicId;
  final String? token;
  final int? roleId;
  final int? userId;
  final String? status;
  final String? userType;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    this.password,
    this.imageUrl,
    this.phoneNumber,
    this.academicId,
    this.token,
    this.roleId,
    this.userId,
    this.status,
    this.userType,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      return UserModel(
        id: json['id'] as int?,
        name: (json['name'] ?? '') as String,
        email: (json['email'] ?? '') as String,
        password: json['password'] as String?,
        imageUrl: json['image_url'] as String?,
        phoneNumber: json['phone_number'] as String?,
        academicId: json['academic_id'] as int?,
        token: (json['token'] ?? json['access_token']) as String?,
        roleId: json['role_id'] as int?,
        userId: json['user_id'] as int?,
        status: json['status'] as String?,
        userType: json['user'] as String?,
      );
    } catch (e) {
      throw 'خطأ في تحويل بيانات المستخدم: ${e.toString()}';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (password != null) 'password': password,
      'image_url': imageUrl,
      'phone_number': phoneNumber,
      'academic_id': academicId,
      if (token != null) 'token': token,
      if (roleId != null) 'role_id': roleId,
      if (userId != null) 'user_id': userId,
      if (status != null) 'status': status,
      if (userType != null) 'user': userType,
    };
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    String? imageUrl,
    String? phoneNumber,
    int? academicId,
    String? token,
    int? roleId,
    int? userId,
    String? status,
    String? userType,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      imageUrl: imageUrl ?? this.imageUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      academicId: academicId ?? this.academicId,
      token: token ?? this.token,
      roleId: roleId ?? this.roleId,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      userType: userType ?? this.userType,
    );
  }
}