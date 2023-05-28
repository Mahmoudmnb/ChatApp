import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/chat_provider.dart';

class AlternativeBottomInput extends StatelessWidget {
  const AlternativeBottomInput({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: double.infinity,
      decoration: const BoxDecoration(color: Colors.purple),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          context.watch<ChatProvider>().toMeSelectedMessage.length == 1 &&
                      context
                          .read<ChatProvider>()
                          .fromMeSelectedMessage
                          .isEmpty ||
                  context.watch<ChatProvider>().toMeSelectedMessage.isEmpty &&
                      context
                              .read<ChatProvider>()
                              .fromMeSelectedMessage
                              .length ==
                          1
              ? TextButton.icon(
                  onPressed: () {
                    context.read<ChatProvider>().replyOnTab();
                  },
                  label: const Text(
                    'reply',
                    style: TextStyle(fontSize: 20),
                  ),
                  icon: const Icon(Icons.arrow_back))
              : const SizedBox.shrink(),
          TextButton.icon(
              onPressed: () {
                context.read<ChatProvider>().convertMessageOnTab(context);
              },
              label: const Text(
                'Convert',
                style: TextStyle(fontSize: 20),
              ),
              icon: const Icon(Icons.arrow_forward)),
        ],
      ),
    );
  }
}
