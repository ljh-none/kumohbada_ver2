import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:kumohbada_ver2/chatpage.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'backend.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Item _item = Item();
  List<Map<String, dynamic>> list = []; //홈 화면에서 출력 중인 아이템 리스트

  @override
  Widget build(BuildContext context) {
    Future loadMoreData(var time) async {
      var result = await _item.getMoreItem(time: time);
      if (result.isEmpty) {
        return;
      }
      setState(() => list.addAll(result));
    }

    return FutureBuilder(
      future: _item.startItemStream(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.data == null || !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        list.addAll(snapshot.data!);
        return Container(
          color: Colors.white,
          child: ListView.separated(
            itemCount: list.length,
            itemBuilder: (BuildContext context, int index) {
              if (index == list.length - 1) {
                loadMoreData(list[index][TIMESTAMP]);
              } //스크롤 무한로딩 로직

              if (context.watch<MyLocation>().getLocation != "전체" &&
                  list[index][LOCATION] !=
                      context.watch<MyLocation>().getLocation) {
                return Container();
              } else {
                DateTime date = list[index][TIMESTAMP].toDate();
                String formattedTime = timeago.format(date, locale: 'ko');

                return Card(
                  elevation: 0,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            return HomeSubPage(item: list[index]);
                          },
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.network(
                              list[index][IMAGE_URI] ?? '대체이미지_URL',
                              width: 100.0,
                              height: 100.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 30),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  list[index][TITLE],
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(list[index][LOCATION]),
                                    const SizedBox(width: 5),
                                    const Text('•'),
                                    const SizedBox(width: 5),
                                    Text(formattedTime),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '${NumberFormat('#,###', 'ko_KR').format(list[index][PRICE])}원',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
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
            },
            separatorBuilder: (BuildContext context, int index) {
              if (context.watch<MyLocation>().getLocation != "전체" &&
                  list[index][LOCATION] !=
                      context.watch<MyLocation>().getLocation) {
                return Container();
              } else {
                return Divider(
                  height: 1,
                  color: const Color.fromARGB(136, 73, 73, 73).withOpacity(1),
                  indent: 16, // 시작 부분의 공백
                  endIndent: 16, // 끝 부분의 공백
                );
              }
            },
          ),
        );
      },
    );
  }
}

class HomeSubPage extends StatefulWidget {
  Map<String, dynamic> item;
  HomeSubPage({Key? key, required this.item}) : super(key: key);

  @override
  State<HomeSubPage> createState() => _HomeSubPageState();
}

class _HomeSubPageState extends State<HomeSubPage> {
  final MyUser _myUser = MyUser.instance;
  late String profileUri;
  final Chat _chat = Chat();

  @override
  Widget build(BuildContext context) {
    loadProfileImage() async {
      profileUri =
          await _myUser.getOthersProfileImage(otherUid: widget.item[UID]);
    }

    return FutureBuilder(
        future: loadProfileImage(),
        builder: (BuildContext context, snapshot) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              title: Text(widget.item[TITLE]),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
            body: Container(
              color: Colors.white,
              child: ListView.separated(
                itemCount: 3,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Image.network(widget.item[IMAGE_URI]);
                  } else if (index == 1) {
                    return Card(
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(children: [
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            backgroundImage: NetworkImage(profileUri),
                          ),
                          const SizedBox(width: 8.0),
                          Column(children: [
                            Text(widget.item[REGISTER],
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(widget.item[LOCATION]),
                          ]),
                          const Spacer(),
                          Column(children: [
                            Row(
                              children: List.generate(
                                  5, // 별점을 표시하는 부분은 어떻게 처리할지 알려주셔야 합니다.
                                  (index) => const Icon(Icons.star,
                                      color: Colors.orange)),
                            ),
                            Text(timeago.format(
                              widget.item[TIMESTAMP].toDate(),
                              locale: 'ko',
                            )),
                          ]),
                        ]),
                      ),
                    );
                  } else {
                    return Card(
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text(widget.item[DESCRIPTION]),
                      ),
                    );
                  }
                },
                separatorBuilder: (context, index) {
                  return const Divider(
                    color: Color.fromARGB(255, 211, 211, 211),
                    thickness: 1,
                    indent: 20,
                    endIndent: 20,
                  );
                },
              ),
            ),
            bottomNavigationBar: BottomAppBar(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Text(
                        '가격 : ${NumberFormat('#,###', 'ko_KR').format(widget.item[PRICE])}원'),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () async {
                        if (widget.item[UID] == _myUser.getUid) {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (BuildContext context) {
                            return ModifyItemPage(widget.item);
                          }));
                        } else {
                          var result =
                              await _chat.checkRoomExist(item: widget.item);
                          if (!result) {
                            //챗방이 없을 때
                            await _chat.createChattingRoom(item: widget.item);
                          }
                          gotoChatting();
                        }
                      },
                      child: widget.item[UID] == _myUser.getUid
                          ? const Text("수정하기")
                          : const Text("채팅하기"),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future<dynamic> gotoChatting() {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (BuildContext context) {
        return ChatSubPage(widget.item, _myUser.getUid);
      }),
    );
  }
}

class ModifyItemPage extends StatefulWidget {
  Map<String, dynamic>? _item;
  ModifyItemPage(Map<String, dynamic> item, {super.key}) {
    _item = item;
  }

  @override
  State<ModifyItemPage> createState() => _ModifyItemPageState();
}

class _ModifyItemPageState extends State<ModifyItemPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  XFile? _image;
  String? _selectedCategory; // 선택된 카테고리를 저장할 변수
  final Item _item = Item();

  // 글을 제출 또는 수정하는 함수
  _modify() async {
    String title = titleController.text;
    String price = priceController.text;
    String description = descriptionController.text;

    // 이미지, 제목, 가격, 설명, 선택된 카테고리로 새로운 Item 생성
    bool result = await _item.updateItem(
      itemId: widget._item![ITEMID],
      image: _image!,
      title: title,
      category: _selectedCategory!,
      price: int.parse(price),
      description: description,
    );

    if (result) {
      _returnToHomePage();
    }
  }

  //async gap 경고에 때문에 함수로 작성.
  _returnToHomePage() => Navigator.pop(context, true);

  @override
  void initState() {
    super.initState();
    _image = XFile(widget._item![IMAGE_URI]);
    _selectedCategory = widget._item![CATEGORY];
    titleController.text = widget._item![TITLE];
    priceController.text = widget._item![PRICE].toString();
    descriptionController.text = widget._item![DESCRIPTION];
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: const Text('글쓰기')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 16),
              // 이미지 선택 버튼
              if (_image == null)
                SizedBox(
                  height: 100.0,
                  width: 130.0,
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        _image = await _item.pickImage();
                      },
                      child: const Text('이미지 선택'),
                    ),
                  ),
                ),
              // 선택한 이미지 표시
              if (_image != null)
                GestureDetector(
                  onTap: () async {
                    _image = await _item.pickImage();
                  },
                  child: SizedBox(
                    height: 100.0,
                    width: 130.0,
                    child: Center(
                      child: Image.network(
                        _image!.path,
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              // 제목 입력 필드
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 제목 입력 필드
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: '제목',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // 가격 입력 필드
                      TextField(
                        controller: priceController,
                        decoration: const InputDecoration(
                          labelText: '가격',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const SizedBox(width: 16),
              // 카테고리 선택 부분
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Row(
                  children: [
                    PopupMenuButton(
                      onSelected: (value) {
                        setState(() {
                          _selectedCategory = value.toString();
                        });
                      },
                      itemBuilder: (BuildContext context) {
                        List<PopupMenuEntry<String>> list = [];
                        for (String str in categoryImages.keys) {
                          list.add(
                            PopupMenuItem<String>(
                              value: str,
                              child: Text(str),
                            ),
                          );
                        }
                        return list;
                      },
                      child: const Text('카테고리 선택'),
                    ),
                    const SizedBox(width: 16),
                    Text('선택된 카테고리: $_selectedCategory'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 설명 입력 필드
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextField(
                controller: descriptionController,
                maxLines: null, // 가변적인 높이를 가지도록 설정
                expands: true, // 입력 내용에 따라 세로로 늘어나도록 설정
                decoration: const InputDecoration(
                  labelText: '설명',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
              onPressed: _modify,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16.0),
                minimumSize: Size(screenWidth, 0),
              ),
              child: const Text('수정'),
            ),
          ),
        ],
      ),
    );
  }
}
