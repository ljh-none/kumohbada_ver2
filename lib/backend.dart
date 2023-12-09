import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

//유저 객체에서 쓰이는 상수
const String UID = "uid";
const String NICKNAME = "nickname";
const String LOCATION = "location";
const String PROFILE_URI = "profileUri";

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
const String SENDER_UID = "sender_uid";
const String RECEIVER_UID = "receiver_uid";

//provider class
class MyLocation extends ChangeNotifier {
  String _location = MyUser.instance.getLocation!;
  String get getLocation => _location;

  void changeLocation({required String location}) {
    _location = location;
    notifyListeners();
  }
}

class MyCategory extends ChangeNotifier {
  String _category = "전체";
  String get getCategory => _category;

  void changeCategory({required String category}) {
    _category = category;
    notifyListeners();
  }
}

//리스트 변수 - 지역, 카테고리, 카테고리에 따른 이미지
const List<String> availableLocations = [
  '전체',
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
  '지산동',
  '송정동',
  '형곡동',
  '원평동',
  '신평동',
  '비산동',
  '공단동',
];

final List<String> categoryList = [
  '전체',
  '디지털기기',
  '가구/인테리어',
  '유아동',
  '여성의류',
  '여성잡화',
  '남성패션/잡화',
  '생활가전',
  '생활/주방',
  '가공식품',
  '스포츠/레저',
  '취미/게임/음반',
  '뷰티/미용',
  '식물',
  '반려동물용품',
  '티켓/교환권',
  '도서',
  '유아도서',
  '기타 중고물품',
];

final Map<String, String> categoryImages = {
  '전체': 'assets/images/all.png', // 0
  '디지털기기': 'assets/images/digital_device.png', // 1
  '가구/인테리어': 'assets/images/furniture_interior.png', // 2
  '유아동': 'assets/images/baby_product.png', // 3
  '여성의류': 'assets/images/female_clothes.png', // 4
  '여성잡화': 'assets/images/female_goods.png', // 5
  '남성패션/잡화': 'assets/images/male_clothes_goods.png', // 6
  '생활가전': 'assets/images/electric_appliance.png', // 7
  '생활/주방': 'assets/images/kitchenware.png', // 8
  '가공식품': 'assets/images/canned_food.png', // 9
  '스포츠/레저': 'assets/images/sports_leisure.png', // 10
  '취미/게임/음반': 'assets/images/hobby_game_music.png', // 11
  '뷰티/미용': 'assets/images/beauty.png', // 12
  '식물': 'assets/images/plant.png', // 13
  '반려동물용품': 'assets/images/pet_supplies.png', // 14
  '티켓/교환권': 'assets/images/ticket.png', // 15
  '도서': 'assets/images/book.png', // 16
  '유아도서': 'assets/images/baby_book.png', // 17
  '기타 중고물품': 'assets/images/others.png', // 18
};

//데이터베이스 관련 클래스들
class MyAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final MyUser _myUser = MyUser.instance;

  //member variable
  final String _uri = "/UserData";

  //private function
  Future _getDocs(String key, String value) async {
    //key: doc's index, value: document
    var result =
        await _firestore.collection(_uri).where(key, isEqualTo: value).get();
    var docs = result.docs.asMap();
    return docs;
  }

  Future _authenticateUser(String email, String password) async {
    UserCredential userInfo = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    if (userInfo.user == null) return;

    return userInfo.user!;
  }

  _loadUserData(String uid) async {
    var docs = await _getDocs(UID, uid);
    if (docs == null || docs.isEmpty) return false;

    Map data = docs[0].data() as Map;
    if (data.isEmpty) return;

    return data;
  }

  _registUser(String uid, String nickname, String location) {
    var collection = _firestore.collection(_uri);
    collection.add({
      UID: uid,
      NICKNAME: nickname,
      LOCATION: location,
      PROFILE_URI:
          "https://firebasestorage.googleapis.com/v0/b/ljh-firebase-for-flutter.appspot.com/o/Profile%2Fuser.png?alt=media&token=1a822917-dcbd-4abf-887c-6dc044c85db0",
    });
  }

  //public function
  isNicknameTaken(String nickname) async {
    //닉네임 중복 검사
    var data = await _getDocs(NICKNAME, nickname);

    if (data == null || data.isEmpty) return false;
    return true;
  }

  changePassword(String newPassword) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    try {
      await user.updatePassword(newPassword);
    } catch (e) {
      return;
    }
    return true;
  }

  //sign function
  signIn({required String email, required String password}) async {
    User? user = await _authenticateUser(email, password);
    if (user == null) return false;

    Map<String, dynamic>? data = await _loadUserData(user.uid);
    if (data == null) return false;

    _myUser.setUser(
      uid: data[UID],
      nickname: data[NICKNAME],
      location: data[LOCATION],
      profileImage: data[PROFILE_URI],
    );

    return true;
  }

  Future signOut() async => await FirebaseAuth.instance.signOut();

  signUp({
    required String email,
    required String password,
    required String nickname,
  }) async {
    if (await isNicknameTaken(nickname)) return false;

    UserCredential userInfo = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    if (userInfo.user == null || _auth.currentUser == null) return false;

    _auth.currentUser!.sendEmailVerification();
    _registUser(userInfo.user!.uid, nickname, "양호동");
    return true;
  }
}

class MyUser {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String _uri = "/UserData";
  final String _profileUri = "Profile/";
  //singleton
  MyUser._privateConstructor();
  static final MyUser _instance = MyUser._privateConstructor();
  static MyUser get instance => _instance;
  //member variable
  String? _uid;
  String? _nickname;
  String? _location;
  String? _profileImage;

  String? get getUid => _uid;
  String? get getNickname => _nickname;
  String? get getLocation => _location;
  String? get getProfileImage => _profileImage;

  setUser(
      {required String uid,
      required String nickname,
      required String location,
      required String profileImage}) {
    _uid = uid;
    _nickname = nickname;
    _location = location;
    _profileImage = profileImage;
  }

  _getUserDocument() async {
    QuerySnapshot snapshot =
        await _firestore.collection(_uri).where(UID, isEqualTo: _uid).get();
    return snapshot;
  }

  String _getUuid() {
    Uuid uuid = const Uuid();
    return uuid.v4();
  }

  Future _registImage(XFile image) async {
    String str = _getUuid(); //무작위로 이름 생성
    Reference ref = _storage.ref().child('$_profileUri$str');
    Uint8List imageData = await image.readAsBytes();
    await ref.putData(imageData);
    String imageurl = await ref.getDownloadURL();
    return imageurl;
  }

  changeLocation({required String location}) async {
    QuerySnapshot? snapshot = await _getUserDocument();
    if (snapshot == null || snapshot.docs.isEmpty) return;

    _location = location;
    var docId = snapshot.docs.first.id;

    await _firestore.collection(_uri).doc(docId).update({LOCATION: _location});
  }

  changeNickname({required String nickname}) async {
    QuerySnapshot? snapshot = await _getUserDocument();
    if (snapshot == null || snapshot.docs.isEmpty) return;

    _nickname = nickname;
    var docId = snapshot.docs.first.id;

    await _firestore.collection(_uri).doc(docId).update({NICKNAME: _nickname});
  }

  changeProfileImage({required XFile profileImage}) async {
    QuerySnapshot? snapshot = await _getUserDocument();
    if (snapshot == null || snapshot.docs.isEmpty) return;

    String uri = await _registImage(profileImage);
    _profileImage = uri;
    var docId = snapshot.docs.first.id;

    await _firestore
        .collection(_uri)
        .doc(docId)
        .update({PROFILE_URI: _profileImage});
  }

  getOthersProfileImage({required String otherUid}) async {
    QuerySnapshot snapshot =
        await _firestore.collection(_uri).where(UID, isEqualTo: otherUid).get();
    if (snapshot.docs.isEmpty) return;

    return snapshot.docs.first[PROFILE_URI];
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

  //아이템 수정
  modifyItem(
      {required itemId,
      required XFile image,
      required String title,
      required String category,
      required int price,
      required String description}) async {
    QuerySnapshot snapshot = await _firestore
        .collection(_itemUri)
        .where(ITEMID, isEqualTo: itemId)
        .get();

    DocumentReference docRef = snapshot.docs.first.reference;

    String url = await _registImage(image);
    String? location = _myUser.getLocation;
    String? nickname = _myUser.getNickname;
    String? uid = _myUser.getUid;
    if (location == null || nickname == null || uid == null) {
      false;
    }
    Map<String, dynamic> item = {
      UID: uid, //등록자의 uid
      ITEMID: itemId,
      IMAGE_URI: url,
      TITLE: title,
      CATEGORY: category,
      PRICE: price,
      DESCRIPTION: description,
      TIMESTAMP: FieldValue.serverTimestamp(),
      REGISTER: nickname,
      LOCATION: location,
    };
    await docRef.update(item);
    return true;
  }

  //아이템 삭제
  deleteItem({required String itemId}) async {
    QuerySnapshot snapshot = await _firestore
        .collection(_itemUri)
        .where(ITEMID, isEqualTo: itemId)
        .get();

    DocumentReference docRef = snapshot.docs.first.reference;
    Map<String, dynamic> temp =
        snapshot.docs.first.data() as Map<String, dynamic>;

    await _storage.ref().child(temp[IMAGE_URI]).delete();
    docRef.delete();
    return;
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
    String? location = _myUser.getLocation;
    String? nickname = _myUser.getNickname;
    String? uid = _myUser.getUid;
    if (location == null || nickname == null || uid == null) {
      false;
    }
    Map<String, dynamic> item = {
      UID: uid, //등록자의 uid
      ITEMID: _getUuid(),
      IMAGE_URI: url,
      TITLE: title,
      CATEGORY: category,
      PRICE: price,
      DESCRIPTION: description,
      TIMESTAMP: FieldValue.serverTimestamp(),
      REGISTER: nickname,
      LOCATION: location,
    };
    collection.add(item);
    return true;
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

  //단일 아이템 로드
  getSingleItem({required String itemId}) async {
    QuerySnapshot snapshot = await _firestore
        .collection(_itemUri)
        .where(ITEMID, isEqualTo: itemId)
        .get();
    if (snapshot.docs.isEmpty || snapshot.docs.first.data() == null) return;
    Map<String, dynamic> item =
        snapshot.docs.first.data() as Map<String, dynamic>;
    return item;
  }

  //내 아이템만 출력
  Future<List<Map<String, dynamic>>> getMyItems() async {
    List<Map<String, dynamic>> list = [];
    var snapshot = await _firestore
        .collection(_itemUri)
        .where(UID, isEqualTo: _myUser.getUid)
        .get();
    if (snapshot.docs.isEmpty) {
      print("! no data");
      return list;
    }
    for (var doc in snapshot.docs) {
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
        return null;
      }
      list.add(doc.data());
    }
    return list;
  }

  Future searchItem({required String? str}) async {
    if (str == null) {
      return;
    }
    print(str);
    List<Map<String, dynamic>> list = [];
    var snapshot = await _firestore
        .collection(_itemUri)
        .where(TITLE, whereIn: [str]).get();

    if (snapshot.docs.isEmpty) {
      print("! no data");
      return list;
    }
    for (var doc in snapshot.docs) {
      list.add(doc.data());
    }
    return list;
  }

  Future getCategoryItem({required String category}) async {
    QuerySnapshot snapshot = await _firestore
        .collection(_itemUri)
        .where(CATEGORY, isEqualTo: category)
        .get();

    return snapshot.docs;
  }
}

class Chat {
  final String _baseUrl = '/NewChatData';
  final String _log = "chat_log";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  MyUser myUser = MyUser._instance;
  late CollectionReference _collectionReference;
  //채팅할 때는 한 번에 하나의 채팅방으로만 함. 따라서 임시로 채팅방 위치를 지정해줄 변수를 생성하였음.

  _getSenderIsMe() async {
    List<Map<String, dynamic>> list = [];

    var docRef = await _firestore
        .collection(_baseUrl)
        .where(SENDER_UID, isEqualTo: myUser.getUid)
        .get();

    if (docRef.docs.isEmpty) {
      return list;
    } else {
      for (var doc in docRef.docs) {
        list.add(doc.data());
      }
    }

    return list;
  }

  _getReceiverIsMe() async {
    List<Map<String, dynamic>> list = [];

    var docRef = await _firestore
        .collection(_baseUrl)
        .where(RECEIVER_UID, isEqualTo: myUser.getUid)
        .get();

    if (docRef.docs.isEmpty) {
      return list;
    } else {
      for (var doc in docRef.docs) {
        list.add(doc.data());
      }
    }

    return list;
  }

  //활성화 중인 채팅창 리스트 출력 함수
  Future showChatList() async {
    List<Map<String, dynamic>> list = [];
    list.addAll(await _getSenderIsMe());
    list.addAll(await _getReceiverIsMe());
    return list;
  }

  //한 아이템에 대한 채팅 모두 삭제
  deleteChat({required String itemId}) async {
    QuerySnapshot snapshot = await _firestore
        .collection(_baseUrl)
        .where(ITEMID, isEqualTo: itemId)
        .get();

    for (var doc in snapshot.docs) {
      _firestore.collection(_baseUrl).doc(doc.id).delete();
    }
    return;
  }

  //채팅창 리스트에서 요소 클릭 시 채팅방으로 넘어갈 때
  Stream<QuerySnapshot<Object?>> getChatStream(
      {required Map<String, dynamic> item, required String senderUid}) async* {
    var result = await _firestore
        .collection(_baseUrl)
        .where(ITEMID, isEqualTo: item[ITEMID])
        .where(SENDER_UID, isEqualTo: senderUid)
        .get();

    DocumentReference docRef = result.docs.first.reference;
    _collectionReference = docRef.collection(_log);

    yield* _collectionReference
        .orderBy(TIMESTAMP, descending: true)
        .snapshots();
  }

  //채팅 메시지 보내기
  Future<void> sendMessage({required String msg}) async {
    await _collectionReference.add({
      CONTENT: msg,
      SENDER: myUser.getNickname,
      SENDER_UID: myUser.getUid,
      TIMESTAMP: FieldValue.serverTimestamp(),
    });
  }

  //채팅방이 이미 존재할 경우
  checkRoomExist({required Map<String, dynamic> item}) async {
    var docRef = await _firestore
        .collection(_baseUrl)
        .doc("${myUser.getUid}_${item[ITEMID]}")
        .get();

    if (docRef.data() == null || docRef.data()!.isEmpty) {
      return false;
    }
    return true;
  }

  //채팅하기 버튼 클릭 시 채팅방 생성할 때
  createChattingRoom({required Map<String, dynamic> item}) async {
    await _firestore
        .collection(_baseUrl)
        .doc("${myUser.getUid}_${item[ITEMID]}")
        .set({
      SENDER: myUser.getNickname,
      SENDER_UID: myUser.getUid,
      RECEIVER: item[REGISTER],
      RECEIVER_UID: item[UID],
      ITEMID: item[ITEMID],
      TITLE: item[TITLE],
      IMAGE_URI: item[IMAGE_URI],
    });
  }
}
