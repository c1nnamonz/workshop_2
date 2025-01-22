import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final Image image;
  final String category;

  const CategoryCard({
    required this.image,
    required this.category,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: image,
        ),
        const SizedBox(height: 5),
        Text(
          category,
          style: const TextStyle(fontSize: 12, color: Colors.black),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

