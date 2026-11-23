import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/content_controller.dart';

class RelacionarWidget extends StatefulWidget {
  final Map<String, dynamic> data;
  const RelacionarWidget({super.key, required this.data});

  @override
  State<RelacionarWidget> createState() => _RelacionarWidgetState();
}

class _RelacionarWidgetState extends State<RelacionarWidget> {
  late List<String> leftColumn;
  late List<String> rightColumn;
  String? selectedLeft;
  String? selectedRight;
  Map<String, String> currentConnections = {};
  late Map<String, String> correctPairs;

  @override
  void initState() {
    super.initState();
    _setupGame();
  }

  void _setupGame() {
    leftColumn = (widget.data['Columna_Izquierda'] as String).split(';').map((e) => e.trim()).toList();
    rightColumn = (widget.data['Columna_Derecha'] as String).split(';').map((e) => e.trim()).toList();
    
    correctPairs = {};
    final pairsList = (widget.data['Pares_Correctos'] as String).split(';').map((e) => e.trim());
    for (var pair in pairsList) {
      final parts = pair.split(':');
      if (parts.length == 2) {
        correctPairs[parts[0].trim()] = parts[1].trim();
      }
    }

    rightColumn.shuffle();
    currentConnections = {};
    selectedLeft = null;
    selectedRight = null;
  }

  void _onLeftTap(String item) {
    setState(() {
      if (selectedLeft == item) {
        selectedLeft = null;
      } else {
        selectedLeft = item;
        _checkMatch();
      }
    });
  }

  void _onRightTap(String item) {
    setState(() {
      if (selectedRight == item) {
        selectedRight = null;
      } else {
        selectedRight = item;
        _checkMatch();
      }
    });
  }

  void _checkMatch() {
    if (selectedLeft != null && selectedRight != null) {
      if (correctPairs[selectedLeft] == selectedRight) {
        currentConnections[selectedLeft!] = selectedRight!;
        selectedLeft = null;
        selectedRight = null;

        if (currentConnections.length == leftColumn.length) {
          context.read<ContentController>().allowNext();
          _showSuccess();
        }
      } else {
        selectedLeft = null;
        selectedRight = null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("¡Casi! No coinciden, intenta con otro par.", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            backgroundColor: const Color(0xFF7B5BA3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            duration: const Duration(milliseconds: 900),
          )
        );
      }
    }
  }

  void _showSuccess() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (context, a1, a2) => const SizedBox(),
      transitionDuration: const Duration(milliseconds: 260),
      transitionBuilder: (context, a1, a2, child) {
        final curveValue = Curves.easeOutBack.transform(a1.value);
        return Transform.scale(
          scale: curveValue,
          child: Opacity(
            opacity: a1.value.clamp(0.0, 1.0),
            child: AlertDialog(
            backgroundColor: const Color(0xFF5B3A82),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            title: const Icon(Icons.auto_awesome, color: Colors.yellowAccent, size: 70),
            content: Text(
              widget.data['Retroalimentacion'] ?? "¡Increíble! Has relacionado todo correctamente.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
                  child: const Text("¡GENIAL!", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFD4C5E0).withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.data['Instruccion'] ?? "Relaciona las columnas",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF5B3A82)),
            ),
          ),
          const SizedBox(height: 25),
          Expanded(
            child: Row(
              children: [
                _buildColumn(leftColumn, true),
                const SizedBox(width: 15),
                _buildColumn(rightColumn, false),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildProgress(),
        ],
      ),
    );
  }

  Widget _buildColumn(List<String> items, bool isLeft) {
    return Expanded(
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          bool isMatched = isLeft ? currentConnections.containsKey(item) : currentConnections.containsValue(item);
          bool isSelected = isLeft ? (selectedLeft == item) : (selectedRight == item);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ConnectCard(
              text: item,
              isMatched: isMatched,
              isSelected: isSelected,
              onTap: isMatched ? null : () => isLeft ? _onLeftTap(item) : _onRightTap(item),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgress() {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: currentConnections.length / leftColumn.length,
              minHeight: 12,
              backgroundColor: const Color(0xFFD4C5E0),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF08080)),
            ),
          ),
        ),
        const SizedBox(width: 15),
        Text(
          "${currentConnections.length}/${leftColumn.length}",
          style: const TextStyle(color: Color(0xFF5B3A82), fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _ConnectCard extends StatefulWidget {
  final String text;
  final bool isMatched;
  final bool isSelected;
  final VoidCallback? onTap;

  const _ConnectCard({required this.text, required this.isMatched, required this.isSelected, this.onTap});

  @override
  State<_ConnectCard> createState() => _ConnectCardState();
}

class _ConnectCardState extends State<_ConnectCard> with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 100), lowerBound: 0.0, upperBound: 0.05);
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor = Colors.white;
    Color borderColor = const Color(0xFFD4C5E0);
    Color textColor = const Color(0xFF5B3A82);

    if (widget.isMatched) {
      bgColor = const Color(0xFFE8F5E9);
      borderColor = Colors.green;
      textColor = Colors.green[800]!;
    } else if (widget.isSelected) {
      bgColor = const Color(0xFF5B3A82);
      borderColor = const Color(0xFF4A2F6A);
      textColor = Colors.white;
    }

    return GestureDetector(
      onTapDown: (_) => widget.onTap != null ? _anim.forward() : null,
      onTapUp: (_) { _anim.reverse(); if (widget.onTap != null) widget.onTap!(); },
      onTapCancel: () => _anim.reverse(),
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 - _anim.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor, width: 3),
                boxShadow: [
                  if (!widget.isMatched)
                    BoxShadow(color: borderColor.withOpacity(0.5), offset: const Offset(0, 4), blurRadius: 0),
                ],
              ),
              child: Center(
                child: Text(
                  widget.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: textColor),
                ),
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
