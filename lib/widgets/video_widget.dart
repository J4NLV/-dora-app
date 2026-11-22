import 'package:flutter/material.dart';

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
                Text("Cargando video...", style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 25),
          Text(
            data['Tema'] ?? "Sin título",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          Text(
            data['Explicación'] ?? "",
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }
}
