import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:senior_ease/app_router.dart';
import 'package:senior_ease/app_settings_scope.dart';
import 'package:senior_ease/models/activity_history_entry.dart';
import 'package:senior_ease/models/reminder.dart';
import 'package:senior_ease/services/activity_history_storage.dart';
import 'package:senior_ease/services/notification_service.dart';
import 'package:senior_ease/services/reminders_storage.dart';
import 'package:senior_ease/theme/app_theme.dart';
import 'package:senior_ease/widgets/confirm_before_action.dart';
import 'package:senior_ease/widgets/large_card.dart';

class Screen2 extends StatefulWidget {
  const Screen2({super.key});

  @override
  State<Screen2> createState() => _Screen2State();
}

class _Screen2State extends State<Screen2> {
  static const List<String> _taskLabels = [
    'Tomar remédio da manhã',
    'Caminhar por 20 minutos',
    'Beber 2 copos de água',
    'Ligar para a família',
  ];

  /// Tarefas concluídas (mesmo estado inicial da UI estática).
  final List<bool> _tasksDone = [false, false, true, false];

  /// Etapas guiadas: [passo1, passo2, passo3].
  final List<bool> _guidedDone = [true, false, false];

  List<Reminder> _reminders = [];
  bool _remindersLoaded = false;
  List<ActivityHistoryEntry> _history = [];
  bool _historyLoaded = false;
  Timer? _remindersStorageSyncTimer;

  static const List<String> _guidedStepDescriptions = [
    'Pegue o remédio na caixa azul',
    'Tome com um copo cheio de água',
    'Anote no caderno que já tomou',
  ];

  int get _completedTaskCount => _tasksDone.where((e) => e).length;

  double get _taskProgress =>
      _tasksDone.isEmpty ? 0 : _completedTaskCount / _tasksDone.length;

  int get _guidedCompleted => _guidedDone.where((e) => e).length;

  double get _guidedProgress =>
      _guidedDone.isEmpty ? 0 : _guidedCompleted / _guidedDone.length;

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _bootstrapHistory() async {
    final list = await ActivityHistoryStorage.instance.load();
    if (!mounted) return;
    setState(() {
      _history = list;
      _historyLoaded = true;
    });
  }

  Future<void> _recordActivity(String title) async {
    await ActivityHistoryStorage.instance.append(title);
    if (!mounted) return;
    final list = await ActivityHistoryStorage.instance.load();
    if (!mounted) return;
    setState(() => _history = list);
  }

  String _formatHistoryWhen(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(d.year, d.month, d.day);
    final hm = DateFormat('HH:mm').format(d);
    if (day == today) return 'Hoje, $hm';
    if (day == today.subtract(const Duration(days: 1))) {
      return 'Ontem, $hm';
    }
    if (d.year == now.year) {
      return DateFormat('dd/MM · HH:mm').format(d);
    }
    return DateFormat('dd/MM/yyyy').format(d);
  }

  void _playCompletionFeedback() {
    if (!mounted) return;
    if (!AppSettingsScope.of(context).soundAlerts) return;
    HapticFeedback.mediumImpact();
    SystemSound.play(SystemSoundType.click);
  }

  Future<void> _toggleTask(int index) async {
    if (!mounted) return;
    final settings = AppSettingsScope.of(context);
    final label = _taskLabels[index];
    final willComplete = !_tasksDone[index];
    if (!await confirmBeforeImportantAction(
      context,
      settings: settings,
      title: willComplete ? 'Marcar como feita?' : 'Repor esta tarefa?',
      message: label,
      confirmLabel: willComplete ? 'Marcar feita' : 'Repor',
    )) {
      return;
    }
    if (!mounted) return;
    setState(() => _tasksDone[index] = !_tasksDone[index]);
    if (willComplete) {
      _playCompletionFeedback();
      await _recordActivity('Tarefa concluída: $label');
    }
  }

  Future<void> _onManageTasks() async {
    await context.pushNamed('task_management');
    if (mounted) await _bootstrapHistory();
  }

  Future<void> _completeNextGuidedStep() async {
    if (!mounted) return;
    final settings = AppSettingsScope.of(context);
    final i = _guidedDone.indexWhere((d) => !d);
    if (i < 0) return;
    if (!await confirmBeforeImportantAction(
      context,
      settings: settings,
      title: 'Concluir passo ${i + 1}?',
      message: 'Confirma que já realizou esta etapa.',
      confirmLabel: 'Concluir',
    )) {
      return;
    }
    if (!mounted) return;
    setState(() => _guidedDone[i] = true);
    _playCompletionFeedback();
    _showSnack('Passo ${i + 1} concluído!');
    final desc = i < _guidedStepDescriptions.length
        ? _guidedStepDescriptions[i]
        : 'Passo ${i + 1}';
    await _recordActivity('Etapa guiada: $desc');
  }

  @override
  void initState() {
    super.initState();
    _bootstrapReminders();
    _bootstrapHistory();
    _remindersStorageSyncTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _syncRemindersWithStorageIfChanged(),
    );
  }

  @override
  void dispose() {
    _remindersStorageSyncTimer?.cancel();
    super.dispose();
  }

  bool _sameReminderLists(List<Reminder> a, List<Reminder> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      final x = a[i];
      final y = b[i];
      if (x.id != y.id ||
          x.title != y.title ||
          x.scheduledAt != y.scheduledAt ||
          x.notificationId != y.notificationId ||
          x.iconIndex != y.iconIndex) {
        return false;
      }
    }
    return true;
  }

  /// Alinha `_reminders` com [SharedPreferences] (ex.: após purga automática).
  Future<void> _syncRemindersWithStorageIfChanged() async {
    if (!mounted || !_remindersLoaded) return;
    final list = await RemindersStorage.instance.load();
    list.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    if (!mounted) return;
    if (_sameReminderLists(_reminders, list)) return;
    // Nunca atualizar árvore durante layout / desativação de InheritedWidgets
    // (iOS: assert `_dependents.isEmpty` em debug).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      setState(() => _reminders = list);
    });
  }

  Future<void> _bootstrapReminders() async {
    final storage = RemindersStorage.instance;
    var list = await storage.load();
    if (list.isEmpty) {
      list = await _createDefaultReminders();
      await storage.save(list);
    }
    list.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!context.mounted) return;
      final s = AppSettingsScope.of(context);
      await NotificationService.instance.syncReminders(
        list,
        notificationsEnabled: s.notificationsEnabled,
        playSound: s.soundAlerts,
      );
      if (!context.mounted) return;
      setState(() {
        _reminders = list;
        _remindersLoaded = true;
      });
    });
  }

  Future<List<Reminder>> _createDefaultReminders() async {
    final storage = RemindersStorage.instance;
    final now = DateTime.now();
    final tomorrow = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 1));

    DateTime atDay(DateTime day, int h, int m) =>
        DateTime(day.year, day.month, day.day, h, m);

    DateTime nextWallClock(int h, int m) {
      var d = DateTime(now.year, now.month, now.day, h, m);
      if (!d.isAfter(now)) d = d.add(const Duration(days: 1));
      return d;
    }

    final stamp = now.microsecondsSinceEpoch;
    return [
      Reminder(
        id: 'default_${stamp}_1',
        title: 'Consulta médica',
        scheduledAt: atDay(tomorrow, 14, 0),
        notificationId: await storage.takeNextNotificationId(),
        iconIndex: 0,
      ),
      Reminder(
        id: 'default_${stamp}_2',
        title: 'Tomar remédio',
        scheduledAt: nextWallClock(20, 0),
        notificationId: await storage.takeNextNotificationId(),
        iconIndex: 1,
      ),
      Reminder(
        id: 'default_${stamp}_3',
        title: 'Reunião familiar',
        scheduledAt: atDay(tomorrow.add(const Duration(days: 2)), 10, 0),
        notificationId: await storage.takeNextNotificationId(),
        iconIndex: 2,
      ),
    ];
  }

  Future<void> _persistRemindersAndSync() async {
    await RemindersStorage.instance.save(_reminders);
    if (!mounted) return;
    final s = AppSettingsScope.of(context);
    await NotificationService.instance.syncReminders(
      _reminders,
      notificationsEnabled: s.notificationsEnabled,
      playSound: s.soundAlerts,
    );
  }

  IconData _reminderIconData(int index) {
    switch (index.clamp(0, 2)) {
      case 1:
        return Icons.notifications_outlined;
      case 2:
        return Icons.favorite_border;
      default:
        return Icons.schedule;
    }
  }

  String _formatReminderWhen(DateTime d) {
    return DateFormat('dd/MM/yyyy · HH:mm').format(d);
  }

  Future<void> _confirmDeleteReminder(Reminder r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Apagar lembrete?'),
        content: Text('“${r.title}” será removido.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _reminders.removeWhere((x) => x.id == r.id));
    await _persistRemindersAndSync();
    await _recordActivity('Lembrete removido: ${r.title}');
    _showSnack('Lembrete removido.');
  }

  Future<void> _showAddReminderDialog() async {
    final titleCtrl = TextEditingController();
    var chosen = DateTime.now().add(const Duration(hours: 1));
    var iconIdx = 0;
    final pageContext = context;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDlg) {
            return AlertDialog(
              title: const Text('Novo lembrete'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Descrição',
                        hintText: 'Ex.: Tomar medicamento',
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(_formatReminderWhen(chosen)),
                      subtitle: const Text('Data e hora'),
                      trailing: const Icon(Icons.edit_calendar_outlined),
                      onTap: () async {
                        final d = await showDatePicker(
                          context: ctx,
                          initialDate: chosen,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365 * 2),
                          ),
                        );
                        if (d == null || !ctx.mounted) return;
                        final t = await showTimePicker(
                          context: ctx,
                          initialTime: TimeOfDay.fromDateTime(chosen),
                        );
                        if (t == null) return;
                        setDlg(() {
                          chosen = DateTime(
                            d.year,
                            d.month,
                            d.day,
                            t.hour,
                            t.minute,
                          );
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Text('Ícone', style: Theme.of(ctx).textTheme.titleSmall),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(3, (i) {
                        final sel = iconIdx == i;
                        return IconButton.filledTonal(
                          onPressed: () => setDlg(() => iconIdx = i),
                          style: IconButton.styleFrom(
                            backgroundColor: sel ? AppColors.linkWater : null,
                            foregroundColor: sel
                                ? AppColors.lightBlue
                                : Theme.of(ctx).colorScheme.onSurfaceVariant,
                          ),
                          icon: Icon(_reminderIconData(i)),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () async {
                    if (titleCtrl.text.trim().isEmpty) return;
                    final settings = AppSettingsScope.of(pageContext);
                    if (!await confirmBeforeImportantAction(
                      pageContext,
                      settings: settings,
                      title: 'Guardar lembrete?',
                      message:
                          'Será agendado um aviso na data e hora escolhidas.',
                      confirmLabel: 'Guardar',
                    )) {
                      return;
                    }
                    if (ctx.mounted) Navigator.pop(ctx, true);
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );

    final text = titleCtrl.text.trim();
    titleCtrl.dispose();

    if (saved != true || !mounted) return;
    if (text.isEmpty) {
      _showSnack('Escreva uma descrição.');
      return;
    }
    final now = DateTime.now();
    if (!chosen.isAfter(now)) {
      _showSnack('Escolha uma data e hora no futuro.');
      return;
    }
    // O relógio do picker usa normalmente segundos :00. Se escolheres só o
    // “minuto seguinte”, ao premir Guardar esse instante pode já ter passado
    // e o iOS não recebe nada para agendar.
    const minLead = Duration(minutes: 2);
    if (!chosen.isAfter(now.add(minLead))) {
      _showSnack(
        'Para a notificação ser agendada com fiabilidade, escolha uma hora pelo '
        'menos 2 minutos à frente do relógio atual.',
      );
      return;
    }

    final storage = RemindersStorage.instance;
    final r = Reminder(
      id: 'r_${DateTime.now().microsecondsSinceEpoch}',
      title: text,
      scheduledAt: chosen,
      notificationId: await storage.takeNextNotificationId(),
      iconIndex: iconIdx,
    );

    setState(() {
      _reminders = [..._reminders, r]
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    });
    await _persistRemindersAndSync();
    await _recordActivity('Lembrete criado: $text');
    if (await NotificationService.instance.isDarwinNotificationsBlocked()) {
      _showSnack(
        'Lembrete guardado. Ative notificações em Definições → Notificações → '
        'Senior Ease para ser alertada na hora.',
      );
    } else {
      _showSnack(
        'Lembrete criado. Receberá uma notificação na hora marcada.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final settings = AppSettingsScope.of(context);

    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final simple = settings.navigationSimple;
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context, textTheme),
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 48),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            if (!simple) ...[
                              _buildProgressCard(textTheme),
                              const SizedBox(height: 16),
                            ],
                            _buildTasksCard(textTheme),
                            const SizedBox(height: 16),
                            if (!simple) ...[
                              _buildGuidedStepsCard(textTheme),
                              const SizedBox(height: 16),
                            ],
                            _buildRemindersCard(textTheme),
                            if (!simple) ...[
                              const SizedBox(height: 16),
                              _buildHistoryCard(textTheme),
                            ],
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, TextTheme textTheme) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
          bottom: BorderSide(color: cs.outline, width: 2),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2),
        ],
      ),
      child: Row(
        children: [
          Semantics(
            label: 'Logo Senior Ease',
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.lightBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.favorite_outline,
                color: AppColors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Semantics(
                  button: true,
                  label: 'Perfil',
                  child: Material(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () {
                        // Rota filha de /screen_2: o stack fica […, home, perfil].
                        context.pushNamed('screen_3');
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        constraints: const BoxConstraints(minHeight: 48),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 20,
                              color: cs.onSurface,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Perfil',
                              style: textTheme.titleMedium?.copyWith(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Semantics(
                  button: true,
                  label: 'Sair',
                  child: Material(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () async {
                        final s = AppSettingsScope.of(context);
                        if (!await confirmBeforeImportantAction(
                          context,
                          settings: s,
                          title: 'Sair?',
                          message:
                              'Será necessário iniciar sessão de novo para voltar.',
                          confirmLabel: 'Sair',
                        )) {
                          return;
                        }
                        if (!context.mounted) return;
                        context.go(AppRouter.screen1);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        constraints: const BoxConstraints(minHeight: 48),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.logout,
                              size: 20,
                              color: cs.onSurface,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Sair',
                              style: textTheme.titleMedium?.copyWith(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(TextTheme textTheme) {
    final total = _tasksDone.length;
    final done = _completedTaskCount;
    final pct = (_taskProgress * 100).round();

    return LargeCard(
      padding: const EdgeInsets.all(24),
      semanticLabel:
          'Progresso de hoje: $done de $total tarefas, $pct por cento',
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.lightBlue.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.wb_sunny_outlined,
              color: AppColors.lightBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progresso de hoje: $done de $total tarefas',
                  style: textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(9999),
                  child: LinearProgressIndicator(
                    value: _taskProgress.clamp(0.0, 1.0),
                    backgroundColor: AppColors.linkWater,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.lightBlue,
                    ),
                    minHeight: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '$pct%',
            style: textTheme.headlineMedium?.copyWith(
              color: AppColors.lightBlue,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksCard(TextTheme textTheme) {
    return LargeCard(
      semanticLabel: 'Minhas Tarefas',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.list_alt, color: AppColors.lightBlue, size: 24),
              const SizedBox(width: 8),
              Text('Minhas Tarefas', style: textTheme.headlineMedium),
            ],
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < _taskLabels.length; i++)
            _taskRow(textTheme, i, _taskLabels[i], _tasksDone[i]),
          const SizedBox(height: 16),
          Semantics(
            button: true,
            label: 'Gerenciar tarefas',
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _onManageTasks,
                style: ElevatedButton.styleFrom(
                  elevation: 2,
                  shadowColor: Theme.of(context).colorScheme.onSurface.withValues(
                        alpha: 0.2,
                      ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Gerenciar',
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _taskRow(
    TextTheme textTheme,
    int index,
    String label,
    bool completed,
  ) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: Semantics(
          button: true,
          label: completed
              ? 'Marcar tarefa como não feita: $label'
              : 'Marcar tarefa como feita: $label',
          child: InkWell(
            onTap: () => _toggleTask(index),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: completed
                    ? AppColors.jungleGreen.withValues(alpha: 0.1)
                    : cs.surface,
                border: Border.all(
                  color: completed
                      ? AppColors.jungleGreen.withValues(alpha: 0.4)
                      : cs.outline,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: completed
                          ? AppColors.lightBlue
                          : Colors.transparent,
                      border: Border.all(color: AppColors.lightBlue, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: completed
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: AppColors.white,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      label,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        decoration: completed
                            ? TextDecoration.lineThrough
                            : null,
                        color: completed
                            ? cs.onSurfaceVariant
                            : cs.onSurface,
                      ),
                    ),
                  ),
                  if (completed)
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.jungleGreen,
                      size: 24,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Passo atual a destacar: primeiro ainda não concluído (índice 0 = passo 1).
  bool _isGuidedStepActive(int stepIndex) {
    if (stepIndex < 0 || stepIndex >= _guidedDone.length) return false;
    if (_guidedDone[stepIndex]) return false;
    for (var j = 0; j < stepIndex; j++) {
      if (!_guidedDone[j]) return false;
    }
    return true;
  }

  /// Cores do banner de sucesso (etapas concluídas), alinhadas ao layout de referência.
  static const Color _guidedDoneBannerBg = Color(0xFFF1F8F3);
  static const Color _guidedDoneBannerBorder = Color(0xFFA8D5BA);
  Widget _buildGuidedStepsCard(TextTheme textTheme) {
    final nextIdx = _guidedDone.indexWhere((d) => !d);
    final allDone = nextIdx < 0;
    final buttonLabel = allDone
        ? 'Todas as etapas concluídas'
        : 'Concluir "Passo ${nextIdx + 1}"';

    return LargeCard(
      semanticLabel: 'Etapas Guiadas',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_tree_outlined,
                color: AppColors.lightBlue,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text('Etapas Guiadas', style: textTheme.headlineMedium),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: LinearProgressIndicator(
              value: _guidedProgress.clamp(0.0, 1.0),
              backgroundColor: AppColors.linkWater,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.lightBlue,
              ),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 16),
          _stepRow(
            textTheme,
            1,
            'Pegue o remédio na caixa azul',
            _isGuidedStepActive(0),
            _guidedDone[0],
          ),
          _stepRow(
            textTheme,
            2,
            'Tome com um copo cheio de água',
            _isGuidedStepActive(1),
            _guidedDone[1],
          ),
          _stepRow(
            textTheme,
            3,
            'Anote no caderno que já tomou',
            _isGuidedStepActive(2),
            _guidedDone[2],
          ),
          const SizedBox(height: 16),
          if (allDone)
            Semantics(
              container: true,
              label: 'Todas as etapas concluídas. Parabéns.',
              child: _buildGuidedStepsCompletionBanner(textTheme),
            )
          else
            Semantics(
              button: true,
              label: buttonLabel,
              enabled: true,
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _completeNextGuidedStep,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(buttonLabel),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGuidedStepsCompletionBanner(TextTheme textTheme) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: _guidedDoneBannerBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _guidedDoneBannerBorder, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.celebration_outlined,
            color: _guidedDoneBannerBorder,
            size: 44,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Todas as etapas concluídas!',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Parabéns! 🥳',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepRow(
    TextTheme textTheme,
    int step,
    String description,
    bool isActive,
    bool completed,
  ) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.linkWater
              : (completed
                    ? AppColors.jungleGreen.withValues(alpha: 0.1)
                    : cs.surface),
          border: Border.all(
            color: isActive
                ? AppColors.lightBlue
                : (completed
                      ? AppColors.jungleGreen.withValues(alpha: 0.4)
                      : cs.outline),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: completed
                    ? AppColors.jungleGreen
                    : (isActive
                          ? AppColors.lightBlue
                          : cs.surfaceContainerHighest),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: completed
                  ? const Text(
                      '✓',
                      style: TextStyle(color: AppColors.white, fontSize: 18),
                    )
                  : Text(
                      '$step',
                      style: TextStyle(
                        color: isActive ? AppColors.white : cs.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Passo $step', style: textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: textTheme.bodyMedium?.copyWith(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemindersCard(TextTheme textTheme) {
    if (!_remindersLoaded) {
      return LargeCard(
        semanticLabel: 'Lembretes a carregar',
        child: const SizedBox(
          height: 100,
          child: Center(
            child: CircularProgressIndicator(color: AppColors.lightBlue),
          ),
        ),
      );
    }

    return LargeCard(
      semanticLabel: 'Lembretes',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.notifications_active_outlined,
                color: AppColors.lightBlue,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Lembretes', style: textTheme.headlineMedium),
              ),
              Semantics(
                label: 'Adicionar novo lembrete',
                button: true,
                child: IconButton(
                  onPressed: _showAddReminderDialog,
                  icon: const Icon(Icons.add_circle_outline),
                  color: AppColors.lightBlue,
                  tooltip: 'Novo lembrete',
                  iconSize: 32,
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            NotificationService.instance.isSupported
                ? 'Toque num lembrete para ver a hora. Use + para criar. As notificações aparecem no telemóvel ou computador.'
                : 'Nesta plataforma as notificações do sistema não estão disponíveis; os lembretes ficam guardados na app.',
            style: textTheme.bodyMedium?.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 16),
          if (_reminders.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Nenhum lembrete. Toque em + para criar.',
                style: textTheme.bodyLarge,
              ),
            )
          else
            ..._reminders.map((r) => _reminderTile(r, textTheme)),
        ],
      ),
    );
  }

  Widget _reminderTile(Reminder r, TextTheme textTheme) {
    final cs = Theme.of(context).colorScheme;
    final past = !r.scheduledAt.isAfter(DateTime.now());
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: Semantics(
          label: 'Lembrete: ${r.title}, ${_formatReminderWhen(r.scheduledAt)}',
          button: true,
          child: InkWell(
            onTap: () => _showSnack(
              '${r.title}\n${_formatReminderWhen(r.scheduledAt)}'
              '${past ? '\n(Já passou — pode apagar se quiser)' : ''}',
            ),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cs.surface,
                border: Border.all(color: cs.outline, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    _reminderIconData(r.iconIndex),
                    color: past ? cs.onSurfaceVariant : AppColors.lightBlue,
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.title,
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            color: past ? cs.onSurfaceVariant : cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatReminderWhen(r.scheduledAt),
                          style: textTheme.bodyMedium?.copyWith(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  Semantics(
                    label: 'Apagar lembrete ${r.title}',
                    button: true,
                    child: IconButton(
                      onPressed: () => _confirmDeleteReminder(r),
                      icon: const Icon(Icons.delete_outline),
                      color: cs.onSurfaceVariant,
                      tooltip: 'Apagar',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(TextTheme textTheme) {
    final cs = Theme.of(context).colorScheme;
    return LargeCard(
      semanticLabel: 'Histórico de Atividades',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history, color: AppColors.lightBlue, size: 24),
              const SizedBox(width: 8),
              Text('Histórico de Atividades', style: textTheme.headlineMedium),
            ],
          ),
          const SizedBox(height: 16),
          if (!_historyLoaded)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.lightBlue),
              ),
            )
          else if (_history.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Ainda não há atividades registadas. Ao concluir tarefas, '
                'etapas guiadas ou criar lembretes, elas aparecem aqui.',
                style: textTheme.bodyLarge,
              ),
            )
          else
            ..._history.asMap().entries.map((me) {
              final i = me.key;
              final e = me.value;
              final whenLabel = _formatHistoryWhen(e.recordedAt);
              return Column(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: Semantics(
                      button: true,
                      label: '${e.title}, $whenLabel',
                      child: InkWell(
                        onTap: () => _showSnack(
                          '${e.title}\nRegistado em $whenLabel',
                        ),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.jungleGreen,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  e.title,
                                  style: textTheme.bodyLarge?.copyWith(
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 11,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.linkWater,
                                  borderRadius: BorderRadius.circular(9999),
                                ),
                                child: Text(
                                  whenLabel,
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF0C57A7),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (i < _history.length - 1) ...[
                    const SizedBox(height: 12),
                    Divider(height: 1, color: cs.outline),
                    const SizedBox(height: 12),
                  ],
                ],
              );
            }),
        ],
      ),
    );
  }
}
