import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/content_controller.dart';

class PreguntaWidget extends StatefulWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onCorrect;
  final VoidCallback? onIncorrect;
  final bool isInsideQuiz;

  const PreguntaWidget({
    super.key, 
    required this.data, 
    this.onCorrect, 
    this.onIncorrect,
    this.isInsideQuiz = false,
  });

  @override
  State<PreguntaWidget> createState() => _PreguntaWidgetState();
}

class _PreguntaWidgetState extends State<PreguntaWidget> with TickerProviderStateMixin {
  int? selectedIndex;
  bool answered = false;

  @override
  Widget build(BuildContext context) {
    final controller = context.read<ContentController>();
    final pregunta = widget.data['Pregunta'] ?? '¿Sin pregunta?';
    final opciones = [
      widget.data['Opcion_1'],
      widget.data['Opcion_2'],
      widget.data['Opcion_3'],
      widget.data['Opcion_4'],
    ].where((o) => o != null).toList();
    
    final correcta = widget.data['Respuesta_Correcta_Texto'];

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(color: const Color(0xFF5B3A82).withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            pregunta, 
            style: const TextStyle(
              fontSize: 24, 
              fontWeight: FontWeight.w900, 
              color: Color(0xFF5B3A82),
              height: 1.2,
            )
          ),
          const SizedBox(height: 30),
          Expanded(
            child: ListView.builder(
              itemCount: opciones.length,
              itemBuilder: (context, index) {
                final opcion = opciones[index];
                String cleanOpcion = opcion.toString().replaceAll('\r', '').replaceAll('\\n', '\n').trim();
                String cleanCorrecta = (correcta ?? '').toString().replaceAll('\r', '').replaceAll('\\n', '\n').trim();
                bool isCorrect = cleanOpcion == cleanCorrecta;
                bool isSelected = selectedIndex == index;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _OptionCard(
                    text: opcion.toString(),
                    index: index,
                    isSelected: isSelected,
                    isCorrect: answered ? isCorrect : null,
                    onTap: answered ? null : () {
                      setState(() {
                        selectedIndex = index;
                        answered = true;
                      });
                      
                      Future.delayed(const Duration(milliseconds: 600), () {
                        if (isCorrect) {
                          if (widget.onCorrect != null) widget.onCorrect!();
                          if (!widget.isInsideQuiz) controller.allowNext();
                        } else {
                          if (widget.onIncorrect != null) widget.onIncorrect!();
                        }
                        _mostrarResultado(context, isCorrect, widget.data['Retroalimentacion']);
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarResultado(BuildContext context, bool esCorrecta, String? retro) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Resultado",
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.elasticOut),
          child: AlertDialog(
            backgroundColor: esCorrecta ? const Color(0xFFE8F5E9) : const Color(0xFFEDE7F6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30), 
              side: BorderSide(color: esCorrecta ? Colors.green : const Color(0xFF7B5BA3), width: 3)
            ),
            title: Icon(
              esCorrecta ? Icons.stars_rounded : Icons.lightbulb_outline_rounded, 
              color: esCorrecta ? Colors.green : const Color(0xFF7B5BA3), 
              size: 80
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  esCorrecta ? "¡INCREÍBLE!" : "¡SIGUE INTENTANDO!", 
                  style: TextStyle(
                    fontSize: 26, 
                    fontWeight: FontWeight.w900, 
                    color: esCorrecta ? Colors.green[800] : const Color(0xFF5B3A82)
                  )
                ),
                const SizedBox(height: 15),
                Text(
                  retro ?? "", 
                  textAlign: TextAlign.center, 
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)
                ),
              ],
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B3A82),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 5,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    if (mounted) {
                      setState(() {
                        answered = false;
                        selectedIndex = null;
                      });
                    }
                  },
                  child: const Text("ENTENDIDO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ),
              )
            ],
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 600),
    );
  }
}

class _OptionCard extends StatefulWidget {
  final String text;
  final int index;
  final bool isSelected;
  final bool? isCorrect; 
  final VoidCallback? onTap;

  const _OptionCard({required this.text, required this.index, required this.isSelected, this.isCorrect, this.onTap});

  @override
  State<_OptionCard> createState() => _OptionCardState();
}

class _OptionCardState extends State<_OptionCard> with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 150), lowerBound: 0.0, upperBound: 0.05);
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor = const Color(0xFFF3E5F5);
    Color borderColor = const Color(0xFFD1C4E9);
    
    if (widget.isSelected) {
      if (widget.isCorrect == true) {
        bgColor = Colors.green[100]!;
        borderColor = Colors.green;
      } else if (widget.isCorrect == false) {
        bgColor = const Color(0xFFEDE7F6);
        borderColor = const Color(0xFF7B5BA3);
      } else {
        bgColor = const Color(0xFFCE93D8);
        borderColor = const Color(0xFF5B3A82);
      }
    }

    return GestureDetector(
      onTapDown: (_) => widget.onTap != null ? _anim.forward() : null,
      onTapUp: (_) {
        if (widget.onTap != null) {
          _anim.reverse();
          widget.onTap!();
        }
      },
      onTapCancel: () => _anim.reverse(),
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 - _anim.value,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: borderColor, width: 3),
                boxShadow: [
                  BoxShadow(color: borderColor.withOpacity(0.3), offset: const Offset(0, 4), blurRadius: 0),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 35, height: 35,
                    decoration: BoxDecoration(color: borderColor, shape: BoxShape.circle),
                    child: Center(
                      child: Text("${String.fromCharCode(65 + widget.index)}", 
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      widget.text, 
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A2F6A))
                    )
                  ),
                  if (widget.isCorrect == true && widget.isSelected) const Icon(Icons.check_circle, color: Colors.green),
                  if (widget.isCorrect == false && widget.isSelected) const Icon(Icons.info_outline, color: Color(0xFF7B5BA3)),
                ],
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
