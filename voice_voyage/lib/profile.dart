import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Who's Playing?",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () {
            // Handle closing the profile selection screen
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black),
            onPressed: () {
              // Handle edit functionality
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // "Who's Playing?" text
            const Text(
              "Who's Playing?",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 40),

            // Profile Avatar, Name, and Add Child Button in one row
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // Center the entire row
              children: [
                // Profile Avatar with a custom image (local asset)
                GestureDetector(
                  onTap: () {
                    // Handle profile selection (navigate to homepage)
                    Navigator.pushReplacementNamed(context, '/homepage');
                  },
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue,
                    backgroundImage: AssetImage('assets/images/prof.png'), // Your local image
                  ),
                ),
                const SizedBox(width: 16), // Space between the avatar and name
                const Text(
                  "Bensoy",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16), // Space between the name and Add Child button
                // Add Child Button (Square with Plus)
                GestureDetector(
                  onTap: () {
                    // Handle adding a child profile
                  },
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: const Icon(
                      Icons.add,
                      size: 40,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Parent's Profile Section
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // Center this row
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.orange,
                  backgroundImage: AssetImage('assets/images/parprof.png'),
                ),
                const SizedBox(width: 8), // Space between avatar and text
                const Text(
                  "Parent's Profile",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
