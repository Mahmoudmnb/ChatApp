import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/chat_provider.dart';

class EmojiPickerBuilde extends StatelessWidget {
  const EmojiPickerBuilde({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.45,
      child: EmojiPicker(
        config: const Config(
          columns: 7,
          buttonMode: ButtonMode.MATERIAL,
        ),
        onEmojiSelected: (emoji, category) {
          context.read<ChatProvider>().onEmojiSelected(category);
        },
      ),
    );
  }
}
