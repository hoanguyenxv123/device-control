import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Thêm user vào Firestore (nếu chưa tồn tại)
  Future<void> addUser(UserModel user) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(user.id).get();
      if (!doc.exists) {
        await _firestore.collection('users').doc(user.id).set(user.toJson());
        print("User created: ${user.toJson()}");
      }
    } catch (e) {
      print("Lỗi khi thêm user: $e");
    }
  }

  /// Lấy dữ liệu User từ Firestore
  Future<UserModel?> getUser(String userId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        UserModel user = UserModel.fromJson(doc.data() as Map<String, dynamic>);
        print("User fetched: ${user.toJson()}");
        return user;
      }
      return null;
    } catch (e) {
      print("Lỗi khi lấy user: $e");
      return null;
    }
  }

  Future<void> updateUser(
      String userId, Map<String, dynamic> updateData) async {
    try {
      await _firestore.collection('users').doc(userId).update(updateData);
      print("Cập nhật thành công user $userId với dữ liệu: $updateData");
    } catch (e) {
      print("Lỗi khi cập nhật user: $e");
    }
  }

  /// Cập nhật tên của user
  Future<void> updateUserName(String userId, String newName) async {
    try {
      await _firestore.collection('users').doc(userId).update(
        {
          'name': newName,
        },
      );
      print("Tên của user $userId đã được cập nhật thành: $newName");
    } catch (e) {
      print("Lỗi khi cập nhật tên user: $e");
    }
  }

  /// Cập nhật ảnh đại diện của user
  Future<void> updateUserAvatar(String userId, String avatarUrl) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'avatarUrl': avatarUrl});
      print("Ảnh đại diện của user $userId đã được cập nhật.");
    } catch (e) {
      print("Lỗi khi cập nhật avatar: $e");
    }
  }

  /// Xóa User khỏi Firestore
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      print("User $userId đã bị xóa.");
    } catch (e) {
      print("Lỗi khi xóa user: $e");
    }
  }
}
