import 'package:flutter/material.dart';
import 'package:profesh_forms/constants.dart';

class BlackDialogue extends StatelessWidget {
  final String? title, subtitle;
  final String imagePath;

  const BlackDialogue(
      {super.key, this.title, this.subtitle, required this.imagePath});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85,
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.black, borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Center(
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title ?? "",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
              if (subtitle != null)
                Text(
                  subtitle ?? "",
                  style: TextStyle(
                      color: ThemeColors.neutral3.color,
                      fontSize: 12,
                      fontWeight: FontWeight.w400),
                )
            ],
          ))
        ],
      ),
    );
  }
}
