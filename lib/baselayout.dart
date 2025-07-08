import 'package:flutter/material.dart';

class BaseLayout extends StatelessWidget {
  final String appBarTitle;
  final Widget body;

  const BaseLayout({
    super.key,
    required this.appBarTitle,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        backgroundColor: Colors.teal,
      ),
      body: body,
    );
  }
}
