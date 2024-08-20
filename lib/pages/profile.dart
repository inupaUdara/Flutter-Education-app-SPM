import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:spm_project/auth/loginOrRegister.dart';
import 'package:spm_project/component/button.dart';
import 'package:spm_project/component/textfield.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  Future<void> logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginOrRegister()),
        (route) => false,
      );
    } catch (e) {
      print(e.toString());
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserdetails() async {
    return await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser!.email)
        .get();
  }

  Future<void> updateProfile(String username) async {
    try {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(currentUser!.email)
          .update({"username": username});
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> verifyAndUpdateEmail(
      String newEmail, BuildContext context) async {
    try {
      await currentUser!.verifyBeforeUpdateEmail(newEmail);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "A verification link has been sent to your new email. Please verify to complete the update."),
        ),
      );

      FirebaseAuth.instance.authStateChanges().listen((user) async {
        if (user != null && user.emailVerified) {
          await FirebaseFirestore.instance
              .collection("Users")
              .doc(user.email)
              .update({"email": user.email});
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Email updated successfully!")),
          );
        }
      });
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update email: ${e.toString()}")),
      );
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await currentUser!.updatePassword(newPassword);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> deleteProfile(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(currentUser!.email)
          .delete();

      await currentUser!.delete();

      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginOrRegister()),
      );
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController usernameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("PROFILE"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              await logout(context);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: getUserdetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else if (snapshot.hasData) {
            Map<String, dynamic>? user = snapshot.data!.data();
            usernameController.text = user!['username'];
            emailController.text = user['email'];

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.all(25),
                        child: const Icon(
                          Icons.person,
                          size: 64,
                        ),
                      ),
                      const SizedBox(height: 25),
                      CustomTextField(
                        controller: usernameController,
                        hintText: "Username",
                        obscureText: false,
                      ),
                      const SizedBox(height: 15),
                      CustomTextField(
                        controller: emailController,
                        hintText: "Email",
                        obscureText: false,
                      ),
                      const SizedBox(height: 15),
                      CustomTextField(
                        controller: passwordController,
                        hintText: "Password",
                        obscureText: true,
                      ),
                      const SizedBox(height: 25),
                      CustomButton(
                        ontap: () async {
                          await updateProfile(usernameController.text);

                          if (emailController.text != currentUser!.email) {
                            await verifyAndUpdateEmail(
                                emailController.text, context);
                          }

                          if (passwordController.text.isNotEmpty) {
                            await updatePassword(passwordController.text);
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Profile Updated")),
                          );
                        },
                        text: "Update Profile",
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: () async {
                          await deleteProfile(context);
                        },
                        style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor:
                                Theme.of(context).colorScheme.background),
                        child: const Text(
                          "Delete Profile",
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return const Text("No data");
          }
        },
      ),
    );
  }
}
