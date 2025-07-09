import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../models/order.dart';

class OrderDataSource extends DataGridSource {
  OrderDataSource(List<Order> orders) {
    _orders = orders;
    _buildDataGridRows();
  }

  List<Order> _orders = [];
  List<DataGridRow> _dataGridRows = [];

  void _buildDataGridRows() {
    _dataGridRows = _orders.map<DataGridRow>((order) {
      return DataGridRow(cells: [
        DataGridCell<int>(columnName: 'orderNumber', value: order.orderNumber),
        DataGridCell<String>(columnName: 'client', value: order.client),
        DataGridCell<String>(columnName: 'licensePlate', value: order.vehicleData.licensePlate),
        DataGridCell<String>(columnName: 'status', value: _getStatusText(order.status)),
        DataGridCell<String>(columnName: 'createdAt', value: _formatDate(order.createdAt)),
      ]);
    }).toList();
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending': return 'قيد الانتظار';
      case 'in_progress': return 'قيد التنفيذ';
      case 'completed': return 'مكتملة';
      default: return status;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((cell) {
        if (cell.columnName == 'status') {
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8),
            child: _buildStatusChip(cell.value.toString()),
          );
        }
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8),
          child: Text(cell.value.toString()),
        );
      }).toList(),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'قيد الانتظار':
        color = Colors.orange;
        break;
      case 'قيد التنفيذ':
        color = Colors.blue;
        break;
      case 'مكتملة':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        status,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}
