import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kumohbada_ver2/backend.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'backend.dart';
import 'homepage.dart';

class Category extends StatelessWidget {
  Category({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('카테고리')),
      body: ListView.builder(
        itemCount: categoryImages.length,
        itemBuilder: (BuildContext context, int index) {
          final category = categoryImages.keys.elementAt(index);
          final imagePath = categoryImages[category];
          return ListTile(
            leading: imagePath != null
                ? Image.asset(imagePath, height: 24, width: 24)
                : const Icon(Icons.error),
            title: Text(category),
            onTap: () {
              context.read<MyCategory>().changeCategory(category: category);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (BuildContext context) {
                  return CategorySubPage();
                }),
              );
            },
          );
        },
      ),
    );
  }
}

class CategorySubPage extends StatefulWidget {
  const CategorySubPage({super.key});

  @override
  State<CategorySubPage> createState() => _CategorySubPageState();
}

class _CategorySubPageState extends State<CategorySubPage> {
  Item _item = Item();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _item.getCategoryItem(
          category: context.watch<MyCategory>().getCategory),
      builder: (BuildContext context, snapshot) {
        if (snapshot.data == null || !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return Container(
          color: Colors.white,
          child: ListView.separated(
            itemCount: snapshot.data.length,
            itemBuilder: (BuildContext context, int index) {
              DateTime date = snapshot.data[index][TIMESTAMP].toDate();
              String formattedTime = timeago.format(date, locale: 'ko');

              return Card(
                elevation: 0,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return HomeSubPage(item: snapshot.data[index]);
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
                            snapshot.data[index][IMAGE_URI] ?? '대체이미지_URL',
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
                                snapshot.data[index][TITLE],
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(snapshot.data[index][LOCATION]),
                                  const SizedBox(width: 5),
                                  const Text('•'),
                                  const SizedBox(width: 5),
                                  Text(formattedTime),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '${NumberFormat('#,###', 'ko_KR').format(snapshot.data[index][PRICE])}원',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
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
              return Divider(
                height: 1,
                color: const Color.fromARGB(136, 73, 73, 73).withOpacity(1),
                indent: 16, // 시작 부분의 공백
                endIndent: 16, // 끝 부분의 공백
              );
            },
          ),
        );
      },
    );
  }
}
