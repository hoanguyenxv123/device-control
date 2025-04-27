import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Avatar',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue,
                    child: Text(
                      '${userProvider.user?.name[0]}',
                      style: TextStyle(color: Colors.white, fontSize: 36),
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
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.white),
      body: Center(
        child: CircleAvatar(
          radius: 32,
          backgroundColor: Colors.white,
          child: Text(
            '${userProvider.user?.name[0]}',
            style: TextStyle(color: Colors.blue, fontSize: 30),
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
