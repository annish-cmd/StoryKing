/*
 * FAVORITES PAGE (LEGACY)
 * --------------------
 * Simple screen showing a list of favorite stories.
 * 
 * Note: This appears to be a legacy version that has been replaced 
 * by the more feature-rich favorites_screen.dart file in the screens directory.
 */

import 'package:flutter/material.dart';

class FavoritesPage extends StatelessWidget {
  final List<String> favoriteStories;

  const FavoritesPage({super.key, required this.favoriteStories});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Stories'),
        backgroundColor: Colors.deepPurple,
      ),
      body: favoriteStories.isEmpty
          ? const Center(
              child: Text('No favorite stories yet!',
                  style: TextStyle(fontSize: 20)))
          : ListView.builder(
              itemCount: favoriteStories.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(favoriteStories[index]),
                    // Add more details or actions if needed
                  ),
                );
              },
            ),
    );
  }
}
