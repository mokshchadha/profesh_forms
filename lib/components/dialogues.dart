import 'package:flutter/material.dart';
import 'package:profesh_forms/components/black_dialogue.dart';

class ErrorBlackDialogue {
  static void showSnackBar(
      BuildContext context, String? title, String? subtitle,
      {double padding = 10.0}) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    ScaffoldMessenger.of(context).showSnackBar(
        snackBarAnimationStyle: AnimationStyle.noAnimation,
        SnackBar(
          dismissDirection: DismissDirection.none,
          padding: EdgeInsets.all(padding),
          margin: EdgeInsets.only(
            bottom: bottomPadding > 0
                ? bottomPadding + 20
                : 20, // Adjust position when keyboard is visible
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          behavior: SnackBarBehavior.floating,
          content: BlackDialogue(
            imagePath: 'assets/error_icon.png',
            title: title,
            subtitle: subtitle,
          ),
          duration: const Duration(seconds: 2),
        ));
  }
}
