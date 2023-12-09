import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'backend.dart';
import 'homepage.dart';

class MyItemPage extends StatefulWidget {
  const MyItemPage({super.key});

  @override
  State<MyItemPage> createState() => _MyItemPageState();
}

class _MyItemPageState extends State<MyItemPage> {
  Item _item = Item();
  Chat _chat = Chat();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('내 글 보기')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _item.getMyItems(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Container(
              color: Colors.white,
              child: ListView.separated(
                itemCount: snapshot.data!.length,
                itemBuilder: (BuildContext context, int index) {
                  DateTime date = snapshot.data![index][TIMESTAMP].toDate();
                  String formattedTime = timeago.format(date, locale: 'ko');

                  return Card(
                    elevation: 0,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return HomeSubPage(item: snapshot.data![index]);
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
                                snapshot.data![index][IMAGE_URI] ?? '대체이미지_URL',
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
                                    snapshot.data![index][TITLE],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(snapshot.data![index][LOCATION]),
                                      const SizedBox(width: 5),
                                      const Text('•'),
                                      const SizedBox(width: 5),
                                      Text(formattedTime),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '${NumberFormat('#,###', 'ko_KR').format(snapshot.data![index][PRICE])}원',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                await _chat.deleteChat(
                                    itemId: snapshot.data![index][ITEMID]);
                                await _item.deleteItem(
                                    itemId: snapshot.data![index][ITEMID]);
                                setState(() {});
                              },
                              icon: const Icon(Icons.delete),
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
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available'));
          } else {
            return const Center(child: Text("err!"));
          }
        },
      ),
    );
  }
}
