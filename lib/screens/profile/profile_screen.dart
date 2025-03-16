import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:test_control/common_widget/title_add_new.dart';

import '../../common_widget/custom_dialog.dart';
import '../../constant/app_colors.dart';
import '../../data/provider/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _nameController.text = userProvider.user?.name ?? "";
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    String imageUrl = userProvider.user!.avatarUrl;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new),
        ),
        title: Text(
          'Profile',
          style: TextStyle(
            fontSize: 24,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Container(color: Colors.grey, height: 1),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TitleAddNew(
              title: 'Profile picture',
              addNew: () => _pickImage(context, userProvider),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(
                child: InkWell(
                  onTap: () {
                    _showFullImage(context, imageUrl);
                  },
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage:
                        userProvider.user?.avatarUrl != null
                            ? (userProvider.user!.avatarUrl.startsWith(
                                  '/data/user/0/',
                                )
                                ? FileImage(File(userProvider.user!.avatarUrl))
                                : AssetImage(userProvider.user!.avatarUrl)
                                    as ImageProvider)
                            : AssetImage('assets/default_avatar.png'),
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Divider(thickness: 0.8, color: Colors.grey),
            ),
            Text(
              'Name',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 20),
            Container(
              height: 68,
              padding: const EdgeInsets.only(left: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primaryColor.withOpacity(0.8),
                  width: 2,
                ),
                color: AppColors.primaryColor.withOpacity(0.1),
              ),
              child: Center(
                child: TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(border: InputBorder.none),
                  style: const TextStyle(color: Colors.black, fontSize: 20),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                onTap: () {
                  _showConfirmDialog(context, () {
                    userProvider.updateUserName(_nameController.text);
                  });
                  FocusScope.of(context).unfocus();
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  height: 50,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Update',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Divider(thickness: 0.8, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

void _showFullImage(BuildContext context, String imageUrl) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => FullScreenImage(imageUrl: imageUrl),
    ),
  );
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.white),
      body: Center(
        child: InteractiveViewer(
          child:
              imageUrl.startsWith('/data/user/0/') ||
                      imageUrl.startsWith('file://')
                  ? Image.file(File(imageUrl)) // Load ảnh từ file
                  : Image.network(
                    imageUrl,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/default_avatar.png',
                      ); // Ảnh mặc định nếu lỗi
                    },
                  ),
        ),
      ),
    );
  }
}

void _showConfirmDialog(BuildContext context, VoidCallback update) {
  showDialog(
    context: context,
    builder:
        (context) => CustomDialog(
          message: 'Are you sure you want to update?',
          isError: false,
          onConfirm: update,
        ),
  );
}

void _pickImage(BuildContext context, UserProvider userProvider) async {
  final ImagePicker picker = ImagePicker();
  XFile? image;

  // Hiển thị menu chọn ảnh
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Chọn ảnh từ thư viện'),
              onTap: () async {
                Navigator.pop(context);
                image = await picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  userProvider.updateUserAvatar(image!.path); // Cập nhật avatar
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Chụp ảnh mới'),
              onTap: () async {
                Navigator.pop(context);
                image = await picker.pickImage(source: ImageSource.camera);
                if (image != null) {
                  userProvider.updateUserAvatar(image!.path); // Cập nhật avatar
                }
              },
            ),
          ],
        ),
      );
    },
  );
}
