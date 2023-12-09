import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kumohbada_ver2/chatpage.dart';
import 'package:kumohbada_ver2/registitempage.dart';
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
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Text(
                        '가격 : ${NumberFormat('#,###', 'ko_KR').format(widget.item[PRICE])}원'),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () async {
                        if (_myUser.getUid == widget.item[UID]) {
                          gotoModifyPage(widget.item);
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

  gotoChatting() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (BuildContext context) {
        return ChatSubPage(widget.item, _myUser.getUid);
      }),
    );
  }

  gotoModifyPage(Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (BuildContext context) {
        return ModifyItemPage(item);
      }),
    );
  }
}
