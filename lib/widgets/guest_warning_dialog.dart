import 'package:flutter/material.dart';

/// Dialog to warn users about guest mode limitations
class GuestWarningDialog extends StatelessWidget {
  final VoidCallback onContinueAsGuest;
  final VoidCallback onCreateAccount;

  const GuestWarningDialog({
    Key? key,
    required this.onContinueAsGuest,
    required this.onCreateAccount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: const Color(0xFFE8CCDC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF5B3A82), width: 3),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Warning icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF7B5BA3),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF5B3A82), width: 3),
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            const Text(
              '¡Atención!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Color(0xFF5B3A82),
              ),
            ),
            const SizedBox(height: 16),

            // Warning message
            const Text(
              'Si continúas como invitado, tu progreso podría perderse si desinstalas la aplicación o cambias de dispositivo.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Te recomendamos crear una cuenta para guardar tu progreso de forma segura.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5B3A82),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // Buttons
            Column(
              children: [
                // Create account button (primary)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onCreateAccount();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B3A82),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'Crear cuenta',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Continue as guest button (secondary)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onContinueAsGuest();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF5B3A82),
                      side: const BorderSide(
                        color: Color(0xFF5B3A82),
                        width: 2.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Continuar como invitado',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Show the dialog
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onContinueAsGuest,
    required VoidCallback onCreateAccount,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => GuestWarningDialog(
        onContinueAsGuest: onContinueAsGuest,
        onCreateAccount: onCreateAccount,
      ),
    );
  }
}
