import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_ease/app_router.dart';
import 'package:senior_ease/theme/app_theme.dart';
import 'package:senior_ease/widgets/large_card.dart';

class Screen3 extends StatefulWidget {
  const Screen3({super.key});

  @override
  State<Screen3> createState() => _Screen3State();
}

class _Screen3State extends State<Screen3> {
  String _fontSize = 'normal';
  String _contrast = 'normal';
  String _navigation = 'default';
  bool _extraConfirmations = false;
  bool _notifications = true;
  bool _soundAlerts = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: AppColors.grey98,
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
                        _buildFontSizeCard(textTheme),
                        const SizedBox(height: 16),
                        _buildContrastCard(textTheme),
                        const SizedBox(height: 16),
                        _buildNavigationCard(textTheme),
                        const SizedBox(height: 16),
                        _buildAdditionalPrefsCard(textTheme),
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
  }

  Widget _buildHeader(BuildContext context, TextTheme textTheme) {
    return Container(
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
                  onTap: () => context.go(AppRouter.screen1),
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
    return Material(
      color: AppColors.grey98,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.lightGray, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.darkBlue),
              const SizedBox(width: 8),
              Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkBlue,
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
                  color: AppColors.darkBlue,
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

  Widget _buildFontSizeCard(TextTheme textTheme) {
    return _buildSettingsCard(
      icon: Icons.text_fields,
      title: 'Tamanho da Fonte',
      description: 'Escolha o tamanho de texto mais confortável para leitura.',
      child: Row(
        children: [
          Expanded(
            child: _buildChoiceButton(
              label: 'Aa',
              subtitle: 'Normal',
              selected: _fontSize == 'normal',
              onTap: () => setState(() => _fontSize = 'normal'),
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
              label: 'Aa',
              subtitle: 'Grande',
              selected: _fontSize == 'large',
              onTap: () => setState(() => _fontSize = 'large'),
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
              label: 'Aa',
              subtitle: 'Extra Grande',
              selected: _fontSize == 'xlarge',
              onTap: () => setState(() => _fontSize = 'xlarge'),
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

  Widget _buildContrastCard(TextTheme textTheme) {
    return _buildSettingsCard(
      icon: Icons.contrast,
      title: 'Nível de Contraste',
      description: 'Aumente o contraste para melhor visibilidade.',
      child: Row(
        children: [
          Expanded(
            child: _buildChoiceButton(
              label: 'Normal',
              selected: _contrast == 'normal',
              onTap: () => setState(() => _contrast = 'normal'),
              labelStyle: textTheme.titleMedium,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildChoiceButton(
              label: 'Alto Contraste',
              selected: _contrast == 'high',
              onTap: () => setState(() => _contrast = 'high'),
              labelStyle: textTheme.titleMedium?.copyWith(
                color: _contrast == 'high'
                    ? AppColors.darkBlue
                    : AppColors.gray,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationCard(TextTheme textTheme) {
    return _buildSettingsCard(
      icon: Icons.navigation_outlined,
      title: 'Modo de Navegação',
      description: 'Escolha como deseja navegar pelo aplicativo.',
      child: Row(
        children: [
          Expanded(
            child: _buildChoiceButton(
              label: 'Padrão',
              subtitle: 'Todas as opções visíveis',
              selected: _navigation == 'default',
              onTap: () => setState(() => _navigation = 'default'),
              alignStart: true,
              labelStyle: textTheme.titleMedium,
              subtitleStyle: textTheme.bodyMedium?.copyWith(fontSize: 14),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildChoiceButton(
              label: 'Simplificado',
              subtitle: 'Apenas o essencial',
              selected: _navigation == 'simple',
              onTap: () => setState(() => _navigation = 'simple'),
              alignStart: true,
              labelStyle: textTheme.titleMedium,
              subtitleStyle: textTheme.bodyMedium?.copyWith(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalPrefsCard(TextTheme textTheme) {
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
            value: _extraConfirmations,
            onChanged: (value) => setState(() => _extraConfirmations = value),
          ),
          const SizedBox(height: 4),
          Container(height: 1, color: AppColors.lightGray),
          const SizedBox(height: 4),
          _buildSwitchRow(
            icon: Icons.notifications_none_outlined,
            title: 'Lembretes e notificações',
            subtitle: 'Receber avisos de tarefas e compromissos',
            value: _notifications,
            onChanged: (value) => setState(() => _notifications = value),
          ),
          const SizedBox(height: 4),
          Container(height: 1, color: AppColors.lightGray),
          const SizedBox(height: 4),
          _buildSwitchRow(
            icon: Icons.volume_up_outlined,
            title: 'Alertas sonoros',
            subtitle: 'Sons ao concluir tarefas e receber lembretes',
            value: _soundAlerts,
            onChanged: (value) => setState(() => _soundAlerts = value),
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
        onPressed: () {
          setState(() {
            _fontSize = 'normal';
            _contrast = 'normal';
            _navigation = 'default';
            _extraConfirmations = false;
            _notifications = true;
            _soundAlerts = false;
          });
        },
        icon: const Icon(Icons.refresh, size: 24, color: AppColors.darkBlue),
        label: Text(
          'Restaurar configurações padrão',
          style: textTheme.titleMedium?.copyWith(color: AppColors.darkBlue),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.lightGray, width: 2),
          backgroundColor: AppColors.grey98,
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
    required String label,
    String? subtitle,
    required bool selected,
    required VoidCallback onTap,
    TextStyle? labelStyle,
    TextStyle? subtitleStyle,
    bool alignStart = false,
  }) {
    return Material(
      color: selected ? AppColors.linkWater : AppColors.white,
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
              color: selected ? AppColors.lightBlue : AppColors.lightGray,
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
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lightGray, width: 2),
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
                    color: AppColors.darkBlue,
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
            inactiveTrackColor: AppColors.lightGray,
            thumbColor: const WidgetStatePropertyAll(AppColors.grey98),
            trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
          ),
        ],
      ),
    );
  }
}
