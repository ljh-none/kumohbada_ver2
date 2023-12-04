import 'package:flutter/material.dart';
import 'package:kumohbada_ver2/backend.dart';
import 'package:provider/provider.dart';

class Category extends StatelessWidget {
  Category({super.key});

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
              Navigator.pop(context, category);
            },
          );
        },
      ),
    );
  }
}
