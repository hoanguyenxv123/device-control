import 'package:flutter/material.dart';

class ImagePickerGrid extends StatelessWidget {
  final Map<String, String> imageMap;
  final String? selectedImagePath;
  final Function(String path) onImageSelected;

  const ImagePickerGrid({
    super.key,
    required this.imageMap,
    required this.selectedImagePath,
    required this.onImageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        itemCount: imageMap.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.9,
        ),
        itemBuilder: (context, index) {
          String label = imageMap.keys.elementAt(index);
          String path = imageMap.values.elementAt(index);
          bool isSelected = selectedImagePath == path;

          return GestureDetector(
            onTap: () => onImageSelected(path),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(path, width: 60, height: 60),
                  const SizedBox(height: 6),
                  Text(label, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
