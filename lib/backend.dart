import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

//유저 객체에서 쓰이는 상수
const String UID = "uid";
const String NICKNAME = "nickname";
const String LOCATION = "location";

// 아이템 클래스에서 쓰이는 상수
const String IMAGE_URI = 'imageUri';
const String TITLE = "title";
const String CATEGORY = "category";
const String PRICE = "price";
const String DESCRIPTION = "description";
const String TIMESTAMP = "timestamp";
const String REGISTER = "register";
const String EMAIL = "email";
const String ITEMID = "itemid";

// 채팅 클래스에서 쓰이는 함수
const String CONTENT = "content";
const String SENDER = "sender";
const String RECEIVER = "receiver";

//지역 리스트
const List<String> availableLocations = [
  '양호동',
  '선주 원남동',
  '도량동',
  '양포동',
  '상모 사곡동',
  '광평동',
  '칠곡',
  '진미동',
  '인동동',
  '임오동',
  '도량동',
  '지산동',
  '송정동',
  '형곡동',
  '원평동',
  '신평동',
  '비산동',
  '공단동',
];

class MyAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final MyUser _myUser = MyUser.instance;
  final String _uri = "/UserData";

  Future _getDocs(String key, String value) async {
    //key: doc's index, value: document
    var result =
        await _firestore.collection(_uri).where(key, isEqualTo: value).get();
    var docs = result.docs.asMap();
    return docs;
  }

  Future _authenticateUser(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      return user;
    } on FirebaseAuthException {
      return;
    }
  }

  _loadUserData(String uid) async {
    var docs = await _getDocs(UID, uid);
    if (docs == null || docs.isEmpty || docs[0] == null) {
      print("!docs null or empty");
      return;
    }
    Map data = docs[0].data() as Map;
    if (data[UID] == null || data[NICKNAME] == null || data[LOCATION] == null) {
      print("!null from user database");
      return;
    }
    if (data.isEmpty) {
      print("!user not exist");
      return;
    }
    return data;
  }

  _isNicknameTaken(String nickname) async {
    var data = await _getDocs(NICKNAME, nickname);
    if (data == null || data.isEmpty) {
      return false;
    }
    return true;
  }

  Future _verifyUser(String email, String password) async {
    try {
      UserCredential userInfo = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (userInfo.user!.email == null) {
        print("!null from email");
        return;
      }
      _auth.currentUser!.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      print(e.code.toString());
    }
  }

  //sign in
  signIn({required String email, required String password}) async {
    User? user = await _authenticateUser(email, password);
    if (user == null) {
      print("!failed verifying user");
      return;
    }
    Map<String, dynamic>? data = await _loadUserData(user.uid);
    if (data == null) {
      print("!failed load data");
      return;
    }
    _myUser.setUser(
        uid: data[UID], nickname: data[NICKNAME], location: data[LOCATION]);
    return true;
  }

  //sign out
  Future signOut() async => await FirebaseAuth.instance.signOut();

  //sign up
  signUp(
      {required String email,
      required String password,
      required String nickname}) async {
    if (await _isNicknameTaken(nickname)) {
      return;
    }
    await _verifyUser(email, password);
  }
}

class MyUser {
  //singleton
  MyUser._privateConstructor();
  static final MyUser _instance = MyUser._privateConstructor();
  static MyUser get instance => _instance;
  //member variable
  String? _uid;
  String? _nickname;
  String? _location;

  String? get getUid => _uid;
  String? get getNickname => _nickname;
  String? get getLocation => _location;

  setUser(
      {required String uid,
      required String nickname,
      required String location}) {
    _uid = uid;
    _nickname = nickname;
    _location = location;
  }
}

class Item {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final MyUser _myUser = MyUser._instance;
  final String _itemUri = '/ItemData';
  final String _storageUri = 'images/';

  _getCollection() {
    var result = _firestore.collection(_itemUri);
    return result;
  }

  String _getUuid() {
    Uuid uuid = const Uuid();
    return uuid.v4();
  }

  Future _registImage(XFile image) async {
    String str = _getUuid(); //무작위로 이름 생성
    //참조 생성
    Reference ref = _storage.ref().child('$_storageUri$str');
    //picker로 얻어온 이미지를 uint8list타입으로 반환
    //File(image.path)를 사용할 경우, 모바일 상에서는 동작 가능하지만, 웹 상에서 동작 안함.
    Uint8List imageData = await image.readAsBytes();
    await ref.putData(imageData);
    String imageurl = await ref.getDownloadURL();
    return imageurl;
  }

  //아이템 등록. regist페이지에서 사용
  registItem(
      {required XFile image,
      required String title,
      required String category,
      required int price,
      required String description}) async {
    var collection = _getCollection(); //아이템 정보 등록할 firestore
    String url = await _registImage(image);
    Map<String, dynamic> item = {
      UID: _myUser.getUid,
      ITEMID: _getUuid(),
      IMAGE_URI: url,
      TITLE: title,
      CATEGORY: category,
      PRICE: price,
      DESCRIPTION: description,
      TIMESTAMP: FieldValue.serverTimestamp(),
      REGISTER: _myUser.getNickname,
      LOCATION: _myUser.getLocation,
    };
    collection.add(item);
  }

  //이미지 선택 함수
  Future pickImage() async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) {
      print("!null from image");
      return;
    }
    return image;
  }

  //내 아이템만 출력
  Future getMyItems() async {
    List<Map<String, dynamic>> list = [];
    var docRef = await _firestore
        .collection(_itemUri)
        .where(UID, isEqualTo: _myUser.getUid)
        .orderBy(TIMESTAMP)
        .get();
    if (docRef.docs.isEmpty) {
      return;
    }
    for (var doc in docRef.docs) {
      list.add(doc.data());
    }
    return list;
  }

  Future<List<Map<String, dynamic>>> startItemStream() async {
    List<Map<String, dynamic>> list = [];
    var snapshot = await _firestore
        .collection(_itemUri)
        .orderBy(TIMESTAMP)
        .limit(50)
        .get();
    for (var doc in snapshot.docs) {
      if (doc.data().isEmpty) {
        return list;
      }
      list.add(doc.data());
    }
    return list;
  }

  Future getMoreItem({required Timestamp time}) async {
    print("!start get");
    List<Map<String, dynamic>> list = [];
    var snapshot = await _firestore
        .collection(_itemUri)
        .orderBy(TIMESTAMP)
        .startAfter([time])
        .limit(50)
        .get();
    for (var doc in snapshot.docs) {
      if (doc.data().isEmpty) {
        return list;
      }
      list.add(doc.data());
    }

    return list;
  }
}

class Chat {
  final String _baseUrl = '/ChatData';
  final String _log = "chat_log";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  MyUser myUser = MyUser._instance;
  //파일구조
  //chatdata 컬렉션
  //내에 여러 문서들: 채팅방.
  //문서 내에는 발신자, 송신자 필드와 채팅 로그 저장을 위한 컬렉션이 있음.
  //채팅 로그 컬렉션에는 여러 문서들이 있는데, 그 문서 하나하나가 메시지임.

  //활성화 중인 채팅창 리스트 출력을 위해
  Future showChatList() async {
    var docRef = await _firestore
        .collection(_baseUrl)
        .where(SENDER, isEqualTo: myUser.getNickname)
        .get();

    if (docRef.docs.isEmpty) return;

    List<Map<String, dynamic>> list = [];
    for (var doc in docRef.docs) {
      list.add(doc.data());
    }
    return list;
  }

  //채팅창 리스트에서 요소 클릭 시 채팅방으로 넘어갈 때
  getChattingRoom({required String receiver}) {
    CollectionReference collection = _firestore
        .collection(_baseUrl)
        .doc("${myUser.getNickname}_$receiver")
        .collection(_log);
    return collection;
  }

  //채팅하기 버튼 클릭 시 채팅방 생성할 때
  createChattingRoom({required String receiver, required String itemId}) {
    _firestore
        .collection(_baseUrl)
        .doc("${myUser.getNickname}_$receiver")
        .collection(_log);
    _firestore
        .collection(_baseUrl)
        .doc("${myUser.getNickname}_$receiver")
        .set({SENDER: myUser.getNickname, RECEIVER: receiver, ITEMID: itemId});
  }
}
