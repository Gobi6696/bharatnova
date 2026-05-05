import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(backgroundColor: Colors.white, radius: 20),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 150, height: 14, color: Colors.white),
                        const SizedBox(height: 6),
                        Container(width: 100, height: 10, color: Colors.white),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(width: double.infinity, height: 14, color: Colors.white),
                const SizedBox(height: 8),
                Container(width: double.infinity, height: 14, color: Colors.white),
                const SizedBox(height: 8),
                Container(width: 200, height: 14, color: Colors.white),
                const SizedBox(height: 16),
                Container(width: double.infinity, height: 200, color: Colors.white),
              ],
            ),
          ),
        );
      },
    );
  }
}
