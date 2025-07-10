import 'package:flutter/material.dart';

class BaseLayout extends StatelessWidget {
  final String appBarTitle;
  final Widget body;
  final Color? appBarColor; 

  const BaseLayout({
    super.key,
    required this.appBarTitle,
    this.appBarColor,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        backgroundColor: appBarColor ?? Colors.teal,
      ),
      body: body,
    );
  }
}
