import 'package:flutter/material.dart';

import 'backend.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  MyUser _myUser = MyUser.instance;
  MyAuth _myAuth = MyAuth();

  bool _isPasswordMatch = false;

  @override
  void initState() {
    super.initState();
    _loadNickname();
  }

  void _loadNickname() {
    // 여기에 닉네임을 불러오는 로직을 추가
    // 예: _nicknameController.text = 가져온_닉네임;
  }

  void _updateNickname() {
    _showPopup('닉네임이 변경되었습니다.', true);
    _nicknameController.clear();
    setState(() {});
  }

  void _updatePassword() {
    _showPopup('비밀번호가 변경되었습니다.', true);
    _newPasswordController.clear();
    _confirmPasswordController.clear();
    setState(() {});
  }

  _isNicknameChanged() async {
    // return true; // 닉네임이 변경된 경우
    // return false; // 닉네임이 변경되지 않은 경우
    //result가 bool값임.
    var result = await _myAuth.isNicknameTaken(_nicknameController.text);
    if (result) {
      return false;
    }
    return true;
  }

  bool _isPasswordChanged() {
    // return true; // 비밀번호가 변경된 경우
    // return false; // 비밀번호가 변경되지 않은 경우
    return _newPasswordController.text.isNotEmpty;
  }

  void _showPopup(String message, bool bl) {
    String txt = bl ? "변경 완료" : "변경 실패";
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(txt),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('프로필')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  // TODO: 프로필 이미지 표시 (이미지 경로 또는 네트워크 이미지 사용)
                  const CircleAvatar(
                    radius: 30, // 이미지 크기 조절
                    backgroundColor: Colors.grey, // 이미지가 없을 때의 배경색
                    // backgroundImage: AssetImage('이미지_경로'),
                    // backgroundImage: NetworkImage('네트워크_이미지_URL'),
                  ),
                  const SizedBox(width: 16),
                  // 현재 닉네임 표시
                  Text(
                    _myUser.getNickname!,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 새로운 닉네임 입력 필드
              TextField(
                controller: _nicknameController,
                decoration: const InputDecoration(labelText: '새로운 닉네임'),
              ),
              const SizedBox(height: 16),
              // 닉네임 변경 버튼
              ElevatedButton(
                onPressed: () async {
                  await _isNicknameChanged()
                      ? _updateNickname
                      : _showPopup("이미 존재하는 닉네임입니다", false);
                },
                child: const Text('닉네임 변경'),
              ),
              const SizedBox(height: 32),
              // 새로운 비밀번호 입력 필드
              TextField(
                controller: _newPasswordController,
                onChanged: (_) {
                  setState(() {
                    _isPasswordMatch = _newPasswordController.text ==
                        _confirmPasswordController.text;
                  });
                },
                decoration: const InputDecoration(labelText: '새로운 비밀번호'),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              // 비밀번호 확인 입력 필드
              TextField(
                controller: _confirmPasswordController,
                onChanged: (_) {
                  setState(() {
                    _isPasswordMatch = _newPasswordController.text ==
                        _confirmPasswordController.text;
                  });
                },
                decoration: const InputDecoration(labelText: '비밀번호 확인'),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              // 비밀번호 변경 버튼
              ElevatedButton(
                onPressed: _isPasswordChanged() && _isPasswordMatch
                    ? _updatePassword
                    : null,
                child: const Text('비밀번호 변경'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
