import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/content_controller.dart';
import '../state/player_state_notifier.dart';
import 'pregunta_widget.dart';

class QuizWidget extends StatefulWidget {
  final List<dynamic> questions;
  const QuizWidget({super.key, required this.questions});

  @override
  State<QuizWidget> createState() => _QuizWidgetState();
}

class _QuizWidgetState extends State<QuizWidget> {
  int currentQuestionIndex = 0;
  int correctAnswers = 0;
  bool isRewardAwarded = false;

  void _handleAnswer(bool isCorrect) {
    if (isCorrect) {
      correctAnswers++;
    }
    _nextQuestion();
  }

  void _nextQuestion() {
    if (currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      final controller = context.read<ContentController>();
      controller.allowNext();
      _awardDoracoinsAndShowSummary();
    }
  }

  void _awardDoracoinsAndShowSummary() {
    if (isRewardAwarded) return;
    isRewardAwarded = true;

    final total = widget.questions.length;
    final percentage = total > 0 ? (correctAnswers / total) * 100 : 0.0;

    int earnedDoracoins = 10;
    if (percentage >= 100.0) {
      earnedDoracoins = 100;
    } else if (percentage >= 70.0) {
      earnedDoracoins = 60;
    } else {
      earnedDoracoins = 10;
    }

    // Acreditar Doracoins al jugador
    context.read<PlayerStateNotifier>().addDoracoins(earnedDoracoins);

    _showResultsDialog(
      correct: correctAnswers,
      total: total,
      coins: earnedDoracoins,
      percentage: percentage,
    );
  }

  void _restartQuiz() {
    setState(() {
      currentQuestionIndex = 0;
      correctAnswers = 0;
      isRewardAwarded = false;
    });
  }

  void _showResultsDialog({
    required int correct,
    required int total,
    required int coins,
    required double percentage,
  }) {
    final controller = context.read<ContentController>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF5B3A82),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: const BorderSide(color: Colors.white24, width: 2),
        ),
        title: Column(
          children: [
            Icon(
              percentage >= 70.0 ? Icons.emoji_events_rounded : Icons.lightbulb_rounded,
              color: Colors.yellowAccent,
              size: 70,
            ),
            const SizedBox(height: 10),
            Text(
              percentage >= 100.0
                  ? "¡PERFECTO!"
                  : percentage >= 70.0
                      ? "¡MUY BIEN HECHO!"
                      : "¡BUEN INTENTO!",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Puntuación obtenida
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: Colors.greenAccent, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    "Puntuación: $correct / $total (${percentage.toInt()}%)",
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Monedas ganadas en base a puntuación
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber, width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.monetization_on, color: Colors.yellowAccent, size: 30),
                  const SizedBox(width: 8),
                  Text(
                    "+$coins Doracoins",
                    style: const TextStyle(color: Colors.yellowAccent, fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Botón 1: Siguiente lección
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF5B3A82)),
                label: const Text("SIGUIENTE LECCIÓN", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF5B3A82),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 4,
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  controller.nextLeccion();
                },
              ),
            ),
            const SizedBox(height: 10),

            // Botón 2: Volver a intentar
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.replay_rounded, color: Colors.white),
                label: const Text("VOLVER A INTENTAR", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white70, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  _restartQuiz();
                },
              ),
            ),
            const SizedBox(height: 8),

            // Botón 3: Regresar al menú / camino de enseñanza
            TextButton.icon(
              icon: const Icon(Icons.home_rounded, color: Colors.white70, size: 20),
              label: const Text("Regresar al camino", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final questionData = widget.questions[currentQuestionIndex];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF5B3A82),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline_rounded, color: Colors.yellowAccent, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      "Reto",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (currentQuestionIndex + 1) / widget.questions.length,
                    minHeight: 12,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.yellowAccent),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Text(
                "${currentQuestionIndex + 1}/${widget.questions.length}",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
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
