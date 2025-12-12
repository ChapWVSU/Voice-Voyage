import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_helper.dart';
import 'edit_profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<Map<String, dynamic>> _profiles = [];
  String? _userId;
  bool _isLoading = true;
  String? _selectedProfileId;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      print('DEBUG: userId from SharedPreferences: $userId');

      if (userId == null) {
        // Not logged in, redirect to login
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }

      if (!mounted) return;

      // Fetch profiles from Firestore
      final profiles = await ProfileHelper.getUserProfiles(userId);
      print('DEBUG: profiles fetched: ${profiles.length} profiles');
      for (var profile in profiles) {
        print('DEBUG: profile - ${profile['name']} (userId: ${profile['userId']})');
      }
      
      if (mounted) {
        setState(() {
          _userId = userId;
          _profiles = profiles;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading profiles: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showAddProfileDialog() {
    final profileNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Create New Profile'),
          content: TextField(
            controller: profileNameController,
            decoration: const InputDecoration(
              hintText: 'Profile name (e.g., Bensoy)',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final profileName = profileNameController.text.trim();
                if (profileName.isEmpty) {
                  // Close dialog first
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                  // Show snackbar on main context after dialog closes
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a profile name')),
                    );
                  }
                  return;
                }

                // Close dialog first
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }

                try {
                  await ProfileHelper.createProfile(
                    userId: _userId!,
                    profileName: profileName,
                    avatarPath: 'assets/images/prof.png',
                  );

                  if (mounted) {
                    await _loadProfiles();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile created successfully!')),
                    );
                  }
                } catch (e) {
                  print('Error creating profile: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error creating profile: $e')),
                    );
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('userEmail');

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _handleBackButton() async {
    if (_selectedProfileId != null) {
      // User has selected a profile, go back to homepage
      Navigator.pop(context);
    } else {
      // User just logged in, show logout confirmation
      final logout = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Log Out?'),
            content: const Text('Do you want to log out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Log Out', style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
      );

      if (logout == true) {
        _logout();
      }
    }
  }

  void _showProfileOptions() {
    setState(() => _isEditMode = !_isEditMode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profiles",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _handleBackButton,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.edit, color: Colors.black),
              onPressed: _showProfileOptions,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Who's Playing?",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 40),
                    if (_profiles.isEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'No profiles yet. Create one to get started!',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: _showAddProfileDialog,
                            child: Container(
                              height: 120,
                              width: 120,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.blue, width: 2),
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 60,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ..._profiles.map((profile) {
                              return GestureDetector(
                                onTap: () {
                                  if (!_isEditMode) {
                                    // Track selected profile and navigate to homepage
                                    setState(() => _selectedProfileId = profile['id']);
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/homepage',
                                      arguments: {'profileId': profile['id'], 'profileName': profile['name']},
                                    );
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                  child: Stack(
                                    children: [
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: 140,
                                            width: 140,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.1),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(20),
                                              child: Image.asset(
                                                profile['avatar'] ?? 'assets/images/prof.png',
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Container(
                                                    color: Colors.blue,
                                                    child: const Icon(
                                                      Icons.person,
                                                      size: 60,
                                                      color: Colors.white,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          SizedBox(
                                            width: 140, // same as avatar width
                                            child: Text(
                                              profile['name'] ?? 'Unknown',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (_isEditMode)
                                        Positioned(
                                          left: 0,
                                          right: 0,
                                          top: 0,
                                          bottom: 0,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  // Delete button (top-left)
                                                  GestureDetector(
                                                    onTap: () async {
                                                      final confirm = await showDialog<bool>(
                                                        context: context,
                                                        builder: (BuildContext context) {
                                                          return AlertDialog(
                                                            title: const Text('Delete Profile'),
                                                            content: const Text('Are you sure you want to delete this profile?'),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () => Navigator.pop(context, false),
                                                                child: const Text('Cancel'),
                                                              ),
                                                              TextButton(
                                                                onPressed: () => Navigator.pop(context, true),
                                                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );

                                                      if (confirm == true) {
                                                        try {
                                                          await ProfileHelper.deleteProfile(profile['id']);
                                                          setState(() => _isEditMode = false);
                                                          await _loadProfiles();
                                                          if (mounted) {
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              const SnackBar(content: Text('Profile deleted')),
                                                            );
                                                          }
                                                        } catch (e) {
                                                          if (mounted) {
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              SnackBar(content: Text('Error deleting profile: $e')),
                                                            );
                                                          }
                                                        }
                                                      }
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.red,
                                                        shape: BoxShape.circle,
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black.withOpacity(0.3),
                                                            blurRadius: 4,
                                                            offset: const Offset(0, 2),
                                                          ),
                                                        ],
                                                      ),
                                                      padding: const EdgeInsets.all(8),
                                                      child: const Icon(
                                                        Icons.delete,
                                                        color: Colors.white,
                                                        size: 20,
                                                      ),
                                                    ),
                                                  ),
                                                  // Edit button (top-right)
                                                  GestureDetector(
                                                    onTap: () async {
                                                      final result = await Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => EditProfilePage(
                                                            profileId: profile['id'],
                                                            profileName: profile['name'],
                                                            profileAvatar: profile['avatar'],
                                                          ),
                                                        ),
                                                      );

                                                      if (result == true) {
                                                        setState(() => _isEditMode = false);
                                                        await _loadProfiles();
                                                      }
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.orange,
                                                        shape: BoxShape.circle,
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black.withOpacity(0.3),
                                                            blurRadius: 4,
                                                            offset: const Offset(0, 2),
                                                          ),
                                                        ],
                                                      ),
                                                      padding: const EdgeInsets.all(8),
                                                      child: const Icon(
                                                        Icons.edit,
                                                        color: Colors.white,
                                                        size: 20,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                            // Add new profile button
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                              child: GestureDetector(
                                onTap: _showAddProfileDialog,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 140,
                                      width: 140,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.blue, width: 2),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.add,
                                        size: 60,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Add Child',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
