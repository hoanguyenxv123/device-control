import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_control/data/firebase/user_service.dart';

import '../../model/user_model.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  /// Lấy người dùng hiện tại
  User? get currentUser => _firebaseAuth.currentUser;

  /// Lấy ID người dùng hiện tại
  String? get currentUserId => currentUser?.uid;

  /// Lấy thông tin người dùng hiện tại từ Firestore
  Future<UserModel?> getCurrentUserData() async {
    try {
      if (currentUser != null) {
        return await _userService.getUser(currentUser!.uid);
      }
      return null;
    } catch (e) {
      print("Lỗi khi lấy thông tin user: $e");
      return null;
    }
  }


  /// Đăng ký với email và mật khẩu
  Future<User?> createUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        await _userService.addUser(UserModel(
          id: user.uid,
          name: user.displayName ?? "New User",
          email: user.email ?? "",
          avatarUrl: user.photoURL ?? "assets/images/default_avatar.png",
        ));
      }
      return user;
    } catch (e) {
      print("Lỗi khi đăng ký: $e");
      return null;
    }
  }

  /// Đăng nhập với email và mật khẩu
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Lỗi khi đăng nhập: $e");
      return null;
    }
  }

  /// Đăng xuất
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      print("Đăng xuất thành công");
    } catch (e) {
      print("Lỗi khi đăng xuất: $e");
    }
  }

  /// Gửi email đặt lại mật khẩu
  Future<void> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      print("Email đặt lại mật khẩu đã được gửi");
    } catch (e) {
      print("Lỗi khi gửi email đặt lại mật khẩu: $e");
    }
  }
}
