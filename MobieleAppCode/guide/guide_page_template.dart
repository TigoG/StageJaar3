import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GuidePageTemplate extends StatelessWidget {
  final String? imageAsset; // Optional image (nullable)
  final String title;
  final String description;
  final int pageNumber;

  const GuidePageTemplate({
    Key? key,
    this.imageAsset, // Optional parameter for the image
    required this.title,
    required this.description,
    required this.pageNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      body: Stack(
        children: [
          Column(
            children: [
              // Image block (if available) with no background color
              if (imageAsset != null && imageAsset!.isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Image.asset(
                      imageAsset!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              
              // Title and description in their own container with background color
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                  padding: const EdgeInsets.all(20.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 246, 236, 236), // Background color for the text section
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: CupertinoTheme.of(context)
                                  .textTheme
                                  .textStyle
                                  .copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        description,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Page number indicator
          if (pageNumber > 0)
            Positioned(
              top: 16.0,
              left: 16.0,
              child: Container(
                width: 50.0,
                height: 50.0,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: CupertinoColors.systemGroupedBackground,
                ),
                child: Center(
                  child: Text(
                    pageNumber.toString(),
                    style: CupertinoTheme.of(context)
                                  .textTheme
                                  .textStyle,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
