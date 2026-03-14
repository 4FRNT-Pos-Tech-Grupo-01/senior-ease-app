import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_ease/app_router.dart';
import 'package:senior_ease/theme/app_theme.dart';
import 'package:senior_ease/widgets/large_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _fontSizeIndex = 0;

  int _contrastIndex = 0;

  int _navModeIndex = 0;
  bool _extraConfirmations = false;
  bool _remindersNotifications = true;
  bool _soundAlerts = false;

  static const double _headerHeight = 74;
  static const double _headerPaddingH = 16;
  static const double _headerPaddingV = 12;
  static const double _logoSize = 48;
  static const double _logoRadius = 12;
  static const double _contentPaddingH = 16;
  static const double _contentPaddingTop = 24;
  static const double _contentPaddingBottom = 48;
  static const double _gapBetweenCards = 16;
  static const double _gapBetweenSections = 24;
  static const double _cardRadius = 12;
  static const double _cardBorderWidth = 2;
  static const double _cardPadding = 24;
  static const double _optionBorderRadius = 12;
  static const double _iconSize = 24;
  static const double _iconSizeSmall = 20;
  static const double _buttonMinHeight = 48;
  static const double _buttonPaddingH = 18;
  static const double _buttonPaddingV = 10;
  static const double _buttonGap = 8;
  static const double _buttonSpacing = 16;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.grey98,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context, textTheme)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                _contentPaddingH,
                _contentPaddingTop,
                _contentPaddingH,
                _contentPaddingBottom,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildUserCard(textTheme),
                  const SizedBox(height: _gapBetweenSections),
                  _buildFontSizeCard(textTheme),
                  const SizedBox(height: _gapBetweenSections),
                  _buildContrastCard(textTheme),
                  const SizedBox(height: _gapBetweenSections),
                  _buildNavModeCard(textTheme),
                  const SizedBox(height: _gapBetweenSections),
                  _buildAdditionalPreferencesCard(textTheme),
                  const SizedBox(height: _gapBetweenSections),
                  _buildRestoreButton(textTheme),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TextTheme textTheme) {
    return Container(
      height: _headerHeight,
      padding: const EdgeInsets.symmetric(
        horizontal: _headerPaddingH,
        vertical: _headerPaddingV,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.lightGray, width: _cardBorderWidth),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Semantics(
            label: 'Logo Senior Ease',
            child: Container(
              width: _logoSize,
              height: _logoSize,
              decoration: BoxDecoration(
                color: AppColors.lightBlue,
                borderRadius: BorderRadius.circular(_logoRadius),
              ),
              child: const Icon(Icons.favorite_outline, color: AppColors.white, size: _iconSize),
            ),
          ),
          const SizedBox(width: _buttonSpacing),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _headerButton(
                  context,
                  textTheme,
                  icon: Icons.home_outlined,
                  label: 'Home',
                  onTap: () => context.go(AppRouter.screen2),
                  semanticLabel: 'Voltar para a home',
                ),
                const SizedBox(width: _buttonSpacing),
                _headerButton(
                  context,
                  textTheme,
                  icon: Icons.logout,
                  label: 'Sair',
                  onTap: () => context.go(AppRouter.screen1),
                  semanticLabel: 'Sair',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerButton(
    BuildContext context,
    TextTheme textTheme, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required String semanticLabel,
  }) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: AppColors.grey98,
        borderRadius: BorderRadius.circular(_logoRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(_logoRadius),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: _buttonPaddingH,
              vertical: _buttonPaddingV,
            ),
            constraints: const BoxConstraints(minHeight: _buttonMinHeight),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: _iconSizeSmall, color: AppColors.darkBlue),
                const SizedBox(width: _buttonGap),
                Text(label, style: textTheme.titleMedium?.copyWith(fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(TextTheme textTheme) {
    return Semantics(
      container: true,
      label: 'Usuário Senior Ease, usuario@email.com',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(_cardPadding),
        decoration: BoxDecoration(
          color: AppColors.lightGray.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(_cardRadius),
          border: Border.all(color: AppColors.lightGray, width: _cardBorderWidth),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.lightBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_outline, color: AppColors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Usuário Senior Ease',
                    style: textTheme.headlineMedium?.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'usuario@email.com',
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.darkBlue,
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

  /// Tamanho da Fonte (título + descrição + 3 opções dentro do mesmo card)
  Widget _buildFontSizeCard(TextTheme textTheme) {
    return LargeCard(
      padding: const EdgeInsets.all(_cardPadding),
      semanticLabel: 'Tamanho da fonte',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                'T',
                style: textTheme.headlineMedium?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.lightBlue,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Tamanho da Fonte',
                style: textTheme.headlineMedium?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Escolha o tamanho de texto mais confortável para leitura.',
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 16,
              color: AppColors.gray,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _fontSizeOption(textTheme, 0, 'Normal', 16)),
              const SizedBox(width: 12),
              Expanded(child: _fontSizeOption(textTheme, 1, 'Grande', 20)),
              const SizedBox(width: 12),
              Expanded(child: _fontSizeOption(textTheme, 2, 'Extra Grande', 24)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fontSizeOption(TextTheme textTheme, int index, String label, double aaSize) {
    final selected = _fontSizeIndex == index;
    return Semantics(
      button: true,
      label: '$label. ${selected ? "Selecionado" : ""}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _fontSizeIndex = index),
          borderRadius: BorderRadius.circular(_optionBorderRadius),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: selected ? AppColors.linkWater : AppColors.white,
              border: Border.all(
                color: selected ? AppColors.lightBlue : AppColors.lightGray,
                width: _cardBorderWidth,
              ),
              borderRadius: BorderRadius.circular(_optionBorderRadius),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Aa',
                  style: textTheme.titleMedium?.copyWith(
                    fontSize: aaSize,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    color: AppColors.gray,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Nível de Contraste (título + descrição + opções dentro do mesmo card)
  Widget _buildContrastCard(TextTheme textTheme) {
    return LargeCard(
      padding: const EdgeInsets.all(_cardPadding),
      semanticLabel: 'Nível de contraste',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.lightBlue.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  'i',
                  style: textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                    color: AppColors.lightBlue,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Nível de Contraste',
                style: textTheme.headlineMedium?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Aumente o contraste para melhor visibilidade.',
            style: textTheme.bodyMedium?.copyWith(fontSize: 16, color: AppColors.gray),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _selectableOption(
                  textTheme,
                  selected: _contrastIndex == 0,
                  label: 'Normal',
                  onTap: () => setState(() => _contrastIndex = 0),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _selectableOption(
                  textTheme,
                  selected: _contrastIndex == 1,
                  label: 'Alto Contraste',
                  onTap: () => setState(() => _contrastIndex = 1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Modo de Navegação (título + descrição + opções dentro do mesmo card)
  Widget _buildNavModeCard(TextTheme textTheme) {
    return LargeCard(
      padding: const EdgeInsets.all(_cardPadding),
      semanticLabel: 'Modo de navegação',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.send_outlined, color: AppColors.lightBlue, size: _iconSize),
              const SizedBox(width: 8),
              Text(
                'Modo de Navegação',
                style: textTheme.headlineMedium?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Escolha como deseja navegar pelo aplicativo.',
            style: textTheme.bodyMedium?.copyWith(fontSize: 16, color: AppColors.gray),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _navModeOption(
                  textTheme,
                  selected: _navModeIndex == 0,
                  label: 'Padrão',
                  subtitle: 'Todas as opções visíveis',
                  onTap: () => setState(() => _navModeIndex = 0),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _navModeOption(
                  textTheme,
                  selected: _navModeIndex == 1,
                  label: 'Simplificado',
                  subtitle: 'Apenas o essencial',
                  onTap: () => setState(() => _navModeIndex = 1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _selectableOption(
    TextTheme textTheme, {
    required bool selected,
    required String label,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      label: '$label. ${selected ? "Selecionado" : ""}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(_optionBorderRadius),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: selected ? AppColors.linkWater : AppColors.white,
              border: Border.all(
                color: selected ? AppColors.lightBlue : AppColors.lightGray,
                width: _cardBorderWidth,
              ),
              borderRadius: BorderRadius.circular(_optionBorderRadius),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.darkBlue,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navModeOption(
    TextTheme textTheme, {
    required bool selected,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      label: '$label. $subtitle. ${selected ? "Selecionado" : ""}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(_optionBorderRadius),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: selected ? AppColors.linkWater : AppColors.white,
              border: Border.all(
                color: selected ? AppColors.lightBlue : AppColors.lightGray,
                width: _cardBorderWidth,
              ),
              borderRadius: BorderRadius.circular(_optionBorderRadius),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    color: AppColors.gray,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Preferências Adicionais (título + 3 linhas com ícone + texto + Switch no mesmo card)
  Widget _buildAdditionalPreferencesCard(TextTheme textTheme) {
    return LargeCard(
      padding: const EdgeInsets.all(_cardPadding),
      semanticLabel: 'Preferências adicionais',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.verified_user_outlined, color: AppColors.lightBlue, size: _iconSize),
              const SizedBox(width: 8),
              Text(
                'Preferências Adicionais',
                style: textTheme.headlineMedium?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _preferenceRow(
            textTheme,
            icon: Icons.verified_user_outlined,
            title: 'Confirmações extras',
            subtitle: 'Pedir confirmação antes de ações importantes',
            value: _extraConfirmations,
            onChanged: (v) => setState(() => _extraConfirmations = v),
          ),
          const SizedBox(height: 12),
          _preferenceRow(
            textTheme,
            icon: Icons.notifications_outlined,
            title: 'Lembretes e notificações',
            subtitle: 'Receber avisos de tarefas e compromissos',
            value: _remindersNotifications,
            onChanged: (v) => setState(() => _remindersNotifications = v),
          ),
          const SizedBox(height: 12),
          _preferenceRow(
            textTheme,
            icon: Icons.volume_up_outlined,
            title: 'Alertas sonoros',
            subtitle: 'Sons ao concluir tarefas e receber lembretes',
            value: _soundAlerts,
            onChanged: (v) => setState(() => _soundAlerts = v),
          ),
        ],
      ),
    );
  }

  Widget _preferenceRow(
    TextTheme textTheme, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.lightBlue, size: _iconSize),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkBlue,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  color: AppColors.gray,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.lightBlue,
        ),
      ],
    );
  }

  /// Botão: Restaurar configurações padrão (borda azul clara, ícone refresh, texto azul)
  Widget _buildRestoreButton(TextTheme textTheme) {
    return Semantics(
      button: true,
      label: 'Restaurar configurações padrão',
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(_cardRadius),
        child: InkWell(
          onTap: () {
            setState(() {
              _fontSizeIndex = 0;
              _contrastIndex = 0;
              _navModeIndex = 0;
              _extraConfirmations = false;
              _remindersNotifications = true;
              _soundAlerts = false;
            });
          },
          borderRadius: BorderRadius.circular(_cardRadius),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: AppColors.linkWater, width: _cardBorderWidth),
              borderRadius: BorderRadius.circular(_cardRadius),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.restart_alt, color: AppColors.lightBlue, size: _iconSize),
                const SizedBox(width: 12),
                Text(
                  'Restaurar configurações padrão',
                  style: textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightBlue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
