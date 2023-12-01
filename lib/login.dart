import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'backend.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();

  bool _isLogin = true; // 로그인 모드인지 회원가입 모드인지 구별하는 변수

  // Firebase Authentication login
  Future<void> _login() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Perform additional actions, e.g., loading user data
      await MyAuth().signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Navigate to MainPage upon successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = '해당 이메일로 등록된 계정이 없습니다.';
      } else if (e.code == 'wrong-password') {
        errorMessage = '비밀번호가 잘못되었습니다.';
      } else {
        errorMessage = '로그인에 실패하였습니다. 다시 시도해주세요.';
      }
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('로그인 실패'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('확인'),
            ),
          ],
        ),
      );
    }
  }

  // Firebase Authentication signup
  Future<void> _signup() async {
    try {
      await MyAuth().signUp(
        email: _emailController.text,
        password: _passwordController.text,
        nickname:
            _nicknameController.text, // Use the nickname from the input field
      );

      // After successful signup, perform login
      await _login();
    } catch (e) {
      print('Error during signup: $e');
      // Handle signup error, e.g., show an error dialog
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? '로그인' : '회원가입'), // 앱바 제목 변경
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: '이메일'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: '비밀번호'),
            ),
            if (!_isLogin) ...[
              // 회원가입 모드일 때만 닉네임 입력 필드를 보여줍니다
              const SizedBox(height: 16.0),
              TextField(
                controller: _nicknameController,
                decoration: const InputDecoration(labelText: '닉네임'),
              ),
            ],
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                if (_isLogin) {
                  _login();
                } else {
                  _signup();
                }
              },
              child: Text(_isLogin ? '로그인' : '회원가입'),
            ),
            const SizedBox(height: 8.0),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLogin = !_isLogin; // 로그인 모드와 회원가입 모드를 전환합니다
                });
              },
              child: Text(_isLogin ? '회원가입' : '로그인'),
            ),
          ],
        ),
      ),
    );
  }
}
