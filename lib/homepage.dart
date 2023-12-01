import 'package:flutter/material.dart';
import 'backend.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

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
                    loadMoreData(list[index][TIMESTAMP]);
                  }
                  return Card(
                    elevation: 0,
                    child: InkWell(
                      onTap: () {},
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
                                      Text("formattedTime"),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '${NumberFormat('#,###', 'ko_KR').format(list[index][PRICE])}원',
                                    style: TextStyle(
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
            return const CircularProgressIndicator();
          }
        });
  }
}
