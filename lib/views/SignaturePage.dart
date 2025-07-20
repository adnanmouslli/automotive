import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';
import 'dart:typed_data';

import '../utils/AppColors.dart';

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
      penColor: AppColors.darkGray,
      exportBackgroundColor: AppColors.pureWhite,
    );

    _nameController = TextEditingController(text: defaultName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: TextStyle(color: AppColors.whiteText)),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.whiteText,
        actions: [
          TextButton.icon(
            onPressed: _clearSignature,
            icon: Icon(Icons.clear, color: AppColors.whiteText),
            label: Text(
              'clear_signature'.tr,
              style: TextStyle(color: AppColors.whiteText),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Name input
          Container(
            padding: const EdgeInsets.all(20),
            color: AppColors.lightGray,
            child: TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'signer_name'.tr,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.borderGray),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.borderGray),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
                ),
                prefixIcon: Icon(Icons.person, color: AppColors.mediumGray),
                filled: true,
                fillColor: AppColors.pureWhite,
              ),
              style: TextStyle(color: AppColors.darkGray),
            ),
          ),

          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              'please_sign_below'.tr,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.mediumGray,
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
                border: Border.all(color: AppColors.borderGray, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Signature(
                  controller: _signatureController,
                  backgroundColor: AppColors.pureWhite,
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
                    style: AppColors.secondaryButtonStyle.copyWith(
                      padding: MaterialStateProperty.all(
                          const EdgeInsets.all(16)),
                    ),
                    child: Text('cancel'.tr),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveSignature,
                    style: AppColors.primaryButtonStyle.copyWith(
                      padding: MaterialStateProperty.all(
                          const EdgeInsets.all(16)),
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
        backgroundColor: AppColors.errorRed,
        colorText: AppColors.whiteText,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (_signatureController.isEmpty) {
      Get.snackbar(
        'signature_error'.tr,
        'add_signature_first'.tr,
        backgroundColor: AppColors.errorRed,
        colorText: AppColors.whiteText,
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
        backgroundColor: AppColors.errorRed,
        colorText: AppColors.whiteText,
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