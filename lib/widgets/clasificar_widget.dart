import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/content_controller.dart';

class ClasificarWidget extends StatefulWidget {
  final Map<String, dynamic> data;
  const ClasificarWidget({super.key, required this.data});

  @override
  State<ClasificarWidget> createState() => _ClasificarWidgetState();
}

class _ClasificarWidgetState extends State<ClasificarWidget> with TickerProviderStateMixin {
  late List<String> items;
  late List<String> categories;
  int currentIndex = 0;
  Map<String, List<String>> userClassification = {};
  late AnimationController _cardController;
  late Animation<double> _cardScale;

  @override
  void initState() {
    super.initState();
    items = (widget.data['Items'] as String).split(';').map((e) => e.trim()).toList();
    categories = (widget.data['Categorias'] as String).split(';').map((e) => e.trim()).toList();
    for (var cat in categories) {
      userClassification[cat] = [];
    }
    
    _cardController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _cardScale = Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeInBack));
  }

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  void _classify(String category) {
    _cardController.forward().then((_) {
      setState(() {
        userClassification[category]!.add(items[currentIndex]);
        if (currentIndex < items.length - 1) {
          currentIndex++;
          _cardController.reverse();
        } else {
          context.read<ContentController>().allowNext();
          _showResults();
        }
      });
    });
  }

  void _showResults() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (context, a1, a2) => const SizedBox(),
      transitionBuilder: (context, a1, a2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: a1, curve: Curves.elasticOut),
          child: AlertDialog(
            backgroundColor: const Color(0xFF5B3A82),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            title: const Icon(Icons.stars_rounded, color: Colors.yellowAccent, size: 70),
            content: SingleChildScrollView(
              child: Text(
                widget.data['Retroalimentacion'] ?? "¡Excelente clasificación!",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF5B3A82),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("¡CONTINUAR!", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentIndex >= items.length) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF5B3A82)));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFD4C5E0).withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.data['Instruccion'] ?? "",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF5B3A82)),
            ),
          ),
          const Spacer(),
          ScaleTransition(
            scale: _cardScale,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFF5B3A82), width: 4),
                boxShadow: const [
                  BoxShadow(color: Color(0xFF5B3A82), offset: Offset(0, 8), blurRadius: 0),
                ],
              ),
              child: Text(
                items[currentIndex],
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF5B3A82)),
              ),
            ),
          ),
          const Spacer(),
          const Text("CLASIFICA EN:", style: TextStyle(color: Color(0xFF5B3A82), fontWeight: FontWeight.w900, letterSpacing: 1.2)),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: categories.map((cat) => _CategoryButton(
              text: cat,
              onTap: () => _classify(cat),
            )).toList(),
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (currentIndex + 1) / items.length,
                    minHeight: 12,
                    backgroundColor: const Color(0xFFD4C5E0),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF08080)),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Text(
                "${currentIndex + 1}/${items.length}",
                style: const TextStyle(color: Color(0xFF5B3A82), fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  const _CategoryButton({required this.text, required this.onTap});

  @override
  State<_CategoryButton> createState() => _CategoryButtonState();
}

class _CategoryButtonState extends State<_CategoryButton> with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 100), lowerBound: 0.0, upperBound: 0.1);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _anim.forward(),
      onTapUp: (_) { _anim.reverse(); widget.onTap(); },
      onTapCancel: () => _anim.reverse(),
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 - _anim.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF5B3A82),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Color(0xFF3E2759), offset: Offset(0, 4), blurRadius: 0),
                ],
              ),
              child: Text(
                widget.text.toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
              ),
            ),
          );
        },
      ),
    );
  }
  @override
  void dispose() { _anim.dispose(); super.dispose(); }
}
