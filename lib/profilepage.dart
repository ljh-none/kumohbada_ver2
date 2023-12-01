import 'package:flutter/material.dart';
import 'backend.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  MyUser _myUser = MyUser.instance;
  @override
  Widget build(BuildContext context) {
    return Text("currunt user : ${_myUser.getUid}");
  }
}
