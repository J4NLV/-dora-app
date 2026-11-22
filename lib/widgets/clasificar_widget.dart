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
  late Map<String, String> itemToCategory;
  late Map<String, String> itemFeedbacks;
  int currentIndex = 0;
  int correctCount = 0;
  bool isShowingFeedback = false;
  late AnimationController _cardController;
  late Animation<double> _cardScale;

  @override
  void initState() {
    super.initState();
    items = (widget.data['Items'] as String).split(';').map((e) => e.trim()).toList();
    categories = (widget.data['Categorias'] as String).split(';').map((e) => e.trim()).toList();
    _parseAnswersAndFeedbacks();
    
    _cardController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _cardScale = Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeInBack));
  }

  void _parseAnswersAndFeedbacks() {
    itemToCategory = {};
    itemFeedbacks = {};

    // Parse Clasificacion_Correcta: "Cat1: itemA, itemB; Cat2: itemC"
    final rawCorrect = widget.data['Clasificacion_Correcta'] as String? ?? "";
    final catBlocks = rawCorrect.split(';');
    for (var block in catBlocks) {
      final parts = block.split(':');
      if (parts.length >= 2) {
        final catName = parts[0].trim();
        final itemsInCat = parts[1].split(',').map((e) => e.trim()).toList();
        for (var it in itemsInCat) {
          if (it.isNotEmpty) {
            itemToCategory[it] = catName;
          }
        }
      }
    }

    // Parse Retroalimentacion: "itemA: explicacion; itemB: explicacion"
    final rawRetro = widget.data['Retroalimentacion'] as String? ?? "";
    final retroBlocks = rawRetro.split(';');
    for (var block in retroBlocks) {
      final parts = block.split(':');
      if (parts.length >= 2) {
        final itemKey = parts[0].trim();
        final feedbackText = parts.sublist(1).join(':').trim();
        itemFeedbacks[itemKey] = feedbackText;
      }
    }
  }

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  void _classify(String chosenCategory) {
    if (isShowingFeedback) return;

    final currentItem = items[currentIndex];
    final correctCat = itemToCategory[currentItem] ?? "";
    
    // Comparar categoría elegida con la correcta (normalizado para nombres largos o siglas)
    bool isCorrect = chosenCategory.trim().toLowerCase() == correctCat.trim().toLowerCase() ||
        (correctCat.isNotEmpty && (chosenCategory.toLowerCase().startsWith(correctCat.toLowerCase()) || 
                                   correctCat.toLowerCase().startsWith(chosenCategory.toLowerCase())));

    if (isCorrect) {
      correctCount++;
    }

    final specificFeedback = itemFeedbacks[currentItem];

    setState(() {
      isShowingFeedback = true;
    });

    _showItemFeedback(
      isCorrect: isCorrect,
      item: currentItem,
      correctCat: correctCat.isNotEmpty ? correctCat : chosenCategory,
      explanation: specificFeedback,
      onDismiss: () {
        setState(() {
          isShowingFeedback = false;
        });

        _cardController.forward().then((_) {
          if (currentIndex < items.length - 1) {
            setState(() {
              currentIndex++;
            });
            _cardController.reverse();
          } else {
            context.read<ContentController>().allowNext();
            _showSummaryResults();
          }
        });
      },
    );
  }

  void _showItemFeedback({
    required bool isCorrect,
    required String item,
    required String correctCat,
    String? explanation,
    required VoidCallback onDismiss,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (context, a1, a2) => const SizedBox(),
      transitionBuilder: (context, a1, a2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: a1, curve: Curves.elasticOut),
          child: AlertDialog(
            backgroundColor: isCorrect ? const Color(0xFFE8F5E9) : const Color(0xFFEDE7F6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: BorderSide(
                color: isCorrect ? Colors.green : const Color(0xFF7B5BA3),
                width: 3,
              ),
            ),
            title: Icon(
              isCorrect ? Icons.check_circle_rounded : Icons.lightbulb_outline_rounded,
              color: isCorrect ? Colors.green : const Color(0xFF7B5BA3),
              size: 65,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isCorrect ? "¡CORRECTO!" : "¡AQUÍ APRENDEMOS!",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: isCorrect ? Colors.green[800] : const Color(0xFF5B3A82),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0xFF5B3A82).withOpacity(0.2)),
                  ),
                  child: Text(
                    "$item  ➔  $correctCat",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF5B3A82)),
                  ),
                ),
                if (explanation != null && explanation.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    explanation,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                ],
              ],
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B3A82),
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 12),
                    elevation: 4,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    onDismiss();
                  },
                  child: const Text("CONTINUAR", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  void _showSummaryResults() {
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
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "¡Reto completado!",
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                Text(
                  "Aciertos: $correctCount de ${items.length}",
                  style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
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
