import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kumohbada_ver2/chatpage.dart';
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
      print("!load More Data");
      var result = await _item.getMoreItem(time: time);
      if (result.isEmpty) {
        return;
      }
      setState(() => list.addAll(result));
      print("!add ${result[0]}");
    }

    return FutureBuilder(
        future: _item.startItemStream(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            list.addAll(snapshot.data!);
            return Container(
              color: Colors.white,
              child: ListView.separated(
                itemCount: list.length,
                itemBuilder: (BuildContext context, int index) {
                  if (index == list.length - 1) {
                    //스크롤 무한로딩
                    loadMoreData(list[index][TIMESTAMP]);
                  }
                  DateTime date = list[index][TIMESTAMP].toDate();
                  String formattedTime = timeago.format(date, locale: 'ko');
                  return Card(
                    elevation: 0,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (BuildContext context) {
                            return HomeSubPage(item: list[index]);
                          }),
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
                },
                separatorBuilder: (BuildContext context, int index) {
                  // 각 아이템 사이에 Divider 추가
                  return Divider(
                    height: 1,
                    color: Color.fromARGB(136, 73, 73, 73)!.withOpacity(1),
                    indent: 16, // 시작 부분의 공백
                    endIndent: 16, // 끝 부분의 공백
                  );
                },
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}

class HomeSubPage extends StatefulWidget {
  Map<String, dynamic> item;
  HomeSubPage({Key? key, required this.item}) : super(key: key);

  @override
  State<HomeSubPage> createState() => _HomeSubPageState();
}

class _HomeSubPageState extends State<HomeSubPage> {
  @override
  Widget build(BuildContext context) {
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
                      backgroundImage: NetworkImage(widget.item[IMAGE_URI]),
                    ),
                    SizedBox(width: 8.0),
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
                            (index) => Icon(Icons.star, color: Colors.orange)),
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
                  Chat chat = Chat();
                  String? myuid = MyUser.instance.getUid;
                  if (myuid! == widget.item[UID]) {
                    return;
                  } else if (await chat.noRoomExist(
                      itemid: widget.item[ITEMID])) {
                    await chat.createChattingRoom(
                      receiver: widget.item[REGISTER],
                      receiveruid: widget.item[UID],
                      itemId: widget.item[ITEMID],
                    );
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) =>
                          ChatSubPage(widget.item[ITEMID]),
                    ),
                  );
                },
                child: const Text("채팅하기"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
