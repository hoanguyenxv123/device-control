import 'package:flutter/material.dart';

class TitleAddNew extends StatelessWidget {
  final String title;

  final VoidCallback addNew;

  const TitleAddNew({super.key, required this.title, required this.addNew});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all( 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          GestureDetector(
            onTap: addNew,
            child: Text(
              '+AddNew',
              style: TextStyle(
                fontSize: 18,
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
