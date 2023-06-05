import 'package:chat_app/core/constant.dart';
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
        .collection('messages')
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
                  itemBuilder: (context, index) {
                    print(snapshot.data!.docs[index].data());
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 10, left: 10, right: 10),
                          child: ListTile(
                            trailing: StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('messages')
                                  .doc(snapshot.data!.docs[index].id)
                                  .collection('msg')
                                  .where('to',
                                      isEqualTo:
                                          Constant.currentUsre.phoneNamber)
                                  .where('isReseved', isEqualTo: false)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                return CircleAvatar(
                                  child: Text(
                                      (snapshot.data?.docs.length).toString()),
                                );
                              },
                            ),
                            onTap: () async {
                              Map<String, dynamic> map = {
                                'name': snapshot.data!.docs[index]
                                            .data()['toName'] ==
                                        Constant.currentUsre.name
                                    ? snapshot.data!.docs[index]
                                        .data()['fromName']
                                    : snapshot.data!.docs[index]
                                        .data()['toName'],
                                'number': snapshot.data!.docs[index]
                                            .data()['to'] ==
                                        Constant.currentUsre.phoneNamber
                                    ? snapshot.data!.docs[index].data()['from']
                                    : snapshot.data!.docs[index].data()['to'],
                              };
                              context.read<ChatProvider>().friend =
                                  UserEntity.fromJson(map);
                              String chatId = await context
                                  .read<ChatProvider>()
                                  .createChat();
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ChatePage(
                                    chatId: chatId,
                                    friend: UserEntity.fromJson(map)),
                              ));
                            },
                            leading: const CircleAvatar(
                              backgroundColor: Colors.pinkAccent,
                            ),
                            tileColor: Colors.amber,
                            selectedTileColor: Colors.pinkAccent[100],
                            title: Text(snapshot.data!.docs[index]
                                .data()['toName']
                                .toString()),
                          ),
                        ),
                      ],
                    );
                  },
                );
              } else {
                return const Text('no data');
              }
            }),
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            showModalBottomSheet(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15))),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              context: context,
              builder: (ctx) {
                return StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('number',
                          isNotEqualTo: Constant.currentUsre.phoneNamber)
                      .snapshots(),
                  builder: (context, snapshot) => snapshot.hasData
                      ? ListView.builder(
                          itemCount: snapshot.data?.docs.length,
                          itemBuilder: (context, index) => ListTile(
                            title:
                                Text(snapshot.data!.docs[index].data()['name']),
                            onTap: () async {
                              context.read<ChatProvider>().friend =
                                  UserEntity.fromJson(
                                      snapshot.data!.docs[index].data());
                              String chatId = await context
                                  .read<ChatProvider>()
                                  .createChat();
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ChatePage(
                                    chatId: chatId,
                                    friend: UserEntity.fromJson(
                                        snapshot.data!.docs[index].data())),
                              ));
                            },
                          ),
                        )
                      : const Text('Please wait'),
                );
              },
            );
          }),
      drawer: const Drawer(),
    );
  }
}
