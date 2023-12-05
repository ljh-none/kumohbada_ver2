import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

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
    _myUser.changeNickname(nickname: _nicknameController.text);
    setState(() {
      _nicknameController.clear();
    });
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
              Row(children: [
                SizedBox(
                    width: 60,
                    height: 60,
                    child: GestureDetector(
                      onTap: () async {
                        XFile? image = await ImagePicker()
                            .pickImage(source: ImageSource.gallery);
                        if (image == null) return;
                        await _myUser.changeProfileImage(profileImage: image);
                        setState(() {});
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.grey,
                        backgroundImage: NetworkImage(_myUser.getProfileImage!),
                      ),
                    )),
                const SizedBox(width: 16),
                // 현재 닉네임 표시
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _myUser.getNickname!,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _myUser.getLocation!,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              // 새로운 닉네임 입력 필드
              SizedBox(
                width: double.infinity, // 전체 폭으로 확장
                child: TextField(
                  controller: _nicknameController,
                  decoration: const InputDecoration(labelText: '새로운 닉네임'),
                ),
              ),
              const SizedBox(height: 16),
              // 닉네임 변경 버튼
              ElevatedButton(
                onPressed: () async {
                  await _isNicknameChanged()
                      ? _updateNickname()
                      : _showPopup("이미 존재하는 닉네임입니다", false);
                },
                child: const Text('닉네임 변경'),
              ),
              const SizedBox(height: 32),
              Row(children: [
                const Spacer(),
                const Text(
                  '내 위치',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                SizedBox(
                  width: 110,
                  height: 30,
                  child: DropdownButton<String>(
                    value: context.watch<MyLocation>().getLocation,
                    onChanged: (String? newValue) async {
                      if (newValue == null) return;
                      context
                          .read<MyLocation>()
                          .changeLocation(location: newValue);
                      await _myUser.changeLocation(location: newValue);
                      setState(() {});
                    },
                    items: availableLocations
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                const Spacer(),
              ]),

              const SizedBox(height: 16),
              // 새로운 비밀번호 입력 필드
              SizedBox(
                width: double.infinity, // 전체 폭으로 확장
                child: TextField(
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
              ),
              const SizedBox(height: 16),
              // 비밀번호 확인 입력 필드
              SizedBox(
                width: double.infinity, // 전체 폭으로 확장
                child: TextField(
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
              ),
              const SizedBox(height: 16),
              // 비밀번호 변경 버튼
              ElevatedButton(
                onPressed: () async {
                  if (_newPasswordController.text !=
                      _confirmPasswordController.text) {
                    _showPopup("비밀번호를 정확히 입력하세요", false);
                    return;
                  }
                  await _myAuth.changePassword(_newPasswordController.text);
                  _newPasswordController.clear();
                  _confirmPasswordController.clear();
                  _showPopup("변경 성공!", true);
                },
                child: const Text('비밀번호 변경'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
