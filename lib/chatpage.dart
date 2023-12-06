import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'backend.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Chat _chat = Chat();
  Item _item = Item();
  MyUser _myUser = MyUser.instance;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _chat.showChatList(),
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return ListView.separated(
            itemBuilder: (BuildContext context, index) {
              return GestureDetector(
                onTap: () async {
                  Map<String, dynamic>? item = await _item.getSingleItem(
                      itemId: snapshot.data[index][ITEMID]);
                  if (item == null) return;

                  gotoChatting(item, snapshot, index);
                },
                child: ListTile(
                    leading: Image.network(snapshot.data[index]
                        [IMAGE_URI]), // Add an icon for each chat item
                    title: Text(snapshot.data[index][TITLE],
                        style: const TextStyle(fontSize: 20)),
                    subtitle:
                        snapshot.data[index][RECEIVER_UID] == _myUser.getUid
                            ? Text(snapshot.data[index][RECEIVER])
                            : Text(snapshot.data[index][SENDER])),
              );
            },
            separatorBuilder: _buildSeparator,
            itemCount: snapshot.data.length,
          );
        } else if (!snapshot.hasData) {
          return const Center(child: Text("No chat exist"));
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  Future<dynamic> gotoChatting(
      Map<String, dynamic> item, AsyncSnapshot<dynamic> snapshot, int index) {
    return Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) {
      return ChatSubPage(item, snapshot.data[index][SENDER_UID]);
    }));
  }

  Widget _buildSeparator(BuildContext context, index) {
    return Divider(
      height: 1,
      color: const Color.fromARGB(136, 73, 73, 73).withOpacity(1),
      indent: 16, // 시작 부분의 공백
      endIndent: 16, // 끝 부분의 공백
    );
  }
}

class ChatSubPage extends StatefulWidget {
  Map<String, dynamic>? _item;
  String? _senderUid;
  ChatSubPage(item, senderUid, {super.key}) {
    _item = item;
    _senderUid = senderUid;
  }

  @override
  State<ChatSubPage> createState() {
    return _ChatSubPageState();
  }
}

class _ChatSubPageState extends State<ChatSubPage> {
  TextEditingController txtcontrollor = TextEditingController();
  final MyUser _myUser = MyUser.instance;
  final Chat _chat = Chat();

  Widget buildChatContent(context, AsyncSnapshot<QuerySnapshot> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
      return const Text("err!");
    }
    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return const Text("no data");
    }

    return ListView.builder(
      itemCount: snapshot.data!.docs.length,
      reverse: true,
      itemBuilder: (context, index) {
        var doc = snapshot.data!.docs[index];
        var data = doc.data() as Map<String, dynamic>;
        if (data[SENDER_UID] == _myUser.getUid) {
          return Row(children: [
            const Spacer(),
            Container(
                padding: const EdgeInsets.all(10.0),
                margin: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 20.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  data[CONTENT],
                  style: const TextStyle(color: Colors.white, fontSize: 16.0),
                )),
          ]);
        } else {
          return Row(children: [
            Container(
                padding: const EdgeInsets.all(10.0),
                margin: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 20.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  data[CONTENT],
                  style: const TextStyle(color: Colors.white, fontSize: 16.0),
                )),
            const Spacer(),
          ]);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget._item![REGISTER])),
      body: StreamBuilder(
        stream: _chat.getChatStream(
            item: widget._item!, senderUid: widget._senderUid!),
        builder: buildChatContent,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: txtcontrollor,
              decoration: const InputDecoration(
                labelText: "텍스트를 입력하세요",
                border: OutlineInputBorder(),
                fillColor: Colors.white,
                filled: true,
              ),
              onSubmitted: (text) {
                _chat.sendMessage(msg: txtcontrollor.text);
                txtcontrollor.clear();
              },
            ),
          ),
          const SizedBox(width: 10.0),
          ElevatedButton(
            onPressed: () {
              _chat.sendMessage(msg: txtcontrollor.text);
              txtcontrollor.clear();
            },
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
            ),
            child: const Icon(Icons.send),
          )
        ]),
      ),
    );
  }
}
