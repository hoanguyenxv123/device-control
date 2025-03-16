import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../firebase/user_service.dart';
import '../../model/user_model.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;
  final UserService _userService = UserService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel? get user => _user;

  Future<void> fetchUserData() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      String userId = currentUser.uid; // Lấy ID từ Firebase Auth
      UserModel? fetchedUser = await _userService.getUser(userId);
      if (fetchedUser != null) {
        _user = fetchedUser;
        notifyListeners(); // Cập nhật UI
      }
    }
  }
  /// 🔹 Cập nhật tên người dùng
  Future<void> updateUserName(String newName) async {
    if (_user == null) return;
    await _userService.updateUserName(_user!.id, newName);
    _user = _user!.copyWith(name: newName);
    notifyListeners();
  }

  /// 🔹 Cập nhật ảnh đại diện người dùng
  Future<void> updateUserAvatar(String newAvatarUrl) async {
    if (_user == null) return;
    await _userService.updateUserAvatar(_user!.id, newAvatarUrl);
    _user = _user!.copyWith(avatarUrl: newAvatarUrl);
    notifyListeners();
  }
}
