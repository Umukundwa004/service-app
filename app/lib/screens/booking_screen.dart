import 'package:flutter/material.dart';

class BookingScreen extends StatelessWidget {
  final String userId;
  const BookingScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking')),
      body: Center(child: Text('Booking screen for user: $userId')),
    );
  }
}
