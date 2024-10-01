import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:spm_project/auth/auth.dart';
import 'package:spm_project/auth/loginOrRegister.dart';
import 'package:spm_project/firebase_options.dart';
import 'package:spm_project/pages/help.dart';
import 'package:spm_project/pages/home.dart';
import 'package:spm_project/pages/objects_detection/currency_obj.dart';
import 'package:spm_project/pages/objects_detection/display_shape.dart';
import 'package:spm_project/pages/objects_detection/math_object.dart';
import 'package:spm_project/pages/objects_detection/science_obj.dart';
import 'package:spm_project/pages/profile.dart';
import 'package:spm_project/pages/quiz/add_question_page.dart';
import 'package:spm_project/pages/quiz/quiz_page.dart';
import 'package:spm_project/pages/quiz/voice_notes_page.dart';
import 'package:spm_project/theme/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthPage(),
      theme: colorMode,
      routes: {
        '/login_register_page': (context) => const LoginOrRegister(),
        '/home_page': (context) => const HomePage(),
        '/profile_page': (context) => const ProfilePage(),
        '/maths_obj': (context) => const MathsObj(),
        '/science_obj': (context) => const ScienceObj(),
        '/currancy_obj': (context) => const CurrancyObj(),
        '/display_shape_obj': (context) => const DisplayShapes(),
        '/help_page': (context) => const HelpScreen(),
        '/add_quiz': (context) => const AddQuestionPage(),
        '/quiz_page': (context) => const QuizPage(),
        '/voice_note_page': (context) => const VoiceNotesPage(),
      },
    );
  }
}
