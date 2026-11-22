import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../controllers/content_controller.dart';
import 'pregunta_widget.dart';

class QuizWidget extends StatefulWidget {
  final List<dynamic> questions;
  const QuizWidget({super.key, required this.questions});

  @override
  State<QuizWidget> createState() => _QuizWidgetState();
}

class _QuizWidgetState extends State<QuizWidget> with TickerProviderStateMixin {
  int currentQuestionIndex = 0;
  late List<AnimationController> _scaleControllers;
  late List<AnimationController> _shakeControllers;

  @override
  void initState() {
    super.initState();
    _scaleControllers = List.generate(
      3,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      )..value = 1.0,
    );
    _shakeControllers = List.generate(
      3,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    for (var c in _scaleControllers) { c.dispose(); }
    for (var c in _shakeControllers) { c.dispose(); }
    super.dispose();
  }

  void _handleAnswer(bool isCorrect) {
    if (isCorrect) {
      _nextQuestion();
    } else {
      // Avanzar amigablemente a la siguiente pregunta tras equivocarse (sin bloqueos punitivos)
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _nextQuestion();
        }
      });
    }
  }

  void _nextQuestion() {
    if (currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      final controller = context.read<ContentController>();
      controller.allowNext();
      _showFinishDialog();
    }
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF5B3A82),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30), side: const BorderSide(color: Colors.white24, width: 2)),
        title: const Icon(Icons.heart_broken, color: Colors.white, size: 60),
        content: const Text(
          "¡Ánimo! Te has quedado sin vidas, pero cada error es una oportunidad para aprender. ¡Inténtalo de nuevo!",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF08080),
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
                context.read<ContentController>().resetLives();
              },
              child: const Text("REINTENTAR", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  void _showFinishDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF5B3A82),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: const Icon(Icons.emoji_events, color: Colors.yellowAccent, size: 70),
        content: const Text(
          "¡Felicidades! Has completado este reto con éxito.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7B5BA3),
                foregroundColor: Colors.white,
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
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ContentController>();
    final questionData = widget.questions[currentQuestionIndex];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            children: [
              Row(
                children: List.generate(3, (index) {
                  return AnimatedBuilder(
                    animation: _shakeControllers[index],
                    builder: (context, child) {
                      final sineValue = sin(_shakeControllers[index].value * 3 * pi);
                      return Transform.translate(
                        offset: Offset(sineValue * 8, 0),
                        child: ScaleTransition(
                          scale: _scaleControllers[index],
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              Icons.favorite,
                              color: index < controller.lives ? Colors.redAccent : Colors.grey[400],
                              size: 34,
                              shadows: [
                                if (index < controller.lives)
                                  const Shadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4)
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Container(
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: (currentQuestionIndex + 1) / widget.questions.length,
                      backgroundColor: Colors.transparent,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF08080)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Text(
                "${currentQuestionIndex + 1}/${widget.questions.length}",
                style: const TextStyle(color: Color(0xFF5B3A82), fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ],
          ),
        ),
        
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(15, 5, 15, 20),
            child: PreguntaWidget(
              key: ValueKey(currentQuestionIndex),
              data: questionData,
              onCorrect: () => _handleAnswer(true),
              onIncorrect: () => _handleAnswer(false),
              isInsideQuiz: true,
            ),
          ),
        ),
      ],
    );
  }
}
