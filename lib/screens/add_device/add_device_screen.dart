import 'package:flutter/material.dart';
import 'package:test_control/screens/add_device/widgets/form_styles.dart';
import 'package:test_control/screens/add_device/widgets/image_picker_grid.dart';

import '../../constant/app_colors.dart';
import '../../constant/device_image.dart';
import '../../data/remote/firestore_service.dart';
import '../../model/device/device_model.dart';

class AddDeviceScreen extends StatefulWidget {
  final String roomId;

  final DeviceModel? initialDevice;

  const AddDeviceScreen({
    required this.roomId,
    this.initialDevice, // nullable, nếu null là thêm mới
  });

  @override
  _AddDeviceScreenState createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _commandController = TextEditingController();
  final _typeController = TextEditingController();
  final _imageController = TextEditingController();

  FirestoreService _firestoreService = FirestoreService();

  List<int> availablePorts = [];
  int? selectedPort;

  String? selectedImagePath;
  bool _isOn = false;
  bool _isLoading = false;
  String? _imageErrorText;

  @override
  void initState() {
    super.initState();
    _loadAvailablePorts();

    if (widget.initialDevice != null) {
      final d = widget.initialDevice!;
      _nameController.text = d.name;
      _commandController.text = d.controllerName;
      _typeController.text = d.type;
      _imageController.text = d.imagePath;
      selectedImagePath = d.imagePath;
      selectedPort = d.devicePort;
      _isOn = d.isOn;
    }
  }

  void _loadAvailablePorts() async {
    List<int> ports = await _firestoreService.getAvailablePortsGlobal();

    if (widget.initialDevice != null &&
        !ports.contains(widget.initialDevice!.devicePort)) {
      ports.add(widget.initialDevice!.devicePort);
    }

    setState(() {
      availablePorts = ports;
    });
  }

  void _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text("Xác nhận xoá"),
            content: Text("Bạn có chắc muốn xoá thiết bị này không?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text("Huỷ"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text("Xoá"),
              ),
            ],
          ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);

      await _firestoreService.deleteDeviceAndUpdateCount(
        widget.roomId,
        widget.initialDevice!.id!,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("🗑️ Đã xoá thiết bị")));

      setState(() => _isLoading = false);
      Navigator.pop(context);
    }
  }

  void _submit() async {
    setState(() {
      _imageErrorText =
          selectedImagePath == null ? 'Vui lòng chọn hình thiết bị' : null;
    });

    if (_formKey.currentState!.validate() && selectedImagePath != null) {
      setState(() => _isLoading = true);

      final device = DeviceModel(
        devicePort: selectedPort!,
        name: _nameController.text.trim(),
        type: _typeController.text.trim(),
        controllerName: _commandController.text.trim(),
        imagePath: _imageController.text.trim(),
        isOn: _isOn,
      );

      if (widget.initialDevice == null) {
        await _firestoreService.addDeviceToRoom(widget.roomId, device);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("✅ Thiết bị đã được thêm")));
      } else {
        await _firestoreService.updateDeviceInfo(
          widget.roomId,
          device.devicePort,
          name: device.name,
          controllerName: device.controllerName,
          type: device.type,
          imagePath: device.imagePath,
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("✅ Thiết bị đã được cập nhật")));
      }

      setState(() => _isLoading = false);
      Navigator.pop(context);
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => ImagePickerGrid(
            imageMap: DeviceImage.all,
            selectedImagePath: selectedImagePath,
            onImageSelected: (path) {
              setState(() {
                selectedImagePath = path;
                _imageController.text = path;
                _imageErrorText = null;
              });
              Navigator.pop(context);
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialDevice == null ? 'Thêm thiết bị' : 'Sửa thiết bị',
          style: TextStyle(fontSize: 26),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<int>(
                  value: selectedPort,
                  hint: Text('Chọn cổng thiết bị'),
                  decoration: customInputDecoration('Cổng thiết bị'),
                  items:
                      availablePorts.map((port) {
                        return DropdownMenuItem(
                          value: port,
                          child: Text('Cổng $port'),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedPort = value!;
                    });
                  },
                  validator:
                      (value) =>
                          value == null ? 'Vui lòng chọn cổng thiết bị' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _nameController,
                  decoration: customInputDecoration('Tên thiết bị'),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Nhập tên thiết bị'
                              : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _commandController,
                  decoration: customInputDecoration('Lệnh điều khiển'),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Nhập lệnh điều khiển'
                              : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _typeController,
                  decoration: customInputDecoration('Hãng sản xuất'),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Nhập hãng sản xuất'
                              : null,
                ),

                const SizedBox(height: 24),
                Text(
                  'Hình thiết bị đã chọn:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                if (selectedImagePath != null)
                  Column(
                    children: [
                      Image.asset(selectedImagePath!, width: 80, height: 80),
                      const SizedBox(height: 4),
                      Text(
                        DeviceImage.all.entries
                            .firstWhere((e) => e.value == selectedImagePath)
                            .key,
                      ),
                    ],
                  )
                else
                  Text(
                    'Chưa chọn',
                    style: TextStyle(
                      color: _imageErrorText != null ? Colors.red : null,
                    ),
                  ),

                if (_imageErrorText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _imageErrorText!,
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),

                const SizedBox(height: 10),

                ElevatedButton.icon(
                  onPressed: _showImagePicker,
                  icon: Icon(Icons.image, size: 24, color: Colors.white),
                  label: Text('Chọn hình thiết bị'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),

                const SizedBox(height: 24),

                const SizedBox(height: 20),
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : widget.initialDevice == null
                    ? SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submit,
                        child: Text('Thêm thiết bị'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          textStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                    : Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _submit,
                            icon: Icon(Icons.save),
                            label: Text("Lưu"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _delete,
                            icon: Icon(Icons.delete),
                            label: Text("Xoá"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
