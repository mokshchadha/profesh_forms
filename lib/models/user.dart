class UserLocalInfo {
  String? id;
  String? token;
  String? userType;

  UserLocalInfo({
    required this.id,
    required this.token,
    required this.userType,
  });

  factory UserLocalInfo.fromJson(Map<String, dynamic> json) {
    return UserLocalInfo(
      id: json['id'] as String?,
      token: json['token'] as String?,
      userType: json['userType'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'token': token,
      'userType': userType,
    };
  }
}

class LinkedinUserObject {
  String? firstName;
  String? lastName;
  String? email;
  String? profileImageUrl;

  LinkedinUserObject({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.profileImageUrl,
  });

  factory LinkedinUserObject.fromJson(Map<String, dynamic> json) {
    return LinkedinUserObject(
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      email: json['email'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'profileImageUrl': profileImageUrl,
    };
  }
}

class UserServerInfo {
  String? firstName;
  String? lastName;
  String? email;
  String? phoneNumber;
  String? profilePictureUrl;
  String? gender;
  String? status;
  String? normalResumeUrl;
  String? url;
  String? designation;
  final String? company;
  bool isPro;
  String? countryCode;
  String? videoThumbnailUrl;
  String? resumeFileName;
  String? videoUpdated;
  bool? allowPublicFeed;
  String? createdAt;
  int? statusId;
  String? publicHash;

  UserServerInfo({
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.profilePictureUrl,
    this.gender,
    this.status,
    this.normalResumeUrl,
    this.url,
    this.designation,
    this.company,
    this.isPro = false,
    this.countryCode,
    this.videoThumbnailUrl,
    this.resumeFileName,
    this.videoUpdated,
    this.allowPublicFeed,
    this.createdAt,
    this.statusId,
    this.publicHash,
  });

  factory UserServerInfo.fromJson(Map<String, dynamic> json) {
    return UserServerInfo(
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      gender: json['gender'] as String?,
      status: json['status'] as String?,
      normalResumeUrl: json['normalResumeUrl'] as String?,
      url: json['url'] as String?,
      designation: json['designation'] as String?,
      company: json['companyName'] as String?, // Note: using 'companyName' key as in original
      isPro: json['isPro'] as bool? ?? false,
      countryCode: json['countryCode'] as String?,
      videoThumbnailUrl: json['videoThumbnailUrl'] as String?,
      resumeFileName: json['resumeFileName'] as String?,
      videoUpdated: json['videoUpdated'] as String?,
      allowPublicFeed: json['allowPublicFeed'] as bool?,
      createdAt: json['createdAt'] as String?,
      statusId: json['statusId'] as int?,
      publicHash: json['publicHash'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'profilePictureUrl': profilePictureUrl,
      'gender': gender,
      'status': status,
      'normalResumeUrl': normalResumeUrl,
      'url': url,
      'designation': designation,
      'companyName': company, // Note: using 'companyName' key as in original
      'isPro': isPro,
      'countryCode': countryCode,
      'videoThumbnailUrl': videoThumbnailUrl,
      'resumeFileName': resumeFileName,
      'videoUpdated': videoUpdated,
      'allowPublicFeed': allowPublicFeed,
      'createdAt': createdAt,
      'statusId': statusId,
      'publicHash': publicHash,
    };
  }
}