import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';
import 'dart:typed_data';

class SignaturePage extends StatefulWidget {
  @override
  _SignaturePageState createState() => _SignaturePageState();
}

class _SignaturePageState extends State<SignaturePage> {
  late SignatureController _signatureController;
  late TextEditingController _nameController;

  String title = '';
  String defaultName = '';

  @override
  void initState() {
    super.initState();

    // Get arguments
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    title = args['title'] ?? 'signature_page'.tr;
    defaultName = args['signerName'] ?? '';

    _signatureController = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );

    _nameController = TextEditingController(text: defaultName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        actions: [
          TextButton.icon(
            onPressed: _clearSignature,
            icon: const Icon(Icons.clear, color: Colors.white),
            label: Text(
              'clear_signature'.tr,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Name input
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.grey.shade50,
            child: TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'signer_name'.tr,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
          ),

          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              'please_sign_below'.tr,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Signature area
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Signature(
                  controller: _signatureController,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ),

          // Action buttons
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('cancel'.tr),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveSignature,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('save_signature'.tr),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _clearSignature() {
    _signatureController.clear();
  }

  Future<void> _saveSignature() async {
    if (_nameController.text.trim().isEmpty) {
      Get.snackbar(
        'signature_error'.tr,
        'enter_signer_name'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (_signatureController.isEmpty) {
      Get.snackbar(
        'signature_error'.tr,
        'add_signature_first'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    try {
      final Uint8List? signatureBytes = await _signatureController.toPngBytes();

      if (signatureBytes != null) {
        Get.back(result: {
          'signature': signatureBytes,
          'signerName': _nameController.text.trim(),
        });
      } else {
        throw Exception('signature_conversion_failed'.tr);
      }
    } catch (e) {
      Get.snackbar(
        'signature_error'.tr,
        'signature_save_failed_error'.tr.replaceAll('error', e.toString()),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  @override
  void dispose() {
    _signatureController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}