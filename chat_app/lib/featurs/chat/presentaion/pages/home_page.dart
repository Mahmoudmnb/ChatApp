import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/domain/entities/user.dart';
import '../providers/chat_provider.dart';

import 'chat_page.dart';

class HomePage extends StatefulWidget {
  final UserEntity user;
  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    var data = FirebaseFirestore.instance
        .collection('users')
        .where('number', isNotEqualTo: widget.user.phoneNamber)
        .snapshots(includeMetadataChanges: true);
    return Scaffold(
      appBar: !context.watch<ChatProvider>().isConvertedMode
          ? AppBar(
              title: const Text('Chat App'),
              actions: const [Icon(Icons.search)],
            )
          : AppBar(
              title: const Text('convert to ...'),
              leading: IconButton(
                  onPressed: () {
                    context.read<ChatProvider>().setConvertedMode = false;
                  },
                  icon: const Icon(Icons.arrow_back)),
            ),
      body: Center(
        child: StreamBuilder(
            stream: data,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) => Column(
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 10, left: 10, right: 10),
                        child: ListTile(
                          onTap: () async {
                            context.read<ChatProvider>().friend =
                                UserEntity.fromJson(
                                    snapshot.data!.docs[index].data());
                            String chatId =
                                await context.read<ChatProvider>().createChat();
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ChatePage(
                                  chatId: chatId,
                                  friend: UserEntity.fromJson(
                                      snapshot.data!.docs[index].data())),
                            ));
                          },
                          leading: const CircleAvatar(
                            backgroundColor: Colors.pinkAccent,
                          ),
                          tileColor: Colors.amber,
                          selectedTileColor: Colors.pinkAccent[100],
                          title:
                              Text(snapshot.data!.docs[index].data()['name']),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return const Text('no data');
              }
            }),
      ),
      drawer: const Drawer(),
    );
  }
}
