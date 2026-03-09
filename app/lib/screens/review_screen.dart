import 'package:flutter/material.dart';

class ReviewScreen extends StatelessWidget {
  final String userId;
  const ReviewScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review')),
      body: Center(child: Text('Review screen for user: $userId')),
    );
  }
}
