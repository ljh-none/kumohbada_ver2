import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'backend.dart';
import 'category.dart';

class RegistItemPage extends StatefulWidget {
  const RegistItemPage({super.key});

  @override
  State<RegistItemPage> createState() => _RegistItemPageState();
}

class _RegistItemPageState extends State<RegistItemPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  XFile? _image;
  String _selectedCategory = '디지털기기'; // 선택된 카테고리를 저장할 변수
  final Item _item = Item();

  // 글을 제출 또는 수정하는 함수
  _submit() async {
    String title = titleController.text;
    String price = priceController.text;
    String description = descriptionController.text;

    // 이미지, 제목, 가격, 설명, 선택된 카테고리로 새로운 Item 생성
    var result = await _item.registItem(
      image: _image!,
      title: title,
      category: _selectedCategory,
      price: int.parse(price),
      description: description,
    );
    if (result == null) {
      return;
    }
    _returnToHomePage();
  }

  //async gap 경고에 때문에 함수로 작성.
  _returnToHomePage() => Navigator.pop(context, true);

  // 카테고리를 선택하는 함수
  Future<void> _selectCategory() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Category()),
    );

    if (result != null) {
      setState(() {
        if (result is String) {
          // Handle the case where result is a String
          _selectedCategory = result;
        } else if (result is Map<String, dynamic> &&
            result.containsKey('category')) {
          // Handle the case where result is a Map and contains 'category' key
          _selectedCategory = result['category'];
        }
      });
    }
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
                      child: Image.file(
                        File(_image!.path),
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
                    ElevatedButton(
                      onPressed: _selectCategory,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18.0), // 버튼 내부의 내용과의 간격 조절
                      ),
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
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16.0),
                minimumSize: Size(screenWidth, 0),
              ),
              child: const Text('제출'),
            ),
          ),
        ],
      ),
    );
  }
}
