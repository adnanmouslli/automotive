import 'package:get/get_navigation/src/root/internacionalization.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys =>
      {
        'en': {
          'app_title': 'Vehicle Handover System',
          'login': 'Login',
          'dashboard': 'Dashboard',
          'quick_stats': 'Quick Stats',
          'search_and_filter': 'Search & Filter',
          'drivers': 'Drivers',
          'email': 'Email',
          'email_hint': 'driver1@carhandover.com',
          'email_required': 'Please enter your email',
          'email_invalid': 'Please enter a valid email',
          'password': 'Password',
          'password_required': 'Please enter your password',
          'or': 'OR',
          'forgot_password': 'Forgot Password?',
          'reminder': 'Reminder',
          'contact_admin_for_password': 'Please contact administration to reset your password',

          // النصوص الجديدة
          'welcome': 'Welcome',
          'total': 'Total',
          'pending': 'Pending',
          'in_progress': 'In Progress',
          'completed': 'Completed',
          'search_orders': 'Search orders...',
          'all': 'All',
          'order_list': 'Order List',
          'view': 'View',
          'start': 'Start',
          'delete': 'Delete',
          'add_signature': 'Add Signature',
          'send_email': 'Send Email',
          'complete_order': 'Complete Order',
          'order_report': 'Order Report',
          'report': 'Report',

          'view_details': 'View Details',
          'new_order': 'New Order',
          'logout': 'Logout',
          'logout_confirmation': 'Are you sure you want to logout?',
          'start_order': 'Start Order',
          'start_order_confirmation': 'Are you sure you want to start order?',
          'order_will_change': 'Order status will change to "In Progress".',
          'missing_requirements': 'Missing Requirements',
          'complete_order_confirmation': 'Complete Order',
          'are_you_sure_complete': 'Are you sure you want to complete order?',
          'all_requirements_met': '✓ All requirements met:',
          'photos_added': '• Photos added',
          'driver_signature_added': '• Driver signature added',
          'customer_signature_added': '• Customer signature added',
          'order_completed': 'Order Completed',
          'order_completed_success': 'Order completed successfully',
          'loading_orders': 'Loading orders...',
          'no_orders': 'No orders',
          'create_first_order': 'Start by creating your first order',
          'license_plate': 'License Plate',
          'service_type': 'Service Type',

          'confirm_completion': 'Are you sure you want to complete order?',
          'driver_sign_added': '• Driver signature added',
          'customer_sign_added': '• Customer signature added',
          'cancel': 'Cancel',

          'processing': 'Starting execution...',
          'order_started': 'Execution Started',
          'order_started_message': 'Order has started execution',
          'error': 'Error',
          'order_start_failed': 'Failed to start order',

          'january': 'January',
          'february': 'February',
          'march': 'March',
          'april': 'April',
          'may': 'May',
          'june': 'June',
          'july': 'July',
          'august': 'August',
          'september': 'September',
          'october': 'October',
          'november': 'November',
          'december': 'December',

          'add_vehicle_photos': 'Add vehicle photos',
          'driver_signature': 'Driver signature',
          'customer_signature': 'Customer signature',
          'ok': 'OK',
          'completing_order': 'Completing order...',
          'error_in_complete_order': 'Error in completeOrder',
          'unexpected_error': 'Unexpected error: {error}',
          'order_completion_failed': 'Failed to complete order: {error}',

          'order_details': 'Order Details',
          'edit_details': 'Edit Details',
          'delete_order': 'Delete Order',
          'start_execution': 'Start Execution',
          'alert': 'Alert',
          'operation_in_progress': 'There is an operation in progress. Do you want to exit?',
          'stay': 'Stay',
          'exit': 'Exit',
          'loading_order_details': 'Loading order details...',
          'order_progress': 'Order Progress',
          'completion_percentage': 'Completion Percentage',
          'order_requirements': 'Order Requirements',
          'all_requirements_met_ready': 'All requirements met - Order ready for completion',
          'basic_information': 'Basic Information',
          'client': 'Client',
          'phone': 'Phone',
          'vehicle_owner': 'Vehicle Owner',
          'not_specified': 'Not specified',
          'description': 'Description',
          'comments': 'Comments',
          'addresses': 'Addresses',
          'pickup_address': 'Pickup Address',
          'delivery_address': 'Delivery Address',
          'images': 'Images',
          'no_images_added': 'No images added',
          'click_to_upload': 'Click the button to upload images',
          'failed_to_load_image': 'Failed to load image',
          'signatures': 'Signatures',
          'not_signed_yet': 'Not signed yet',
          'signed_at': 'Signed at: {date}',
          'expenses': 'Expenses',
          'no_expenses_added': 'No expenses added',
          'click_to_add_expenses': 'Click the button to add expenses',
          'fuel': 'Fuel',
          'vehicle_wash': 'Vehicle Wash',
          'other_expenses': 'Other Expenses',
          'notes': 'Notes',
          'edit': 'Edit',
          'add_image': 'Add Image',
          'add_expenses': 'Add Expenses',
          'pickup': 'Pickup',
          'delivery': 'Delivery',
          'additional': 'Additional',
          'damage': 'Damage',
          'interior': 'Interior',
          'exterior': 'Exterior',
          'error_handling_exit': 'Error handling exit: {error}',
          'error_updating_dashboard': 'Error updating dashboard before exit: {error}',

          // Expenses Page Terms - المصطلحات الجديدة لصفحة المصاريف
          'edit_expenses': 'Edit Expenses',
          'add_expenses_title': 'Add Expenses',
          'order_label': 'Order:',
          'update_expenses': 'Update Expenses',
          'add_new_expenses': 'Add New Expenses',
          'enter_all_expenses_desc': 'Enter all expenses related to this order',
          'expenses_details': 'Expenses Details',
          'fuel_cost': 'Fuel Cost',
          'vehicle_wash_cost': 'Vehicle Wash Cost',
          'adblue_cost': 'AdBlue Cost',
          'other_expenses_cost': 'Other Expenses',
          'additional_notes': 'Additional Notes',
          'add_expense_notes_hint': 'Add any notes about expenses (optional)...',
          'expenses_summary': 'Expenses Summary',
          'total_amount': 'Total',
          'amount_cannot_be_negative': 'Amount cannot be negative',
          'saving': 'Saving...',
          'update_expenses_btn': 'Update Expenses',
          'save_expenses_btn': 'Save Expenses',
          'warning': 'Warning',
          'must_enter_amount_greater_zero': 'You must enter an amount greater than zero',
          'success_saved': '✅ Success',
          'expenses_updated_successfully': 'Expenses updated successfully',
          'expenses_saved_successfully': 'Expenses saved successfully',
          'error_occurred': '❌ Error',
          'failed_to_save_expenses': 'Failed to save expenses: {error}',
          'fuel_label': 'Fuel',
          'vehicle_wash_label': 'Vehicle Wash',
          'adblue_label': 'AdBlue',
          'other_label': 'Other Expenses',


          // Edit Order Page Terms - مصطلحات صفحة تعديل الطلب
          'edit_order': 'Edit Order',
          'modified': 'Modified',
          'save_changes': 'Save Changes',
          'save_changes_tooltip': 'Save Changes',
          'client_data': 'Client Data',
          'vehicle_data': 'Vehicle Data',
          'client_info': 'Client Information',
          'client_name': 'Client Name',
          'client_name_required': 'Client name is required',
          'phone_number': 'Phone Number',
          'email_address': 'Email Address',
          'order_description': 'Order Description',
          'order_description_required': 'Order description is required',
          'owner_vehicle_info': 'Owner and Vehicle Information',
          'vehicle_owner_required': 'Vehicle owner is required',
          'license_plate_required': 'License plate is required',
          'street': 'Street',
          'street_required': 'Street is required',
          'house_number': 'House Number',
          'house_number_required': 'House number is required',
          'postal_code': 'Postal Code',
          'postal_code_required': 'Postal code is required',
          'city': 'City',
          'city_required': 'City is required',
          'starting_save_process': '🔄 Starting save process...',
          'changes_saved': 'Changes saved',
          'failed_to_save_changes': 'Failed to save changes',
          'error_occurred_while_saving': 'An error occurred while saving',
          'request_timeout': '⏰ Request timeout',
          'save_error': '❌ Save error: {error}',
          'transport': 'Transport',
          'wash': 'Wash',
          'registration': 'Registration',
          'inspection': 'Inspection',
          'maintenance': 'Maintenance',

          // Image Category Dialog Terms - مصطلحات حوار فئات الصور
          'select_image_category': 'Select Image Category',
          'image_description_optional': 'Image Description (Optional)',
          'enter_image_description': 'Enter image description...',
          'skip': 'Skip',
          'pickup_photos': 'Pickup Photos',
          'delivery_photos': 'Delivery Photos',
          'damage_photos': 'Damage Photos',
          'additional_photos': 'Additional Photos',
          'interior_photos': 'Interior Photos',
          'exterior_photos': 'Exterior Photos',


          // Page Title
          'create_new_order': 'Create New Order',

          // Section Titles


          // Form Fields

          'service_description': 'Service Description',

          // Buttons
          'create_order_btn': 'Create Order',

          // Validation Messages
          'field_required': 'This field is required',
          'service_type_required': 'Please select service type',

          // Information Note
          'important_note': 'Important Note',
          'order_creation_note': 'After creating the order, you can add:\n• Photos and additional details\n• Signatures\n• Expenses\n• Other information as needed',


          // Authentication messages
          'auth_error': 'Authentication Error',
          'access_denied': 'Access Denied: Only drivers can login',
          'login_success': 'Login Successful',
          'welcome_user': 'Welcome {name}',
          'invalid_credentials': 'Invalid email or password',
          'login_error': 'Login error occurred',
          'connection_failed': 'Connection failed. Please check your internet connection',
          'logout_success': 'Logout Successful',
          'logout_completed': 'Successfully logged out',
          'logout_error': 'Logout error occurred',

          // Token and authentication status
          'checking_auth_status': 'Checking authentication status...',
          'token_invalid': 'Invalid token',
          'session_expired': 'Session expired',
          'auth_data_cleared': 'Authentication data cleared',
          'user_data_saved': 'User data saved locally',

          // Role verification
          'driver_access_only': 'Driver access only',
          'role_verification_failed': 'Role verification failed',
          'unauthorized_access': 'Unauthorized access attempt',



          // Order Management
          'order_management': 'Order Management',
          'create_order_success': 'Order Created Successfully',
          'order_number': 'Order Number: {number}',
          'order_updated_success': 'Order Updated Successfully',
          'order_deleted_success': 'Order Deleted Successfully',
          'order_not_found': 'Order not found',
          'order_data_not_returned': 'Order data not returned from server',

          // Order Status Messages
          'status_updated_success': 'Order Status Updated',
          'status_changed_to': 'Order status changed to: {status}',
          'cannot_update_status': 'Cannot update status from {from} to {to}',
          'order_ready_for_completion': 'Order ready for completion',
          'order_completed_success_detailed': 'Order {client} completed successfully',
          'order_started_success': 'Order Execution Started',
          'order_cancelled_success': 'Order Cancelled Successfully',

          // Validation Messages
          'must_login_first': 'Must login first',
          'vehicle_owner_name_required': 'Vehicle owner name is required',
          'vehicle_plate_required': 'Vehicle plate number is required',
          'pickup_address_required': 'Pickup address is required',
          'delivery_address_required': 'Delivery address is required',
          'order_id_required': 'Order ID is required',
          'new_status_required': 'New status is required',
          'order_not_found_locally': 'Order not found locally',

          // Requirements and Completion
          'requirements_for_completion': 'To complete the order, you must add: {requirements}',
          'add_vehicle_photos_req': 'Add vehicle photos',
          'driver_signature_req': 'Driver signature',
          'customer_signature_req': 'Customer signature',
          'add_expenses_req': 'Add expenses',
          'all_requirements_completed': 'All requirements completed, completing order...',

          // Order Actions
          'cannot_edit_current_status': 'Cannot edit this order in current status',
          'can_only_start_pending': 'Can only start orders that are "pending"',
          'cannot_cancel_completed': 'Cannot cancel completed order',
          'order_already_cancelled': 'Order already cancelled',
          'confirm_cancellation': 'Confirm Cancellation',
          'cancel_order_confirmation': 'Are you sure you want to cancel order "{client}"?\n\nOrder status will be changed to "cancelled".',
          'no_continue': 'No, Continue',
          'yes_cancel_order': 'Yes, Cancel Order',

          // Delete Confirmation
          'confirm_delete': 'Confirm Delete',
          'delete_order_confirmation': 'Are you sure you want to delete order "{client}"?',
          'order_deleted_permanently': 'Order will be deleted permanently and cannot be recovered',
          'order_deleted_success_detailed': 'Order "{client}" deleted successfully',

          // Image Management
          'signature_saved_success': 'Signature saved successfully',
          'signature_save_failed': 'Failed to save signature',
          'expenses_added_success': 'Expenses added successfully',
          'expenses_add_failed': 'Failed to add expenses',

          // Filters and Search
          'orders_refreshed': 'Orders Refreshed',
          'orders_list_updated': 'Orders list updated',
          'filter_error': 'Error in filtering orders: {error}',

          // Statistics
          'image_statistics_error': 'Error calculating image statistics: {error}',
          'images_by_category_error': 'Error getting images by category: {error}',
          'image_requirements_error': 'Error checking image requirements: {error}',
          'order_readiness_error': 'Error checking order readiness: {error}',
          'order_not_ready_missing_images': 'Order not ready: missing images',
          'order_not_ready_missing_signatures': 'Order not ready: missing signatures',

          // Connection and Error Messages
          'connection_problem': 'Internet connection problem',
          'connection_timeout': 'Connection timeout, please try again',
          'login_again': 'Please login again',
          'data_not_found': 'Requested data not found',
          'updating_order_from_to': 'Updating order status from {from} to {to}',
          'order_updated_locally': 'Order updated locally',
          'updated_data_not_returned': 'Updated data not returned from server',
          'notifying_controllers_error': 'Error notifying controllers: {error}',
          'refreshing_order': 'Refreshing order: {orderId}',
          'order_updated_dashboard': 'Order updated in dashboard',
          'refresh_order_error': 'Error refreshing order: {error}',

          // Email Report
          'email_report_success': 'Report sent to email successfully',
          'email_report_failed': 'Failed to send report',
          'email_send_error': 'Error occurred while sending email: {error}',

          // Order Editing
          'edit_success': 'Success',
          'order_updated_all_saved': 'Order updated and all changes saved',
          'cannot_edit_order_status': 'Cannot edit this order in current status',

          // Status Display
          'status_cancelled': 'Cancelled',


          // Additional Error Messages
          'failed_to_load_orders': 'Failed to load orders',
          'failed_to_create_order': 'Failed to create order',
          'failed_to_update_order': 'Failed to update order',
          'failed_to_delete_order': 'Failed to delete order',
          'failed_to_update_order_status': 'Failed to update order status',
          'failed_to_complete_order': 'Failed to complete order',
          'failed_to_start_order': 'Failed to start order',
          'failed_to_cancel_order': 'Failed to cancel order',
          'order_update_error': 'Order update error',
          'order_status_update_error': 'Order status update error',
          'order_completion_error': 'Order completion error',
          'order_start_error': 'Order start error',
          'order_cancellation_error': 'Order cancellation error',

          // Additional Helper Text
          'creating_new_order': 'Creating new order',
          'order_created_successfully': 'Order created successfully',
          'updating_order_details': 'Updating order details',
          'order_updated_successfully': 'Order updated successfully',
          'starting_order_update': 'Starting order update',
          'incoming_data': 'Incoming data',
          'sending_data_to_server': 'Sending data to server',
          'final_data': 'Final data',
          'all_changes_saved': 'All changes saved',
          'updating_details_controller': 'Updating details controller',
          'checking_completion_requirements': 'Checking completion requirements',
          'get_orders_by_status_error': 'Error getting orders by status',
          'get_recent_orders_error': 'Error getting recent orders',
          'close': 'Close',
          'success': 'Success',


          // Delete confirmations
          'confirm_delete_image': 'Confirm Image Deletion',
          'confirm_delete_image_message': 'Are you sure you want to delete this image?',
          'confirm_delete_signature': 'Confirm Signature Deletion',
          'confirm_delete_signature_message': 'Are you sure you want to delete the {signerType} signature?',
          'driver': 'driver',
          'customer': 'customer',
          'image_deleted_success': 'Image deleted successfully',
          'signature_deleted_success': 'Signature deleted successfully',
          'failed_delete_image': 'Failed to delete image',
          'failed_delete_signature': 'Failed to delete signature',

          // Image upload messages
          'uploading_images': 'Uploading {count} images for order: {orderId}',
          'images_uploaded_success': '{uploaded} of {total} images uploaded successfully',
          'failed_upload_images': 'Failed to upload images',
          'image_upload_error': 'Error uploading images: {error}',
          'select_images_error': 'Error selecting images: {error}',

          // Signature messages
          'uploading_signature': 'Uploading signature for order: {orderId}',
          'signature_upload_error': 'Error uploading signature: {error}',

          // Expenses messages
          'updating_expenses_for_order': 'Updating expenses for order: {orderId}',
          'incoming_expenses_data': 'Incoming expenses data: {data}',
          'expenses_update_error': 'Error updating expenses: {error}',
          'uploading_expenses_for_order': 'Uploading expenses for order: {orderId}',
          'expenses_upload_error': 'Error uploading expenses: {error}',

          // Order completion
          'starting_order_completion': 'Starting order completion...',
          'cannot_complete_missing_requirements': 'Cannot complete order - missing requirements',
          'missing_requirements_list': 'Missing requirements: {requirements}',
          'completion_confirmed': 'Completion confirmed for order {client}',
          'order_completion_process_started': 'Order completion process started',
          'order_completion_success_with_client': 'Order for {client} completed successfully',
          'order_completion_process_error': 'Error in order completion process: {error}',
          'general_completion_error': 'General error in order completion: {error}',

          // Order editing
          'opening_edit_page': 'Opening order edit page: {orderId}',
          'order_data_for_editing': 'Order data for editing: {fields}',
          'edit_completed_successfully': 'Edit completed successfully, reloading data',
          'edit_result': 'Edit result: {result}',
          'error_opening_edit_page': 'Error opening order edit page: {error}',
          'cannot_edit_no_data': 'Cannot edit order - data not available',
          'error_converting_order_json': 'Error converting order to JSON: {error}',
          'edit_cancelled': 'Edit cancelled',

          // Order status updates
          'notifying_dashboard_update': 'Updating dashboard data after order status update',
          'error_notifying_dashboard': 'Error notifying dashboard of update: {error}',
          'updating_order_status_server': 'Failed to update order status on server',

          // Controller lifecycle
          'controller_disposed': 'OrderDetailsController disposed and cleaned up',
          'preventing_execution_disposed': 'Preventing execution - controller disposed',
          'order_already_loaded': 'Order already loaded',
          'starting_order_initialization': 'Starting order initialization: {orderId}',
          'error_loading_order_details': 'Error loading order details: {error}',
          'loading_failed': 'Loading failed',

          // Menu actions
          'mark_in_progress': 'Mark In Progress',

          // Image categories
          'select_category_for_images': 'Select category for images',
          'image_category_required': 'Image category is required',

          // Additional validation
          'order_data_unavailable': 'Order data unavailable',
          'edit_error_title': 'Edit Error',
          'could_not_open_edit_page': 'Could not open edit page: {error}',

          // Success messages with details
          'expenses_total_amount': 'Total: €{amount}',
          'signature_type_saved': '{type} signature saved',

          // Loading states
          'initializing_order': 'Initializing order: {orderId}',
          'order_initialization_complete': 'Order initialization complete',
          'reloading_order_data': 'Reloading order data',


          'signature_page': 'Signature',
          'signer_name': 'Signer Name',
          'please_sign_below': 'Please sign in the space below',
          'clear_signature': 'Clear',
          'save_signature': 'Save Signature',
          'signature_error': 'Error',
          'enter_signer_name': 'Please enter signer name',
          'add_signature_first': 'Please add signature first',
          'signature_conversion_failed': 'Failed to convert signature',
          'signature_save_failed_error': 'Failed to save signature: {error}',

        },
        'ar': {
          'app_title': 'نظام تسليم واستلام المركبات',
          'login': 'تسجيل الدخول',
          'dashboard': 'لوحة التحكم',
          'quick_stats': 'إحصائيات سريعة',
          'search_and_filter': 'البحث والتصفية',
          'drivers': 'السائقين',
          'email': 'البريد',
          'email_hint': 'driver1@carhandover.com',
          'email_required': 'يرجى إدخال البريد الإلكتروني',
          'email_invalid': 'يرجى إدخال بريد إلكتروني صحيح',
          'password': 'كلمة المرور',
          'password_required': 'يرجى إدخال كلمة المرور',
          'or': 'أو',
          'forgot_password': 'نسيت كلمة المرور؟',
          'reminder': 'تذكير',
          'contact_admin_for_password': 'يرجى التواصل مع الإدارة لاستعادة كلمة المرور',

          'welcome': 'مرحباً',
          'total': 'المجموع',
          'pending': 'قيد الانتظار',
          'in_progress': 'قيد التنفيذ',
          'completed': 'مكتملة',
          'search_orders': 'البحث في الطلبات...',
          'all': 'الكل',
          'order_list': 'قائمة الطلبات',
          'view': 'عرض',
          'start': 'بدء',
          'delete': 'حذف',
          'add_signature': 'إضافة توقيع',
          'send_email': 'إرسال بريد',
          'complete_order': 'إتمام الطلب',
          'order_report': 'تقرير الطلب',
          'report': 'تقرير',

          'view_details': 'عرض التفاصيل',
          'new_order': 'طلب جديد',
          'logout': 'تسجيل الخروج',
          'logout_confirmation': 'هل أنت متأكد من تسجيل الخروج؟',
          'start_order': 'بدء الطلب',
          'start_order_confirmation': 'هل أنت متأكد من بدء طلب ؟',
          'order_will_change': 'سيتم تغيير حالة الطلب إلى "قيد التنفيذ".',
          'missing_requirements': 'متطلبات ناقصة',
          'complete_order_confirmation': 'إتمام الطلب',
          'are_you_sure_complete': 'هل أنت متأكد من إتمام طلب؟',
          'all_requirements_met': '✓ جميع المتطلبات مكتملة:',
          'photos_added': '• الصور مضافة',
          'driver_signature_added': '• توقيع السائق مضاف',
          'customer_signature_added': '• توقيع العميل مضاف',
          'order_completed': 'تم إتمام الطلب',
          'order_completed_success': 'تم إتمام طلب بنجاح',
          'loading_orders': 'جارٍ تحميل الطلبات...',
          'no_orders': 'لا توجد طلبات',
          'create_first_order': 'ابدأ بإنشاء أول طلب لك',
          'license_plate': 'رقم اللوحة',
          'service_type': 'نوع الخدمة',

          'confirm_completion': 'هل أنت متأكد من إتمام طلب؟',
          'driver_sign_added': '• توقيع السائق مضاف',
          'customer_sign_added': '• توقيع العميل مضاف',
          'cancel': 'إلغاء',

          'processing': 'جارٍ بدء التنفيذ...',
          'order_started': 'تم بدء التنفيذ',
          'order_started_message': 'تم بدء تنفيذ طلب',
          'error': 'خطأ',
          'order_start_failed': 'فشل في بدء تنفيذ الطلب',

          'january': 'يناير',
          'february': 'فبراير',
          'march': 'مارس',
          'april': 'أبريل',
          'may': 'مايو',
          'june': 'يونيو',
          'july': 'يوليو',
          'august': 'أغسطس',
          'september': 'سبتمبر',
          'october': 'أكتوبر',
          'november': 'نوفمبر',
          'december': 'ديسمبر',

          'add_vehicle_photos': 'إضافة صور للمركبة',
          'driver_signature': 'توقيع السائق',
          'customer_signature': 'توقيع العميل',
          'ok': 'حسناً',
          'completing_order': 'جارٍ إتمام الطلب...',
          'error_in_complete_order': 'خطأ في _completeOrder',
          'unexpected_error': 'حدث خطأ غير متوقع: {error}',
          'order_completion_failed': 'فشل في إتمام الطلب: {error}',

          'order_details': 'تفاصيل الطلب',
          'edit_details': 'تحرير التفاصيل',
          'delete_order': 'حذف الطلب',
          'start_execution': 'بدء التنفيذ',
          'alert': 'تنبيه',
          'operation_in_progress': 'يوجد عملية جارية. هل تريد الخروج؟',
          'stay': 'البقاء',
          'exit': 'الخروج',
          'loading_order_details': 'جارٍ تحميل تفاصيل الطلب...',
          'order_progress': 'تقدم الطلب',
          'completion_percentage': 'نسبة الإنجاز',
          'order_requirements': 'متطلبات الطلب',
          'all_requirements_met_ready': 'جميع المتطلبات مكتملة - الطلب جاهز للإتمام',
          'basic_information': 'المعلومات الأساسية',
          'client': 'العميل',
          'phone': 'الهاتف',
          'vehicle_owner': 'مالك المركبة',
          'not_specified': 'غير محدد',
          'description': 'الوصف',
          'comments': 'التعليقات',
          'addresses': 'العناوين',
          'pickup_address': 'عنوان الاستلام',
          'delivery_address': 'عنوان التسليم',
          'images': 'الصور',
          'no_images_added': 'لا توجد صور مضافة',
          'click_to_upload': 'انقر على الزر لرفع الصور',
          'failed_to_load_image': 'فشل في تحميل الصورة',
          'signatures': 'التوقيعات',
          'not_signed_yet': 'لم يتم التوقيع بعد',
          'signed_at': 'تم التوقيع: {date}',
          'expenses': 'المصاريف',
          'no_expenses_added': 'لم يتم إضافة المصاريف',
          'click_to_add_expenses': 'انقر على الزر لإضافة المصاريف',
          'fuel': 'الوقود',
          'vehicle_wash': 'غسيل المركبة',
          'other_expenses': 'مصاريف أخرى',
          'notes': 'ملاحظات',
          'edit': 'تحرير',
          'add_image': 'إضافة صورة',
          'add_expenses': 'إضافة مصاريف',
          'pickup': 'استلام',
          'delivery': 'تسليم',
          'additional': 'إضافية',
          'damage': 'أضرار',
          'interior': 'داخلية',
          'exterior': 'خارجية',
          'error_handling_exit': 'خطأ في التعامل مع الخروج: {error}',
          'error_updating_dashboard': 'خطأ في تحديث الداشبورد قبل الخروج: {error}',

          // Expenses Page Terms - المصطلحات الجديدة لصفحة المصاريف
          'edit_expenses': 'تعديل المصاريف',
          'add_expenses_title': 'إضافة مصاريف',
          'order_label': 'طلبية:',
          'update_expenses': 'تحديث المصاريف',
          'add_new_expenses': 'إضافة مصاريف جديدة',
          'enter_all_expenses_desc': 'أدخل جميع المصاريف المرتبطة بهذا الطلب',
          'expenses_details': 'تفاصيل المصاريف',
          'fuel_cost': 'تكلفة الوقود',
          'vehicle_wash_cost': 'تكلفة غسيل المركبة',
          'adblue_cost': 'تكلفة AdBlue',
          'other_expenses_cost': 'مصاريف أخرى',
          'additional_notes': 'ملاحظات إضافية',
          'add_expense_notes_hint': 'أضف أي ملاحظات حول المصاريف (اختياري)...',
          'expenses_summary': 'ملخص المصاريف',
          'total_amount': 'الإجمالي',
          'amount_cannot_be_negative': 'المبلغ لا يمكن أن يكون سالباً',
          'saving': 'جاري الحفظ...',
          'update_expenses_btn': 'تحديث المصاريف',
          'save_expenses_btn': 'حفظ المصاريف',
          'warning': 'تنبيه',
          'must_enter_amount_greater_zero': 'يجب إدخال مبلغ أكبر من الصفر',
          'success_saved': '✅ تم بنجاح',
          'expenses_updated_successfully': 'تم تحديث المصاريف بنجاح',
          'expenses_saved_successfully': 'تم حفظ المصاريف بنجاح',
          'error_occurred': '❌ خطأ',
          'failed_to_save_expenses': 'فشل في حفظ المصاريف: {error}',
          'fuel_label': 'الوقود',
          'vehicle_wash_label': 'غسيل المركبة',
          'adblue_label': 'AdBlue',
          'other_label': 'مصاريف أخرى',


          // Edit Order Page Terms - مصطلحات صفحة تعديل الطلب
          'edit_order': 'تعديل الطلب',
          'modified': 'معدل',
          'save_changes': 'حفظ التعديلات',
          'save_changes_tooltip': 'حفظ التعديلات',
          'client_data': 'بيانات العميل',
          'vehicle_data': 'بيانات المركبة',
          'client_info': 'معلومات العميل',
          'client_name': 'اسم العميل',
          'client_name_required': 'اسم العميل مطلوب',
          'phone_number': 'رقم الهاتف',
          'email_address': 'البريد الإلكتروني',
          'order_description': 'وصف الطلب',
          'order_description_required': 'وصف الطلب مطلوب',
          'owner_vehicle_info': 'معلومات المالك والمركبة',
          'vehicle_owner_required': 'مالك المركبة مطلوب',
          'license_plate_required': 'رقم اللوحة مطلوب',
          'street': 'الشارع',
          'street_required': 'الشارع مطلوب',
          'house_number': 'رقم المنزل',
          'house_number_required': 'رقم المنزل مطلوب',
          'postal_code': 'الرمز البريدي',
          'postal_code_required': 'الرمز البريدي مطلوب',
          'city': 'المدينة',
          'city_required': 'المدينة مطلوبة',
          'starting_save_process': '🔄 بدء عملية حفظ التعديلات...',
          'changes_saved': 'تم حفظ التعديلات',
          'failed_to_save_changes': 'فشل في حفظ التعديلات',
          'error_occurred_while_saving': 'حدث خطأ أثناء الحفظ',
          'request_timeout': '⏰ انتهت مهلة الطلب',
          'save_error': '❌ خطأ في الحفظ: {error}',
          'transport': 'نقل',
          'wash': 'غسيل',
          'registration': 'تسجيل',
          'inspection': 'فحص',
          'maintenance': 'صيانة',

          // Image Category Dialog Terms - مصطلحات حوار فئات الصور
          'select_image_category': 'اختر فئة الصور',
          'image_description_optional': 'وصف الصور (اختياري)',
          'enter_image_description': 'أدخل وصف للصور...',
          'skip': 'تخطي',
          'pickup_photos': 'صور الاستلام',
          'delivery_photos': 'صور التسليم',
          'damage_photos': 'صور الأضرار',
          'additional_photos': 'صور إضافية',
          'interior_photos': 'صور داخلية',
          'exterior_photos': 'صور خارجية',



          // Page Title
          'create_new_order': 'إنشاء طلب جديد',




          'service_description': 'وصف الخدمة',

          // Buttons
          'create_order_btn': 'إنشاء الطلب',

          // Validation Messages
          'field_required': 'هذا الحقل مطلوب',
          'service_type_required': 'يرجى اختيار نوع الخدمة',

          // Information Note
          'important_note': 'ملاحظة مهمة',
          'order_creation_note': 'بعد إنشاء الطلب، يمكنك إضافة:\n• الصور والتفاصيل الإضافية\n• التوقيعات\n• المصاريف\n• معلومات أخرى حسب الحاجة',


          // رسائل المصادقة
          'auth_error': 'خطأ في المصادقة',
          'access_denied': 'غير مسموح: يمكن للسائقين فقط تسجيل الدخول',
          'login_success': 'نجح تسجيل الدخول',
          'welcome_user': 'مرحباً {name}',
          'invalid_credentials': 'البريد الإلكتروني أو كلمة المرور غير صحيحة',
          'login_error': 'حدث خطأ أثناء تسجيل الدخول',
          'connection_failed': 'فشل في الاتصال بالخادم. تحقق من الاتصال بالإنترنت',
          'logout_success': 'تم تسجيل الخروج',
          'logout_completed': 'تم تسجيل الخروج بنجاح',
          'logout_error': 'حدث خطأ أثناء تسجيل الخروج',

          // التوكن وحالة المصادقة
          'checking_auth_status': 'جارٍ فحص حالة المصادقة...',
          'token_invalid': 'التوكن غير صالح',
          'session_expired': 'انتهت صلاحية الجلسة',
          'auth_data_cleared': 'تم مسح بيانات المصادقة',
          'user_data_saved': 'تم حفظ بيانات المستخدم محلياً',

          // التحقق من الدور
          'driver_access_only': 'وصول السائقين فقط',
          'role_verification_failed': 'فشل في التحقق من الدور',
          'unauthorized_access': 'محاولة وصول غير مصرح بها',


          // إدارة الطلبات
          'order_management': 'إدارة الطلبات',
          'create_order_success': 'تم إنشاء الطلب بنجاح',
          'order_number': 'رقم الطلب: {number}',
          'order_updated_success': 'تم تحديث الطلب بنجاح',
          'order_deleted_success': 'تم حذف الطلب بنجاح',
          'order_not_found': 'الطلب غير موجود',
          'order_data_not_returned': 'لم يتم إرجاع بيانات الطلبية من الخادم',

          // رسائل حالة الطلب
          'status_updated_success': 'تم تحديث حالة الطلب',
          'status_changed_to': 'تم تغيير حالة الطلب إلى: {status}',
          'cannot_update_status': 'لا يمكن تحديث الحالة من {from} إلى {to}',
          'order_ready_for_completion': 'الطلب جاهز للإتمام',
          'order_completed_success_detailed': 'تم إتمام طلب {client} بنجاح',
          'order_started_success': 'تم بدء تنفيذ الطلب',
          'order_cancelled_success': 'تم إلغاء الطلب بنجاح',

          // رسائل التحقق
          'must_login_first': 'يجب تسجيل الدخول أولاً',
          'vehicle_owner_name_required': 'اسم مالك المركبة مطلوب',
          'vehicle_plate_required': 'رقم لوحة المركبة مطلوب',
          'pickup_address_required': 'عنوان الاستلام مطلوب',
          'delivery_address_required': 'عنوان التسليم مطلوب',
          'order_id_required': 'معرف الطلبية مطلوب',
          'new_status_required': 'الحالة الجديدة مطلوبة',
          'order_not_found_locally': 'الطلبية غير موجودة محلياً',

          // المتطلبات والإتمام
          'requirements_for_completion': 'لإتمام الطلب، يجب إضافة: {requirements}',
          'add_vehicle_photos_req': 'إضافة صور للمركبة',
          'driver_signature_req': 'توقيع السائق',
          'customer_signature_req': 'توقيع العميل',
          'add_expenses_req': 'إضافة المصاريف',
          'all_requirements_completed': 'جميع المتطلبات مكتملة، جارٍ إتمام الطلبية...',

          // إجراءات الطلب
          'cannot_edit_current_status': 'لا يمكن تعديل هذا الطلب في الحالة الحالية',
          'can_only_start_pending': 'يمكن بدء الطلبيات التي في حالة "قيد الانتظار" فقط',
          'cannot_cancel_completed': 'لا يمكن إلغاء طلب مكتمل',
          'order_already_cancelled': 'الطلب ملغي بالفعل',
          'confirm_cancellation': 'تأكيد الإلغاء',
          'cancel_order_confirmation': 'هل أنت متأكد من إلغاء طلب "{client}"؟\n\nسيتم تغيير حالة الطلب إلى "ملغي".',
          'no_continue': 'لا، استمر',
          'yes_cancel_order': 'نعم، ألغ الطلب',

          // تأكيد الحذف
          'confirm_delete': 'تأكيد الحذف',
          'delete_order_confirmation': 'هل أنت متأكد من حذف طلب "{client}"؟',
          'order_deleted_permanently': 'سيتم حذف الطلب نهائياً ولا يمكن استرجاعه',
          'order_deleted_success_detailed': 'تم حذف الطلب "{client}"',

          // إدارة الصور
          'signature_saved_success': 'تم حفظ التوقيع بنجاح',
          'signature_save_failed': 'فشل في حفظ التوقيع',
          'expenses_added_success': 'تم إضافة المصاريف بنجاح',
          'expenses_add_failed': 'فشل في إضافة المصاريف',

          // التصفية والبحث
          'orders_refreshed': 'تم التحديث',
          'orders_list_updated': 'تم تحديث قائمة الطلبيات',
          'filter_error': 'خطأ في تصفية الطلبيات: {error}',

          // الإحصائيات
          'image_statistics_error': 'خطأ في حساب إحصائيات الصور: {error}',
          'images_by_category_error': 'خطأ في جلب الصور حسب الفئة: {error}',
          'image_requirements_error': 'خطأ في فحص متطلبات الصور: {error}',
          'order_readiness_error': 'خطأ في فحص جاهزية الطلبية: {error}',
          'order_not_ready_missing_images': 'الطلبية غير جاهزة: صور ناقصة',
          'order_not_ready_missing_signatures': 'الطلبية غير جاهزة: توقيعات ناقصة',

          // رسائل الاتصال والأخطاء
          'connection_problem': 'مشكلة في الاتصال بالإنترنت',
          'connection_timeout': 'انتهت مهلة الاتصال، يرجى المحاولة مرة أخرى',
          'login_again': 'يرجى تسجيل الدخول مرة أخرى',
          'data_not_found': 'البيانات المطلوبة غير موجودة',
          'updating_order_from_to': 'تحديث حالة الطلبية من {from} إلى {to}',
          'order_updated_locally': 'تم تحديث الطلبية محلياً',
          'updated_data_not_returned': 'لم يتم إرجاع بيانات محدثة من الخادم',
          'notifying_controllers_error': 'خطأ في إشعار الكونترولرز: {error}',
          'refreshing_order': 'إعادة تحميل الطلب: {orderId}',
          'order_updated_dashboard': 'تم تحديث الطلب في الداشبورد',
          'refresh_order_error': 'خطأ في إعادة تحميل الطلب: {error}',

          // تقرير البريد الإلكتروني
          'email_report_success': 'تم إرسال التقرير إلى البريد الإلكتروني',
          'email_report_failed': 'فشل في إرسال التقرير',
          'email_send_error': 'حدث خطأ أثناء إرسال البريد: {error}',

          // تحرير الطلب
          'edit_success': 'تم بنجاح',
          'order_updated_all_saved': 'تم تحديث الطلب وحفظ جميع التعديلات',
          'cannot_edit_order_status': 'لا يمكن تعديل هذا الطلب في الحالة الحالية',

          // عرض الحالة
          'status_cancelled': 'ملغي',


          // نصوص مساعدة إضافية
          'creating_new_order': 'إنشاء طلب جديد',
          'order_created_successfully': 'تم إنشاء الطلب بنجاح',
          'updating_order_details': 'تحديث تفاصيل الطلب',
          'order_updated_successfully': 'تم تحديث الطلب بنجاح',
          'starting_order_update': 'بدء تحديث الطلب',
          'incoming_data': 'البيانات الواردة',
          'sending_data_to_server': 'إرسال البيانات للخادم',
          'final_data': 'البيانات النهائية',
          'all_changes_saved': 'تم حفظ جميع التعديلات',
          'updating_details_controller': 'تحديث كونترولر التفاصيل',
          'checking_completion_requirements': 'فحص متطلبات الإتمام',
          'get_orders_by_status_error': 'خطأ في جلب الطلبات حسب الحالة',
          'get_recent_orders_error': 'خطأ في جلب الطلبات الحديثة',
          'close': 'إغلاق',
          'success': 'نجاح',


          // تأكيدات الحذف
          'confirm_delete_image': 'تأكيد حذف الصورة',
          'confirm_delete_image_message': 'هل أنت متأكد من حذف هذه الصورة؟',
          'confirm_delete_signature': 'تأكيد حذف التوقيع',
          'confirm_delete_signature_message': 'هل أنت متأكد من حذف توقيع {signerType}؟',
          'driver': 'السائق',
          'customer': 'العميل',
          'image_deleted_success': 'تم حذف الصورة بنجاح',
          'signature_deleted_success': 'تم حذف التوقيع بنجاح',
          'failed_delete_image': 'فشل في حذف الصورة',
          'failed_delete_signature': 'فشل في حذف التوقيع',

          // رسائل رفع الصور
          'uploading_images': 'رفع {count} صورة للطلبية: {orderId}',
          'images_uploaded_success': 'تم رفع {uploaded} من {total} صورة بنجاح',
          'failed_upload_images': 'فشل في رفع الصور',
          'image_upload_error': 'خطأ في رفع الصور: {error}',
          'select_images_error': 'خطأ في اختيار الصور: {error}',

          // رسائل التوقيع
          'uploading_signature': 'رفع توقيع للطلبية: {orderId}',
          'signature_upload_error': 'خطأ في رفع التوقيع: {error}',

          // رسائل المصاريف
          'updating_expenses_for_order': 'تحديث مصاريف الطلبية: {orderId}',
          'incoming_expenses_data': 'البيانات الواردة للمصاريف: {data}',
          'expenses_update_error': 'خطأ في تحديث المصاريف: {error}',
          'uploading_expenses_for_order': 'رفع مصاريف للطلبية: {orderId}',
          'expenses_upload_error': 'خطأ في رفع المصاريف: {error}',

          // إتمام الطلب
          'starting_order_completion': 'بدء إتمام الطلب...',
          'cannot_complete_missing_requirements': 'لا يمكن إتمام الطلب - متطلبات ناقصة',
          'missing_requirements_list': 'المتطلبات المفقودة: {requirements}',
          'completion_confirmed': 'تم تأكيد إتمام طلب {client}',
          'order_completion_process_started': 'تم بدء عملية إتمام الطلب',
          'order_completion_success_with_client': 'تم إتمام طلب {client} بنجاح',
          'order_completion_process_error': 'خطأ في عملية إتمام الطلب: {error}',
          'general_completion_error': 'خطأ عام في إتمام الطلب: {error}',

          // تحرير الطلب
          'opening_edit_page': 'فتح صفحة تحرير الطلب: {orderId}',
          'order_data_for_editing': 'بيانات الطلب للتحرير: {fields}',
          'edit_completed_successfully': 'تم التحرير بنجاح، إعادة تحميل البيانات',
          'edit_result': 'نتيجة التحرير: {result}',
          'error_opening_edit_page': 'خطأ في فتح صفحة تحرير الطلب: {error}',
          'cannot_edit_no_data': 'لا يمكن تحرير الطلب - البيانات غير متوفرة',
          'error_converting_order_json': 'خطأ في تحويل الطلب إلى JSON: {error}',
          'edit_cancelled': 'تم إلغاء التحرير',

          // تحديثات حالة الطلب
          'notifying_dashboard_update': 'تحديث بيانات الداشبورد بعد تحديث حالة الطلب',
          'error_notifying_dashboard': 'خطأ في إشعار الداشبورد بالتحديث: {error}',
          'updating_order_status_server': 'فشل في تحديث حالة الطلب على الخادم',

          // دورة حياة الكونترولر
          'controller_disposed': 'تم تنظيف OrderDetailsController',
          'preventing_execution_disposed': 'منع التنفيذ - تم التخلص من الكونترولر',
          'order_already_loaded': 'الطلب محمل مسبقاً',
          'starting_order_initialization': 'بدء تهيئة الطلب: {orderId}',
          'error_loading_order_details': 'خطأ في تحميل تفاصيل الطلب: {error}',
          'loading_failed': 'فشل في التحميل',

          // إجراءات القائمة
          'mark_in_progress': 'وضع قيد التنفيذ',

          // فئات الصور
          'select_category_for_images': 'اختر فئة للصور',
          'image_category_required': 'فئة الصور مطلوبة',

          // التحقق الإضافي
          'order_data_unavailable': 'بيانات الطلب غير متوفرة',
          'edit_error_title': 'خطأ في التحرير',
          'could_not_open_edit_page': 'لم يتم فتح صفحة التحرير: {error}',

          // رسائل النجاح مع التفاصيل
          'expenses_total_amount': 'المجموع: €{amount}',
          'signature_type_saved': 'توقيع {type}',

          // حالات التحميل
          'initializing_order': 'تهيئة الطلب: {orderId}',
          'order_initialization_complete': 'اكتملت تهيئة الطلب',
          'reloading_order_data': 'إعادة تحميل بيانات الطلب',


          'signature_page': 'التوقيع',
          'signer_name': 'اسم الموقع',
          'please_sign_below': 'يرجى التوقيع في المساحة أدناه',
          'clear_signature': 'مسح',
          'save_signature': 'حفظ التوقيع',
          'signature_error': 'خطأ',
          'enter_signer_name': 'يرجى إدخال اسم الموقع',
          'add_signature_first': 'يرجى إضافة التوقيع أولاً',
          'signature_conversion_failed': 'فشل في تحويل التوقيع',
          'signature_save_failed_error': 'فشل في حفظ التوقيع: {error}',
        },
        'de': {
          'app_title': 'Fahrzeugübergabesystem',
          'login': 'Anmeldung',
          'dashboard': 'Armaturenbrett',
          'quick_stats': 'Schnelle Statistiken',
          'search_and_filter': 'Suche & Filter',
          'drivers': 'Fahrer',
          'email': 'Email',
          'email_hint': 'fahrer1@autoubergabe.de',
          'email_required': 'Bitte geben Sie ihre E-Mail-Adresse ein',
          'email_invalid': 'Bitte geben Sie eine gültige E-Mail-Adresse ein',
          'password': 'Passwort',
          'password_required': 'Bitte geben Sie Ihr Passwort ein',
          'or': 'ODER',
          'forgot_password': 'Passwort vergessen?',
          'reminder': 'Erinnerung',
          'contact_admin_for_password': 'Bitte wenden Sie sich an die Verwaltung, um Ihr Passwort zurückzusetzen',

          'welcome': 'Willkommen',
          'total': 'Gesamt',
          'pending': 'Ausstehend',
          'in_progress': 'In Bearbeitung',
          'completed': 'Abgeschlossen',
          'search_orders': 'Aufträge suchen...',
          'all': 'Alle',
          'order_list': 'Auftragsliste',
          'view': 'Anzeigen',
          'start': 'Starten',
          'delete': 'Löschen',
          'add_signature': 'Unterschrift hinzufügen',
          'send_email': 'E-Mail senden',
          'complete_order': 'Auftrag abschließen',
          'order_report': 'Auftragsbericht',
          'report': 'Bericht',

          'view_details': 'Details anzeigen',
          'new_order': 'Neuer Auftrag',
          'logout': 'Abmelden',
          'logout_confirmation': 'Möchten Sie sich wirklich abmelden?',
          'start_order': 'Auftrag starten',
          'start_order_confirmation': 'Möchten Sie den Auftrag wirklich starten?',
          'order_will_change': 'Der Auftragsstatus wird auf "In Bearbeitung" geändert.',
          'missing_requirements': 'Fehlende Anforderungen',
          'complete_order_confirmation': 'Auftrag abschließen',
          'are_you_sure_complete': 'Möchten Sie den Auftrag wirklich abschließen?',
          'all_requirements_met': '✓ Alle Anforderungen erfüllt:',
          'photos_added': '• Fotos hinzugefügt',
          'driver_signature_added': '• Fahrerunterschrift hinzugefügt',
          'customer_signature_added': '• Kundenunterschrift hinzugefügt',
          'order_completed': 'Auftrag abgeschlossen',
          'order_completed_success': 'Auftrag erfolgreich abgeschlossen',
          'loading_orders': 'Aufträge werden geladen...',
          'no_orders': 'Keine Aufträge',
          'create_first_order': 'Erstellen Sie Ihren ersten Auftrag',
          'license_plate': 'Kennzeichen',
          'service_type': 'Serviceart',

          'confirm_completion': 'Möchten Sie den Auftrag wirklich abschließen?',
          'driver_sign_added': '• Fahrerunterschrift hinzugefügt',
          'customer_sign_added': '• Kundenunterschrift hinzugefügt',
          'cancel': 'Abbrechen',

          'processing': 'Ausführung wird gestartet...',
          'order_started': 'Ausführung gestartet',
          'order_started_message': 'Auftrag wurde gestartet',
          'error': 'Fehler',
          'order_start_failed': 'Fehler beim Starten des Auftrags',

          'january': 'Januar',
          'february': 'Februar',
          'march': 'März',
          'april': 'April',
          'may': 'Mai',
          'june': 'Juni',
          'july': 'Juli',
          'august': 'August',
          'september': 'September',
          'october': 'Oktober',
          'november': 'November',
          'december': 'Dezember',

          'add_vehicle_photos': 'Fahrzeugfotos hinzufügen',
          'driver_signature': 'Fahrerunterschrift',
          'customer_signature': 'Kundenunterschrift',
          'ok': 'OK',
          'completing_order': 'Auftrag wird abgeschlossen...',
          'error_in_complete_order': 'Fehler in completeOrder',
          'unexpected_error': 'Unerwarteter Fehler: {error}',
          'order_completion_failed': 'Fehler beim Abschließen des Auftrags: {error}',

          'order_details': 'Auftragsdetails',
          'edit_details': 'Details bearbeiten',
          'delete_order': 'Auftrag löschen',
          'start_execution': 'Ausführung starten',
          'alert': 'Warnung',
          'operation_in_progress': 'Es läuft eine Operation. Möchten Sie wirklich beenden?',
          'stay': 'Bleiben',
          'exit': 'Beenden',
          'loading_order_details': 'Auftragsdetails werden geladen...',
          'order_progress': 'Auftragsfortschritt',
          'completion_percentage': 'Fertigstellungsgrad',
          'order_requirements': 'Auftragsanforderungen',
          'all_requirements_met_ready': 'Alle Anforderungen erfüllt - Auftrag bereit zum Abschluss',
          'basic_information': 'Grundinformationen',
          'client': 'Kunde',
          'phone': 'Telefon',
          'vehicle_owner': 'Fahrzeughalter',
          'not_specified': 'Nicht angegeben',
          'description': 'Beschreibung',
          'comments': 'Kommentare',
          'addresses': 'Adressen',
          'pickup_address': 'Abholadresse',
          'delivery_address': 'Zieladresse',
          'images': 'Bilder',
          'no_images_added': 'Keine Bilder hinzugefügt',
          'click_to_upload': 'Zum Hochladen von Bildern klicken',
          'failed_to_load_image': 'Bild konnte nicht geladen werden',
          'signatures': 'Unterschriften',
          'not_signed_yet': 'Noch nicht unterschrieben',
          'signed_at': 'Unterschrieben am: {date}',
          'expenses': 'Auslagen',
          'no_expenses_added': 'Keine Auslagen hinzugefügt',
          'click_to_add_expenses': 'Zum Hinzufügen von Auslagen klicken',
          'fuel': 'Kraftstoff',
          'vehicle_wash': 'Fahrzeugwäsche',
          'other_expenses': 'Andere Auslagen',
          'notes': 'Notizen',
          'edit': 'Bearbeiten',
          'add_image': 'Bild hinzufügen',
          'add_expenses': 'Auslagen hinzufügen',
          'pickup': 'Abholung',
          'delivery': 'Ziel',
          'additional': 'Zusätzlich',
          'damage': 'Schaden',
          'interior': 'Innenraum',
          'exterior': 'Außenbereich',
          'error_handling_exit': 'Fehler beim Behandeln des Beendens: {error}',
          'error_updating_dashboard': 'Fehler beim Aktualisieren des Dashboards vor dem Beenden: {error}',

          // Expenses Page Terms - المصطلحات الجديدة لصفحة المصاريف
          'edit_expenses': 'Auslagen bearbeiten',
          'add_expenses_title': 'Auslagen hinzufügen',
          'order_label': 'Auftrag:',
          'update_expenses': 'Auslagen aktualisieren',
          'add_new_expenses': 'Neue Auslagen hinzufügen',
          'enter_all_expenses_desc': 'Geben Sie alle Auslagen im Zusammenhang mit diesem Auftrag ein',
          'expenses_details': 'Auslagendetails',
          'fuel_cost': 'Kraftstoffkosten',
          'vehicle_wash_cost': 'Fahrzeugwäsche-Kosten',
          'adblue_cost': 'AdBlue-Kosten',
          'other_expenses_cost': 'Andere Auslagen',
          'additional_notes': 'Zusätzliche Notizen',
          'add_expense_notes_hint': 'Fügen Sie Notizen zu den Auslagen hinzu (optional)...',
          'expenses_summary': 'Auslagenübersicht',
          'total_amount': 'Gesamtbetrag',
          'amount_cannot_be_negative': 'Betrag kann nicht negativ sein',
          'saving': 'Speichern...',
          'update_expenses_btn': 'Auslagen aktualisieren',
          'save_expenses_btn': 'Auslagen speichern',
          'warning': 'Warnung',
          'must_enter_amount_greater_zero': 'Sie müssen einen Betrag größer als Null eingeben',
          'success_saved': '✅ Erfolgreich',
          'expenses_updated_successfully': 'Auslagen erfolgreich aktualisiert',
          'expenses_saved_successfully': 'Auslagen erfolgreich gespeichert',
          'error_occurred': '❌ Fehler',
          'failed_to_save_expenses': 'Fehler beim Speichern der Auslagen: {error}',
          'fuel_label': 'Kraftstoff',
          'vehicle_wash_label': 'Fahrzeugwäsche',
          'adblue_label': 'AdBlue',
          'other_label': 'Andere Auslagen',


          // Edit Order Page Terms - مصطلحات صفحة تعديل الطلب
          'edit_order': 'Auftrag bearbeiten',
          'modified': 'Geändert',
          'save_changes': 'Änderungen speichern',
          'save_changes_tooltip': 'Änderungen speichern',
          'client_data': 'Kundendaten',
          'vehicle_data': 'Fahrzeugdaten',
          'client_info': 'Kundeninformationen',
          'client_name': 'Kundenname',
          'client_name_required': 'Kundenname ist erforderlich',
          'phone_number': 'Telefonnummer',
          'email_address': 'E-Mail-Adresse',
          'order_description': 'Auftragsbeschreibung',
          'order_description_required': 'Auftragsbeschreibung ist erforderlich',
          'owner_vehicle_info': 'Halter- und Fahrzeuginformationen',
          'vehicle_owner_required': 'Fahrzeughalter ist erforderlich',
          'license_plate_required': 'Kennzeichen ist erforderlich',
          'street': 'Straße',
          'street_required': 'Straße ist erforderlich',
          'house_number': 'Hausnummer',
          'house_number_required': 'Hausnummer ist erforderlich',
          'postal_code': 'Postleitzahl',
          'postal_code_required': 'Postleitzahl ist erforderlich',
          'city': 'Stadt',
          'city_required': 'Stadt ist erforderlich',
          'starting_save_process': '🔄 Speichervorgang wird gestartet...',
          'changes_saved': 'Änderungen gespeichert',
          'failed_to_save_changes': 'Fehler beim Speichern der Änderungen',
          'error_occurred_while_saving': 'Ein Fehler ist beim Speichern aufgetreten',
          'request_timeout': '⏰ Anfrage-Timeout',
          'save_error': '❌ Speicherfehler: {error}',
          'transport': 'Transport',
          'wash': 'Waschen',
          'registration': 'Registrierung',
          'inspection': 'Inspektion',
          'maintenance': 'Wartung',

          // Image Category Dialog Terms - مصطلحات حوار فئات الصور
          'select_image_category': 'Bildkategorie auswählen',
          'image_description_optional': 'Bildbeschreibung (Optional)',
          'enter_image_description': 'Bildbeschreibung eingeben...',
          'skip': 'Überspringen',
          'pickup_photos': 'Abholungsfotos',
          'delivery_photos': 'Zielfotos',
          'damage_photos': 'Schadenfotos',
          'additional_photos': 'Zusätzliche Fotos',
          'interior_photos': 'Innenraumfotos',
          'exterior_photos': 'Außenbereichsfotos',


          // Page Title
          'create_new_order': 'Neuen Auftrag erstellen',

          // Section Titles

          // Form Fields
          'service_description': 'Servicebeschreibung',

          // Buttons
          'create_order_btn': 'Auftrag erstellen',

          // Validation Messages
          'field_required': 'Dieses Feld ist erforderlich',
          'service_type_required': 'Bitte wählen Sie die Serviceart aus',

          // Information Note
          'important_note': 'Wichtiger Hinweis',
          'order_creation_note': 'Nach der Auftragserstellung können Sie hinzufügen:\n• Fotos und zusätzliche Details\n• Unterschriften\n• Auslagen\n• Weitere Informationen nach Bedarf',


          // Authentifizierungsnachrichten
          'auth_error': 'Authentifizierungsfehler',
          'access_denied': 'Zugriff verweigert: Nur Fahrer können sich anmelden',
          'login_success': 'Anmeldung erfolgreich',
          'welcome_user': 'Willkommen {name}',
          'invalid_credentials': 'Ungültige E-Mail oder Passwort',
          'login_error': 'Anmeldefehler aufgetreten',
          'connection_failed': 'Verbindung fehlgeschlagen. Bitte überprüfen Sie Ihre Internetverbindung',
          'logout_success': 'Abmeldung erfolgreich',
          'logout_completed': 'Erfolgreich abgemeldet',
          'logout_error': 'Abmeldefehler aufgetreten',

          // Token und Authentifizierungsstatus
          'checking_auth_status': 'Authentifizierungsstatus wird überprüft...',
          'token_invalid': 'Ungültiger Token',
          'session_expired': 'Sitzung abgelaufen',
          'auth_data_cleared': 'Authentifizierungsdaten gelöscht',
          'user_data_saved': 'Benutzerdaten lokal gespeichert',

          // Rollenüberprüfung
          'driver_access_only': 'Nur Fahrerzugang',
          'role_verification_failed': 'Rollenüberprüfung fehlgeschlagen',
          'unauthorized_access': 'Unbefugter Zugriffsversuch',

          // Auftragsverwaltung
          'order_management': 'Auftragsverwaltung',
          'create_order_success': 'Auftrag erfolgreich erstellt',
          'order_number': 'Auftragsnummer: {number}',
          'order_updated_success': 'Auftrag erfolgreich aktualisiert',
          'order_deleted_success': 'Auftrag erfolgreich gelöscht',
          'order_not_found': 'Auftrag nicht gefunden',
          'order_data_not_returned': 'Auftragsdaten vom Server nicht zurückgegeben',

          // Auftragsstatus-Nachrichten
          'status_updated_success': 'Auftragsstatus aktualisiert',
          'status_changed_to': 'Auftragsstatus geändert zu: {status}',
          'cannot_update_status': 'Status kann nicht von {from} zu {to} aktualisiert werden',
          'order_ready_for_completion': 'Auftrag bereit zum Abschluss',
          'order_completed_success_detailed': 'Auftrag {client} erfolgreich abgeschlossen',
          'order_started_success': 'Auftragsausführung gestartet',
          'order_cancelled_success': 'Auftrag erfolgreich storniert',

          // Validierungsnachrichten
          'must_login_first': 'Zuerst anmelden',
          'vehicle_owner_name_required': 'Fahrzeughalter-Name ist erforderlich',
          'vehicle_plate_required': 'Fahrzeugkennzeichen ist erforderlich',
          'pickup_address_required': 'Abholadresse ist erforderlich',
          'delivery_address_required': 'Zieladresse ist erforderlich',
          'order_id_required': 'Auftrags-ID ist erforderlich',
          'new_status_required': 'Neuer Status ist erforderlich',
          'order_not_found_locally': 'Auftrag lokal nicht gefunden',

          // Anforderungen und Abschluss
          'requirements_for_completion': 'Zum Abschluss des Auftrags müssen Sie hinzufügen: {requirements}',
          'add_vehicle_photos_req': 'Fahrzeugfotos hinzufügen',
          'driver_signature_req': 'Fahrerunterschrift',
          'customer_signature_req': 'Kundenunterschrift',
          'add_expenses_req': 'Auslagen hinzufügen',
          'all_requirements_completed': 'Alle Anforderungen erfüllt, Auftrag wird abgeschlossen...',

          // Auftragsaktionen
          'cannot_edit_current_status': 'Dieser Auftrag kann im aktuellen Status nicht bearbeitet werden',
          'can_only_start_pending': 'Nur Aufträge mit Status "ausstehend" können gestartet werden',
          'cannot_cancel_completed': 'Abgeschlossener Auftrag kann nicht storniert werden',
          'order_already_cancelled': 'Auftrag bereits storniert',
          'confirm_cancellation': 'Stornierung bestätigen',
          'cancel_order_confirmation': 'Sind Sie sicher, dass Sie Auftrag "{client}" stornieren möchten?\n\nAuftragsstatus wird auf "storniert" geändert.',
          'no_continue': 'Nein, fortfahren',
          'yes_cancel_order': 'Ja, Auftrag stornieren',

          // Löschbestätigung
          'confirm_delete': 'Löschen bestätigen',
          'delete_order_confirmation': 'Sind Sie sicher, dass Sie Auftrag "{client}" löschen möchten?',
          'order_deleted_permanently': 'Auftrag wird dauerhaft gelöscht und kann nicht wiederhergestellt werden',
          'order_deleted_success_detailed': 'Auftrag "{client}" erfolgreich gelöscht',

          // Bildverwaltung
          'signature_saved_success': 'Unterschrift erfolgreich gespeichert',
          'signature_save_failed': 'Fehler beim Speichern der Unterschrift',
          'expenses_added_success': 'Auslagen erfolgreich hinzugefügt',
          'expenses_add_failed': 'Fehler beim Hinzufügen der Auslagen',

          // Filter und Suche
          'orders_refreshed': 'Aufträge aktualisiert',
          'orders_list_updated': 'Auftragsliste aktualisiert',
          'filter_error': 'Fehler beim Filtern der Aufträge: {error}',

          // Statistiken
          'image_statistics_error': 'Fehler beim Berechnen der Bildstatistiken: {error}',
          'images_by_category_error': 'Fehler beim Abrufen der Bilder nach Kategorie: {error}',
          'image_requirements_error': 'Fehler beim Überprüfen der Bildanforderungen: {error}',
          'order_readiness_error': 'Fehler beim Überprüfen der Auftragsbereitschaft: {error}',
          'order_not_ready_missing_images': 'Auftrag nicht bereit: fehlende Bilder',
          'order_not_ready_missing_signatures': 'Auftrag nicht bereit: fehlende Unterschriften',

          // Verbindungs- und Fehlernachrichten
          'connection_problem': 'Internetverbindungsproblem',
          'connection_timeout': 'Verbindungs-Timeout, bitte erneut versuchen',
          'login_again': 'Bitte erneut anmelden',
          'data_not_found': 'Angeforderte Daten nicht gefunden',
          'updating_order_from_to': 'Auftragsstatus wird von {from} zu {to} aktualisiert',
          'order_updated_locally': 'Auftrag lokal aktualisiert',
          'updated_data_not_returned': 'Aktualisierte Daten vom Server nicht zurückgegeben',
          'notifying_controllers_error': 'Fehler beim Benachrichtigen der Controller: {error}',
          'refreshing_order': 'Auftrag wird aktualisiert: {orderId}',
          'order_updated_dashboard': 'Auftrag im Dashboard aktualisiert',
          'refresh_order_error': 'Fehler beim Aktualisieren des Auftrags: {error}',

          // E-Mail-Bericht
          'email_report_success': 'Bericht erfolgreich per E-Mail gesendet',
          'email_report_failed': 'Fehler beim Senden des Berichts',
          'email_send_error': 'Fehler beim Senden der E-Mail: {error}',

          // Auftragsbearbeitung
          'edit_success': 'Erfolgreich',
          'order_updated_all_saved': 'Auftrag aktualisiert und alle Änderungen gespeichert',
          'cannot_edit_order_status': 'Dieser Auftrag kann im aktuellen Status nicht bearbeitet werden',

          // Status-Anzeige
          'status_cancelled': 'Storniert',


          // Zusätzlicher Hilfstext
          'creating_new_order': 'Neuen Auftrag erstellen',
          'order_created_successfully': 'Auftrag erfolgreich erstellt',
          'updating_order_details': 'Auftragsdetails aktualisieren',
          'order_updated_successfully': 'Auftrag erfolgreich aktualisiert',
          'starting_order_update': 'Auftragsaktualisierung starten',
          'incoming_data': 'Eingehende Daten',
          'sending_data_to_server': 'Daten an Server senden',
          'final_data': 'Finale Daten',
          'all_changes_saved': 'Alle Änderungen gespeichert',
          'updating_details_controller': 'Details-Controller aktualisieren',
          'checking_completion_requirements': 'Abschlussanforderungen prüfen',
          'get_orders_by_status_error': 'Fehler beim Abrufen der Aufträge nach Status',
          'get_recent_orders_error': 'Fehler beim Abrufen der aktuellen Aufträge',
          'close': 'Schließen',
          'success': 'Erfolgreich',


          // Löschbestätigungen
          'confirm_delete_image': 'Bildlöschung bestätigen',
          'confirm_delete_image_message': 'Sind Sie sicher, dass Sie dieses Bild löschen möchten?',
          'confirm_delete_signature': 'Unterschriftlöschung bestätigen',
          'confirm_delete_signature_message': 'Sind Sie sicher, dass Sie die {signerType}-Unterschrift löschen möchten?',
          'driver': 'Fahrer',
          'customer': 'Kunde',
          'image_deleted_success': 'Bild erfolgreich gelöscht',
          'signature_deleted_success': 'Unterschrift erfolgreich gelöscht',
          'failed_delete_image': 'Fehler beim Löschen des Bildes',
          'failed_delete_signature': 'Fehler beim Löschen der Unterschrift',

          // Bild-Upload-Nachrichten
          'uploading_images': '{count} Bilder für Auftrag hochladen: {orderId}',
          'images_uploaded_success': '{uploaded} von {total} Bildern erfolgreich hochgeladen',
          'failed_upload_images': 'Fehler beim Hochladen der Bilder',
          'image_upload_error': 'Fehler beim Hochladen der Bilder: {error}',
          'select_images_error': 'Fehler beim Auswählen der Bilder: {error}',

          // Unterschrift-Nachrichten
          'uploading_signature': 'Unterschrift für Auftrag hochladen: {orderId}',
          'signature_upload_error': 'Fehler beim Hochladen der Unterschrift: {error}',

          // Auslagen-Nachrichten
          'updating_expenses_for_order': 'Auslagen für Auftrag aktualisieren: {orderId}',
          'incoming_expenses_data': 'Eingehende Auslagendaten: {data}',
          'expenses_update_error': 'Fehler beim Aktualisieren der Auslagen: {error}',
          'uploading_expenses_for_order': 'Auslagen für Auftrag hochladen: {orderId}',
          'expenses_upload_error': 'Fehler beim Hochladen der Auslagen: {error}',

          // Auftragsabschluss
          'starting_order_completion': 'Auftragsabschluss wird gestartet...',
          'cannot_complete_missing_requirements': 'Auftrag kann nicht abgeschlossen werden - fehlende Anforderungen',
          'missing_requirements_list': 'Fehlende Anforderungen: {requirements}',
          'completion_confirmed': 'Abschluss für Auftrag {client} bestätigt',
          'order_completion_process_started': 'Auftragsabschlussprozess gestartet',
          'order_completion_success_with_client': 'Auftrag für {client} erfolgreich abgeschlossen',
          'order_completion_process_error': 'Fehler im Auftragsabschlussprozess: {error}',
          'general_completion_error': 'Allgemeiner Fehler beim Auftragsabschluss: {error}',

          // Auftragsbearbeitung
          'opening_edit_page': 'Auftragsbearbeitungsseite öffnen: {orderId}',
          'order_data_for_editing': 'Auftragsdaten zur Bearbeitung: {fields}',
          'edit_completed_successfully': 'Bearbeitung erfolgreich abgeschlossen, Daten werden neu geladen',
          'edit_result': 'Bearbeitungsergebnis: {result}',
          'error_opening_edit_page': 'Fehler beim Öffnen der Auftragsbearbeitungsseite: {error}',
          'cannot_edit_no_data': 'Auftrag kann nicht bearbeitet werden - Daten nicht verfügbar',
          'error_converting_order_json': 'Fehler beim Konvertieren des Auftrags zu JSON: {error}',
          'edit_cancelled': 'Bearbeitung abgebrochen',

          // Auftragsstatus-Updates
          'notifying_dashboard_update': 'Dashboard-Daten nach Auftragsstatus-Update aktualisieren',
          'error_notifying_dashboard': 'Fehler beim Benachrichtigen des Dashboards über Update: {error}',
          'updating_order_status_server': 'Fehler beim Aktualisieren des Auftragsstatus auf dem Server',

          // Controller-Lebenszyklus
          'controller_disposed': 'OrderDetailsController bereinigt',
          'preventing_execution_disposed': 'Ausführung verhindert - Controller bereinigt',
          'order_already_loaded': 'Auftrag bereits geladen',
          'starting_order_initialization': 'Auftragsinitialisierung starten: {orderId}',
          'error_loading_order_details': 'Fehler beim Laden der Auftragsdetails: {error}',
          'loading_failed': 'Laden fehlgeschlagen',

          // Menüaktionen
          'mark_in_progress': 'Als in Bearbeitung markieren',

          // Bildkategorien
          'select_category_for_images': 'Kategorie für Bilder auswählen',
          'image_category_required': 'Bildkategorie ist erforderlich',

          // Zusätzliche Validierung
          'order_data_unavailable': 'Auftragsdaten nicht verfügbar',
          'edit_error_title': 'Bearbeitungsfehler',
          'could_not_open_edit_page': 'Bearbeitungsseite konnte nicht geöffnet werden: {error}',

          // Erfolgsnachrichten mit Details
          'expenses_total_amount': 'Gesamt: €{amount}',
          'signature_type_saved': '{type}-Unterschrift gespeichert',

          // Ladezustände
          'initializing_order': 'Auftrag initialisieren',
          'order_initialization_complete': 'Auftragsinitialisierung abgeschlossen',
          'reloading_order_data': 'Auftragsdaten neu laden',

          'signature_page': 'Unterschrift',
          'signer_name': 'Name des Unterzeichners',
          'please_sign_below': 'Bitte unterschreiben Sie im unteren Bereich',
          'clear_signature': 'Löschen',
          'save_signature': 'Unterschrift speichern',
          'signature_error': 'Fehler',
          'enter_signer_name': 'Bitte geben Sie den Namen des Unterzeichners ein',
          'add_signature_first': 'Bitte fügen Sie zuerst eine Unterschrift hinzu',
          'signature_conversion_failed': 'Fehler beim Konvertieren der Unterschrift',
          'signature_save_failed_error': 'Fehler beim Speichern der Unterschrift',


        }


      };
}