import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_ease/app_router.dart';
import 'package:senior_ease/theme/app_theme.dart';
import 'package:senior_ease/widgets/large_card.dart';

/// Tarefa editável na lista de gerenciamento (estado local).
class _ManagedTask {
  _ManagedTask({required this.id, required this.title});

  final String id;
  String title;
}

/// Tela de gerenciamento: pendentes, concluídas, reordenar, editar, excluir, nova tarefa.
class TaskManagementScreen extends StatefulWidget {
  const TaskManagementScreen({super.key});

  @override
  State<TaskManagementScreen> createState() => _TaskManagementScreenState();
}

class _TaskManagementScreenState extends State<TaskManagementScreen> {
  late List<_ManagedTask> _pending;
  late List<_ManagedTask> _completed;

  @override
  void initState() {
    super.initState();
    _pending = [
      _ManagedTask(id: 't1', title: 'Tomar remédio da manhã'),
      _ManagedTask(id: 't2', title: 'Caminhar por 20 minutos'),
      _ManagedTask(id: 't4', title: 'Ligar para a família'),
    ];
    _completed = [
      _ManagedTask(id: 't3', title: 'Beber 2 copos de água'),
    ];
  }

  int get _totalCount => _pending.length + _completed.length;

  void _popOrHome() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRouter.screen2);
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _addTask() async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nova tarefa'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Descrição',
            hintText: 'Ex.: Caminhar no parque',
          ),
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (_) {
            if (ctrl.text.trim().isNotEmpty) {
              Navigator.pop(ctx, true);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (ctrl.text.trim().isEmpty) return;
              Navigator.pop(ctx, true);
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final t = ctrl.text.trim();
    if (t.isEmpty) return;
    setState(() {
      _pending.add(
        _ManagedTask(
          id: 'n_${DateTime.now().microsecondsSinceEpoch}',
          title: t,
        ),
      );
    });
    _showSnack('Tarefa adicionada.');
  }

  Future<void> _editTask(_ManagedTask task) async {
    final ctrl = TextEditingController(text: task.title);
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar tarefa'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Descrição'),
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (ctrl.text.trim().isEmpty) return;
              Navigator.pop(ctx, true);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (saved != true || !mounted) return;
    final next = ctrl.text.trim();
    if (next.isEmpty) return;
    setState(() => task.title = next);
    _showSnack('Tarefa atualizada.');
  }

  Future<void> _confirmDelete(_ManagedTask task, bool fromCompleted) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Apagar tarefa?'),
        content: Text('“${task.title}” será removida.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() {
      if (fromCompleted) {
        _completed.removeWhere((e) => e.id == task.id);
      } else {
        _pending.removeWhere((e) => e.id == task.id);
      }
    });
    _showSnack('Tarefa removida.');
  }

  void _toggleToCompleted(_ManagedTask task) {
    setState(() {
      _pending.removeWhere((e) => e.id == task.id);
      _completed.add(task);
    });
  }

  void _toggleToPending(_ManagedTask task) {
    setState(() {
      _completed.removeWhere((e) => e.id == task.id);
      _pending.add(task);
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.grey98,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildToolbar(textTheme),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 48),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 896),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildPendingSection(textTheme),
                        const SizedBox(height: 16),
                        _buildCompletedSection(textTheme),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar(TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.lightGray, width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 896),
          child: Row(
            children: [
              Semantics(
                button: true,
                label: 'Voltar',
                child: IconButton(
                  onPressed: _popOrHome,
                  icon: const Icon(Icons.arrow_back),
                  color: AppColors.darkBlue,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.grey98,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  '$_totalCount tarefas no total',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: _addTask,
                icon: const Icon(Icons.add, size: 22, color: AppColors.white),
                label: const Text('Nova Tarefa'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.lightBlue,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPendingSection(TextTheme textTheme) {
    return LargeCard(
      semanticLabel:
          'Tarefas pendentes, ${_pending.length} tarefas',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.list_alt,
                color: AppColors.lightBlue,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tarefas Pendentes',
                  style: textTheme.headlineMedium?.copyWith(fontSize: 20),
                ),
              ),
              _countBadge(_pending.length),
            ],
          ),
          const SizedBox(height: 16),
          if (_pending.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'Nenhuma tarefa pendente.',
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            )
          else
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final item = _pending.removeAt(oldIndex);
                  _pending.insert(newIndex, item);
                });
              },
              itemCount: _pending.length,
              itemBuilder: (context, index) {
                final task = _pending[index];
                return _pendingRow(
                  key: ValueKey(task.id),
                  textTheme: textTheme,
                  task: task,
                  index: index,
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCompletedSection(TextTheme textTheme) {
    return LargeCard(
      semanticLabel:
          'Tarefas concluídas, ${_completed.length} tarefas',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: AppColors.jungleGreen,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tarefas Concluídas',
                  style: textTheme.headlineMedium?.copyWith(fontSize: 20),
                ),
              ),
              _countBadge(_completed.length),
            ],
          ),
          const SizedBox(height: 16),
          if (_completed.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'Nenhuma tarefa concluída.',
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            )
          else
            ..._completed.map(
              (task) => Padding(
                key: ValueKey('c_${task.id}'),
                padding: const EdgeInsets.only(bottom: 12),
                child: _completedRow(textTheme, task),
              ),
            ),
        ],
      ),
    );
  }

  Widget _countBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.linkWater,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.lightBlue,
        ),
      ),
    );
  }

  Widget _pendingRow({
    required Key key,
    required TextTheme textTheme,
    required _ManagedTask task,
    required int index,
  }) {
    final errorColor = Theme.of(context).colorScheme.error;

    return Padding(
      key: key,
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.lightGray, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ReorderableDragStartListener(
                index: index,
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(
                    Icons.drag_indicator,
                    color: AppColors.gray,
                    size: 28,
                  ),
                ),
              ),
              Semantics(
                label: 'Marcar como concluída: ${task.title}',
                button: true,
                child: InkWell(
                  onTap: () => _toggleToCompleted(task),
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.lightBlue,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  task.title,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                    color: AppColors.darkBlue,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Editar',
                onPressed: () => _editTask(task),
                icon: const Icon(Icons.edit_outlined),
                color: AppColors.gray,
              ),
              IconButton(
                tooltip: 'Apagar',
                onPressed: () => _confirmDelete(task, false),
                icon: Icon(Icons.delete_outline, color: errorColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _completedRow(TextTheme textTheme, _ManagedTask task) {
    final errorColor = Theme.of(context).colorScheme.error;

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.jungleGreen.withValues(alpha: 0.1),
          border: Border.all(
            color: AppColors.jungleGreen.withValues(alpha: 0.4),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Semantics(
              label: 'Marcar como pendente: ${task.title}',
              button: true,
              child: InkWell(
                onTap: () => _toggleToPending(task),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: AppColors.jungleGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 16,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                task.title,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  decoration: TextDecoration.lineThrough,
                  color: AppColors.gray,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Editar',
              onPressed: () => _editTask(task),
              icon: const Icon(Icons.edit_outlined),
              color: AppColors.gray,
            ),
            IconButton(
              tooltip: 'Apagar',
              onPressed: () => _confirmDelete(task, true),
              icon: Icon(Icons.delete_outline, color: errorColor),
            ),
          ],
        ),
      ),
    );
  }
}
