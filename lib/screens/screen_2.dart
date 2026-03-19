import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_ease/app_router.dart';
import 'package:senior_ease/theme/app_theme.dart';
import 'package:senior_ease/widgets/large_card.dart';

class Screen2 extends StatelessWidget {
  const Screen2({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: AppColors.grey98,
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
                        _buildProgressCard(textTheme),
                        const SizedBox(height: 16),
                        _buildTasksCard(textTheme),
                        const SizedBox(height: 16),
                        _buildGuidedStepsCard(textTheme),
                        const SizedBox(height: 16),
                        _buildRemindersCard(textTheme),
                        const SizedBox(height: 16),
                        _buildHistoryCard(textTheme),
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
  }

  Widget _buildHeader(BuildContext context, TextTheme textTheme) {
    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.lightGray, width: 2),
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
                    color: AppColors.grey98,
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
                              color: AppColors.darkBlue,
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
                    color: AppColors.grey98,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () => context.go(AppRouter.screen1),
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
                              color: AppColors.darkBlue,
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
    return LargeCard(
      padding: const EdgeInsets.all(24),
      semanticLabel: 'Progresso de hoje: 1 de 4 tarefas, 25 por cento',
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
                  'Progresso de hoje: 1 de 4 tarefas',
                  style: textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(9999),
                  child: LinearProgressIndicator(
                    value: 0.25,
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
            '25%',
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
    final tasks = [
      ('Tomar remédio da manhã', false),
      ('Caminhar por 20 minutos', false),
      ('Beber 2 copos de água', true),
      ('Ligar para a família', false),
    ];
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
          ...tasks.map((e) => _taskRow(textTheme, e.$1, e.$2)),
        ],
      ),
    );
  }

  Widget _taskRow(TextTheme textTheme, String label, bool completed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: completed
              ? AppColors.jungleGreen.withValues(alpha: 0.1)
              : AppColors.white,
          border: Border.all(
            color: completed
                ? AppColors.jungleGreen.withValues(alpha: 0.4)
                : AppColors.lightGray,
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
                color: completed ? AppColors.lightBlue : Colors.transparent,
                border: Border.all(color: AppColors.lightBlue, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: completed
                  ? const Icon(Icons.check, size: 16, color: AppColors.white)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  decoration: completed ? TextDecoration.lineThrough : null,
                  color: completed ? AppColors.gray : AppColors.darkBlue,
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
    );
  }

  Widget _buildGuidedStepsCard(TextTheme textTheme) {
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
              value: 1 / 3,
              backgroundColor: AppColors.linkWater,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.lightBlue,
              ),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 16),
          _stepRow(textTheme, 1, 'Pegue o remédio na caixa azul', false, true),
          _stepRow(textTheme, 2, 'Tome com um copo cheio de água', true, false),
          _stepRow(textTheme, 3, 'Anote no caderno que já tomou', false, false),
          const SizedBox(height: 16),
          Semantics(
            button: true,
            label: 'Concluir Passo 2',
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Concluir "Passo 2"'),
              ),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.linkWater
              : (completed
                    ? AppColors.jungleGreen.withValues(alpha: 0.1)
                    : AppColors.white),
          border: Border.all(
            color: isActive
                ? AppColors.lightBlue
                : (completed
                      ? AppColors.jungleGreen.withValues(alpha: 0.4)
                      : AppColors.lightGray),
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
                          : const Color(0xFFE9EDF2)),
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
                        color: isActive ? AppColors.white : AppColors.gray,
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
    final reminders = [
      (Icons.schedule, 'Consulta médica amanhã às 14h'),
      (Icons.notifications_outlined, 'Tomar remédio às 20h'),
      (Icons.favorite_border, 'Reunião familiar no domingo'),
    ];
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
              Text('Lembretes', style: textTheme.headlineMedium),
            ],
          ),
          const SizedBox(height: 16),
          ...reminders.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(color: AppColors.lightGray, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(e.$1, color: AppColors.lightBlue, size: 28),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        e.$2,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(TextTheme textTheme) {
    final items = [
      ('Tomou remédio da manhã', 'Hoje, 08:15'),
      ('Caminhou 25 minutos', 'Ontem, 09:00'),
      ('Bebeu 6 copos de água', 'Ontem'),
      ('Ligou para a família', '03/03/2026'),
    ];
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
          ...items.map(
            (e) => Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.jungleGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        e.$1,
                        style: textTheme.bodyLarge?.copyWith(fontSize: 18),
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
                        e.$2,
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF0C57A7),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColors.lightGray),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
