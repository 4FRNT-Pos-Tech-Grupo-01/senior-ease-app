import 'package:flutter/material.dart';
import 'package:senior_ease/services/app_settings_controller.dart';

/// Se [settings.extraConfirmations] estiver ativo, mostra diálogo; caso contrário devolve `true`.
Future<bool> confirmBeforeImportantAction(
  BuildContext context, {
  required AppSettingsController settings,
  required String title,
  required String message,
  String confirmLabel = 'Continuar',
}) async {
  if (!settings.extraConfirmations) return true;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return ok == true;
}
