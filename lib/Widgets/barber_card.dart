import 'package:flutter/material.dart';

class BarberCard extends StatelessWidget {
  final String name;
  final String pictureURL;
  final int id;
  final double distance;
  final Function()? onTap;

  const BarberCard({
    super.key,
    required this.name,
    required this.pictureURL,
    required this.id,
    required this.distance,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3 / 4, // Set aspect ratio of the card to 3:4
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8), // Add padding here
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AspectRatio(
                  aspectRatio: 1, // Make the image square
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8), // Make all edges circular
                      image: DecorationImage(
                        image: NetworkImage(pictureURL),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$distance km away',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
