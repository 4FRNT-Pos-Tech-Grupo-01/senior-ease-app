import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_ease/app_router.dart';
import 'package:senior_ease/app_settings_scope.dart';
import 'package:senior_ease/theme/app_theme.dart';
import 'package:senior_ease/widgets/confirm_before_action.dart';
import 'package:senior_ease/widgets/large_card.dart';

class Screen3 extends StatefulWidget {
  const Screen3({super.key});

  @override
  State<Screen3> createState() => _Screen3State();
}

class _Screen3State extends State<Screen3> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final settings = AppSettingsScope.of(context);

    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context, textTheme),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 48),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 896),
                        child: Column(
                          children: [
                            _buildProfileCard(textTheme),
                            const SizedBox(height: 16),
                            _buildFontSizeCard(context, textTheme),
                            const SizedBox(height: 16),
                            _buildContrastCard(context, textTheme),
                            const SizedBox(height: 16),
                            _buildNavigationCard(context, textTheme),
                            const SizedBox(height: 16),
                            _buildAdditionalPrefsCard(context, textTheme),
                            const SizedBox(height: 16),
                            _buildResetButton(textTheme),
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
      },
    );
  }

  Widget _buildHeader(BuildContext context, TextTheme textTheme) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
          bottom: BorderSide(color: cs.outline, width: 2),
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.lightBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.favorite_border,
                        color: AppColors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Senior Ease',
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 24,
                          ),
                        ),
                        Text(
                          'Meu Perfil',
                          style: textTheme.bodyMedium?.copyWith(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                _buildHeaderButton(
                  icon: Icons.arrow_back,
                  label: 'Voltar',
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(AppRouter.screen2);
                    }
                  },
                  textTheme: textTheme,
                ),
                const SizedBox(width: 8),
                _buildHeaderButton(
                  icon: Icons.logout,
                  label: 'Sair',
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
                  textTheme: textTheme,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required TextTheme textTheme,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            border: Border.all(color: cs.outline, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: cs.onSurface),
              const SizedBox(width: 8),
              Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(TextTheme textTheme) {
    return LargeCard(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.lightBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(9999),
              border: Border.all(color: AppColors.lightBlue, width: 2),
            ),
            child: const Icon(
              Icons.person_outline,
              color: AppColors.lightBlue,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Usuário Senior Ease',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 20,
                ),
              ),
              Text('usuario@email.com', style: textTheme.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFontSizeCard(BuildContext context, TextTheme textTheme) {
    final settings = AppSettingsScope.of(context);
    return _buildSettingsCard(
      icon: Icons.text_fields,
      title: 'Tamanho da Fonte',
      description: 'Escolha o tamanho de texto mais confortável para leitura.',
      child: Row(
        children: [
          Expanded(
            child: _buildChoiceButton(
              context: context,
              label: 'Aa',
              subtitle: 'Normal',
              selected: settings.fontSize == 'normal',
              onTap: () => settings.setFontSize('normal'),
              labelStyle: textTheme.titleMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              subtitleStyle: textTheme.bodyMedium?.copyWith(fontSize: 14),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildChoiceButton(
              context: context,
              label: 'Aa',
              subtitle: 'Grande',
              selected: settings.fontSize == 'large',
              onTap: () => settings.setFontSize('large'),
              labelStyle: textTheme.titleMedium?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
              subtitleStyle: textTheme.bodyMedium?.copyWith(fontSize: 14),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildChoiceButton(
              context: context,
              label: 'Aa',
              subtitle: 'Extra Grande',
              selected: settings.fontSize == 'xlarge',
              onTap: () => settings.setFontSize('xlarge'),
              labelStyle: textTheme.titleMedium?.copyWith(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                height: 36 / 30,
              ),
              subtitleStyle: textTheme.bodyMedium?.copyWith(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContrastCard(BuildContext context, TextTheme textTheme) {
    final settings = AppSettingsScope.of(context);
    final cs = Theme.of(context).colorScheme;
    return _buildSettingsCard(
      icon: Icons.contrast,
      title: 'Nível de Contraste',
      description: 'Aumente o contraste para melhor visibilidade.',
      child: Row(
        children: [
          Expanded(
            child: _buildChoiceButton(
              context: context,
              label: 'Normal',
              selected: settings.contrast == 'normal',
              onTap: () => settings.setContrast('normal'),
              labelStyle: textTheme.titleMedium,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildChoiceButton(
              context: context,
              label: 'Alto Contraste',
              selected: settings.contrast == 'high',
              onTap: () => settings.setContrast('high'),
              labelStyle: textTheme.titleMedium?.copyWith(
                color: settings.contrast == 'high'
                    ? cs.onSurface
                    : cs.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationCard(BuildContext context, TextTheme textTheme) {
    final settings = AppSettingsScope.of(context);
    return _buildSettingsCard(
      icon: Icons.navigation_outlined,
      title: 'Modo de Navegação',
      description: 'Escolha como deseja navegar pelo aplicativo.',
      child: Row(
        children: [
          Expanded(
            child: _buildChoiceButton(
              context: context,
              label: 'Padrão',
              subtitle: 'Todas as opções visíveis',
              selected: settings.navigationMode == 'default',
              onTap: () => settings.setNavigationMode('default'),
              alignStart: true,
              labelStyle: textTheme.titleMedium,
              subtitleStyle: textTheme.bodyMedium?.copyWith(fontSize: 14),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildChoiceButton(
              context: context,
              label: 'Simplificado',
              subtitle: 'Apenas o essencial',
              selected: settings.navigationMode == 'simple',
              onTap: () => settings.setNavigationMode('simple'),
              alignStart: true,
              labelStyle: textTheme.titleMedium,
              subtitleStyle: textTheme.bodyMedium?.copyWith(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalPrefsCard(BuildContext context, TextTheme textTheme) {
    final settings = AppSettingsScope.of(context);
    return _buildSettingsCard(
      icon: Icons.shield_outlined,
      title: 'Preferências Adicionais',
      description: '',
      child: Column(
        children: [
          _buildSwitchRow(
            icon: Icons.shield_outlined,
            title: 'Confirmações extras',
            subtitle: 'Pedir confirmação antes de ações importantes',
            value: settings.extraConfirmations,
            onChanged: settings.setExtraConfirmations,
          ),
          const SizedBox(height: 4),
          Container(height: 1, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 4),
          _buildSwitchRow(
            icon: Icons.notifications_none_outlined,
            title: 'Lembretes e notificações',
            subtitle: 'Receber avisos de tarefas e compromissos',
            value: settings.notificationsEnabled,
            onChanged: settings.setNotificationsEnabled,
          ),
          const SizedBox(height: 4),
          Container(height: 1, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 4),
          _buildSwitchRow(
            icon: Icons.volume_up_outlined,
            title: 'Alertas sonoros',
            subtitle: 'Sons ao concluir tarefas e receber lembretes',
            value: settings.soundAlerts,
            onChanged: settings.setSoundAlerts,
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton(TextTheme textTheme) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: () async {
          await AppSettingsScope.of(context).resetAllSettings();
        },
        icon: Icon(
          Icons.refresh,
          size: 24,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        label: Text(
          'Restaurar configurações padrão',
          style: textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 2,
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required IconData icon,
    required String title,
    required String description,
    required Widget child,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return LargeCard(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 24, color: AppColors.lightBlue),
              const SizedBox(width: 8),
              Text(
                title,
                style: textTheme.headlineMedium?.copyWith(fontSize: 30 / 1.5),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (description.isNotEmpty) ...[
            Text(description, style: textTheme.bodyMedium),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }

  Widget _buildChoiceButton({
    required BuildContext context,
    required String label,
    String? subtitle,
    required bool selected,
    required VoidCallback onTap,
    TextStyle? labelStyle,
    TextStyle? subtitleStyle,
    bool alignStart = false,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: selected
          ? AppColors.linkWater
          : cs.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minHeight: 96),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.lightBlue : cs.outline,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: alignStart
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              Text(label, style: labelStyle),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle, style: subtitleStyle),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        border: Border.all(color: cs.outline, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: AppColors.lightBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: cs.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: textTheme.bodyMedium?.copyWith(fontSize: 14),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.lightBlue,
            inactiveTrackColor: cs.outline.withValues(alpha: 0.5),
            thumbColor: WidgetStatePropertyAll(cs.surface),
            trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
          ),
        ],
      ),
    );
  }
}
