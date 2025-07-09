import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ExpensesPage extends StatefulWidget {
  @override
  _ExpensesPageState createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage>
    with TickerProviderStateMixin {

  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Controllers for form fields
  final TextEditingController _fuelController = TextEditingController();
  final TextEditingController _washController = TextEditingController();
  final TextEditingController _adBlueController = TextEditingController();
  final TextEditingController _otherController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // State variables
  bool _isLoading = false;
  bool _isEditMode = false;
  String? _orderId;
  double _totalAmount = 0.0;

  // Animation variables
  bool _showSummary = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadArgumentsAndSetupForm();
    _setupCalculationListeners();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  void _loadArgumentsAndSetupForm() {
    final arguments = Get.arguments as Map<String, dynamic>?;

    if (arguments != null) {
      _orderId = arguments['orderId'] as String?;
      _isEditMode = arguments['isEditMode'] as bool? ?? false;

      // إذا كان في وضع التعديل، تحميل البيانات الموجودة
      if (_isEditMode && arguments['expenses'] != null) {
        final expensesData = arguments['expenses'] as Map<String, dynamic>;
        _populateFieldsFromData(expensesData);
      }
    }
  }

  void _populateFieldsFromData(Map<String, dynamic> expensesData) {
    _fuelController.text = (expensesData['fuel'] ?? 0.0).toString();
    _washController.text = (expensesData['wash'] ?? 0.0).toString();
    _adBlueController.text = (expensesData['adBlue'] ?? 0.0).toString();
    _otherController.text = (expensesData['other'] ?? 0.0).toString();
    _notesController.text = expensesData['notes'] ?? '';

    _calculateTotal();
    _showSummary = true;
  }

  void _setupCalculationListeners() {
    final controllers = [_fuelController, _washController, _adBlueController, _otherController];

    for (final controller in controllers) {
      controller.addListener(_calculateTotal);
    }
  }

  void _calculateTotal() {
    setState(() {
      _totalAmount = _parseDouble(_fuelController.text) +
          _parseDouble(_washController.text) +
          _parseDouble(_adBlueController.text) +
          _parseDouble(_otherController.text);

      _showSummary = _totalAmount > 0;
    });
  }

  double _parseDouble(String text) {
    return double.tryParse(text.replaceAll(',', '.')) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            if (_isLoading) _buildProgressIndicator(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeaderCard(),
                        const SizedBox(height: 24),
                        _buildExpensesForm(),
                        const SizedBox(height: 24),
                        _buildNotesSection(),
                        const SizedBox(height: 24),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          height: _showSummary ? null : 0,
                          child: _showSummary ? _buildSummaryCard() : null,
                        ),
                        const SizedBox(height: 100), // Extra space for bottom actions
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.green.shade600,
      foregroundColor: Colors.white,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isEditMode ? 'edit_expenses'.tr : 'add_expenses_title'.tr,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_orderId != null)
            Text(
              '${'order_label'.tr} $_orderId',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
        ],
      ),
      actions: [
        if (_totalAmount > 0)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Chip(
              label: Text(
                '€${_totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.green.shade800,
            ),
          ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      height: 4,
      child: LinearProgressIndicator(
        backgroundColor: Colors.grey.shade200,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade600),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.shade600,
            Colors.green.shade700,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade200.withOpacity(0.5),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditMode ? 'update_expenses'.tr : 'add_new_expenses'.tr,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'enter_all_expenses_desc'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesForm() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Colors.green.shade600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'expenses_details'.tr,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildExpenseField(
              controller: _fuelController,
              label: 'fuel_cost'.tr,
              icon: Icons.local_gas_station,
              color: Colors.orange,
              hint: '0.00',
            ),
            const SizedBox(height: 16),
            _buildExpenseField(
              controller: _washController,
              label: 'vehicle_wash_cost'.tr,
              icon: Icons.car_crash_outlined,
              color: Colors.blue,
              hint: '0.00',
            ),
            const SizedBox(height: 16),
            _buildExpenseField(
              controller: _adBlueController,
              label: 'adblue_cost'.tr,
              icon: Icons.opacity,
              color: Colors.cyan,
              hint: '0.00',
            ),
            const SizedBox(height: 16),
            _buildExpenseField(
              controller: _otherController,
              label: 'other_expenses_cost'.tr,
              icon: Icons.receipt_long,
              color: Colors.purple,
              hint: '0.00',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required MaterialColor color,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: color.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.shade200),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              prefixIcon: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.shade600,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              suffixText: '€',
              suffixStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color.shade700,
              ),
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator: (value) {
              final amount = _parseDouble(value ?? '');
              if (amount < 0) {
                return 'amount_cannot_be_negative'.tr;
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.note_outlined,
                    color: Colors.blue.shade600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'additional_notes'.tr,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: TextFormField(
                controller: _notesController,
                maxLines: 4,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'add_expense_notes_hint'.tr,
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.shade600,
            Colors.green.shade700,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade200.withOpacity(0.5),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.summarize_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'expenses_summary'.tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSummaryRow('fuel_label'.tr, _parseDouble(_fuelController.text)),
          _buildSummaryRow('vehicle_wash_label'.tr, _parseDouble(_washController.text)),
          _buildSummaryRow('adblue_label'.tr, _parseDouble(_adBlueController.text)),
          _buildSummaryRow('other_label'.tr, _parseDouble(_otherController.text)),
          const SizedBox(height: 16),
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'total_amount'.tr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '€${_totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount) {
    if (amount <= 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            '€${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : () => Get.back(),
                icon: const Icon(Icons.close),
                label: Text('cancel'.tr),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: Colors.grey.shade400),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _isLoading || _totalAmount <= 0 ? null : _submitExpenses,
                icon: _isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : Icon(_isEditMode ? Icons.update : Icons.save),
                label: Text(_isLoading
                    ? 'saving'.tr
                    : _isEditMode ? 'update_expenses_btn'.tr : 'save_expenses_btn'.tr),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitExpenses() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_totalAmount <= 0) {
      Get.snackbar(
        'warning'.tr,
        'must_enter_amount_greater_zero'.tr,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final expensesData = {
        'fuel': _parseDouble(_fuelController.text),
        'wash': _parseDouble(_washController.text),
        'adBlue': _parseDouble(_adBlueController.text),
        'other': _parseDouble(_otherController.text),
        'total': _totalAmount,
        'notes': _notesController.text.trim(),
      };

      // تأخير قصير لإظهار التحميل
      await Future.delayed(const Duration(milliseconds: 500));

      // العودة مع البيانات
      Get.back(result: expensesData);

      // عرض رسالة نجاح
      Get.snackbar(
        'success_saved'.tr,
        _isEditMode
            ? 'expenses_updated_successfully'.tr
            : 'expenses_saved_successfully'.tr,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
    } catch (e) {
      Get.snackbar(
        'error_occurred'.tr,
        'failed_to_save_expenses'.tr.replaceAll('error', e.toString()),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fuelController.dispose();
    _washController.dispose();
    _adBlueController.dispose();
    _otherController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}