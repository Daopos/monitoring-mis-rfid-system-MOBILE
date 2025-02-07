import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agl_heights_app/services/payment_service.dart';

class PaymentHistoryPPage extends StatefulWidget {
  const PaymentHistoryPPage({super.key});

  @override
  State<PaymentHistoryPPage> createState() => _PaymentHistoryPPageState();
}

class _PaymentHistoryPPageState extends State<PaymentHistoryPPage>
    with SingleTickerProviderStateMixin {
  final PaymentService _paymentService = PaymentService();
  late Future<List<dynamic>> _paymentData;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _paymentData = _paymentService.getVehicles();
    _tabController = TabController(length: 2, vsync: this);
  }

  String formatDate(String? date) {
    if (date == null) return 'Unknown Date';
    final DateTime parsedDate = DateTime.parse(date);
    return DateFormat('MMMM d, y').format(parsedDate);
  }

  List<dynamic> filterPayments(List<dynamic> payments, String status) {
    return payments.where((payment) => payment['status'] == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff85C1E7),
      appBar: AppBar(
        backgroundColor: const Color(0xff0A2C42),
        centerTitle: true,
        title: const Text(
          'Payment History',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        bottom: TabBar(
          indicatorColor: Colors.white,
          controller: _tabController,
          tabs: const [
            Tab(text: 'Paid'),
            Tab(text: 'Unpaid'),
          ],
          labelColor: Color(0xff85C1E7),
          unselectedLabelColor: Colors.white,
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _paymentData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No payment history found.'),
            );
          } else {
            final paidPayments = filterPayments(snapshot.data!, 'paid');
            final unpaidPayments = filterPayments(snapshot.data!, 'unpaid');

            return TabBarView(
              controller: _tabController,
              children: [
                buildPaymentList(paidPayments, Colors.green),
                buildPaymentList(unpaidPayments, Colors.red),
              ],
            );
          }
        },
      ),
    );
  }

  Widget buildPaymentList(List<dynamic> payments, Color iconColor) {
    if (payments.isEmpty) {
      return const Center(
        child: Text('No payments found.'),
      );
    }

    return ListView.builder(
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index];

        if (payment['status'] == 'paid') {
          // Sentence format for "Paid" payments
          final String dueMonth = payment['due_date'] != null
              ? DateFormat('MMMM').format(DateTime.parse(payment['due_date']))
              : 'Unknown month';
          final String title = payment['title'] ?? 'No Title';
          final String amount = payment['amount'] != null
              ? '${payment['amount']} pesos'
              : 'an unknown amount';

          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(
                'For the month of $dueMonth, you paid a total amount of $amount for $title.',
              ),
              trailing: Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
            ),
          );
        } else {
          // Modified layout for "Unpaid" payments
          final String dueMonth = payment['due_date'] != null
              ? DateFormat('MMMM').format(DateTime.parse(payment['due_date']))
              : 'Unknown month';
          final String title = payment['title'] ?? 'No Title';

          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text('$title for $dueMonth'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Amount: ${payment['amount'] ?? 'N/A'}'),
                  Text('Due Date: ${formatDate(payment['due_date'])}'),
                ],
              ),
              trailing: Icon(
                Icons.warning,
                color: Colors.red,
              ),
            ),
          );
        }
      },
    );
  }
}
