import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'backend.dart';
import 'homepage.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  Item _item = Item();

  List<Map<String, dynamic>> filteredItems = [];
  String? str;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0.0,
        title: TextField(
          controller: _controller,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(25.0)),
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            child: const Text("검색"),
            onPressed: () {
              setState(() {
                str = _controller.text;
              });
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: _item.searchItem(str: str),
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
