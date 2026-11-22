import 'package:flutter/material.dart';
import 'rich_text_helper.dart';

class VideoWidget extends StatelessWidget {
  final Map<String, dynamic> data;

  const VideoWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_circle_fill, color: Colors.white, size: 60),
                SizedBox(height: 10),
                Text("Video de YouTube próximamente", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 25),
          FormattedText(
            text: data['Tema'] ?? "Sin título",
            baseStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            boldStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.yellowAccent),
          ),
          const SizedBox(height: 15),
          FormattedText(
            text: data['Explicación'] ?? "",
            baseStyle: const TextStyle(fontSize: 16, height: 1.5, color: Colors.white),
            boldStyle: const TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.w900, color: Colors.yellowAccent),
          ),
        ],
      ),
    );
  }
}

