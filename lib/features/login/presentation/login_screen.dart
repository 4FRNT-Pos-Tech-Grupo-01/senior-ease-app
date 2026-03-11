import 'package:flutter/material.dart';
import 'package:senior_ease/core/theme/app_theme.dart';

/// Ecrã de Login — implementação fiel ao Figma (node 8:295).
/// Apenas layout e componentes existentes no design.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: AppColors.grey98,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 448),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 43),
                  _buildHeader(context, textTheme),
                  const SizedBox(height: 32),
                  _buildFormCard(context, theme, textTheme),
                  const SizedBox(height: 32),
                  _buildHelpSection(textTheme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TextTheme textTheme) {
    return Column(
      children: [
        Semantics(
          image: true,
          label: 'Logo Senior Ease',
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.lightBlue,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.favorite_outline,
              color: AppColors.white,
              size: 40,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Senior Ease',
          style: textTheme.headlineLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Bem vindo! Por favor, faça login para iniciar ',
          style: textTheme.bodyMedium?.copyWith(
            fontSize: 16,
            height: 24 / 16,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFormCard(
    BuildContext context,
    ThemeData theme,
    TextTheme textTheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(34),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.lightGray, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 25,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildEmailField(theme),
            const SizedBox(height: 16),
            _buildPasswordField(theme),
            const SizedBox(height: 16),
            _buildForgotPasswordLink(textTheme),
            const SizedBox(height: 16),
            _buildLoginButton(textTheme),
            const SizedBox(height: 16),
            _buildRegisterPrompt(textTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField(ThemeData theme) {
    return Semantics(
      textField: true,
      label: 'Endereço de email',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Endereço de email',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'exemplo@exemplo.com',
            ),
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(ThemeData theme) {
    return Semantics(
      textField: true,
      label: 'Senha',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Senha',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Stack(
            alignment: Alignment.centerRight,
            children: [
              TextFormField(
                obscureText: _obscurePassword,
                decoration: const InputDecoration(
                  hintText: 'Insira sua senha',
                ),
                style: theme.textTheme.bodyMedium,
              ),
              Semantics(
                label: _obscurePassword
                    ? 'Mostrar senha'
                    : 'Ocultar senha',
                button: true,
                child: IconButton(
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.gray,
                    size: 24,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPasswordLink(TextTheme textTheme) {
    return Align(
      alignment: Alignment.centerRight,
      child: Semantics(
        link: true,
        label: 'Esqueceu a senha?',
        child: TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            foregroundColor: AppColors.lightBlue,
            padding: const EdgeInsets.symmetric(vertical: 12),
            minimumSize: const Size(48, 48),
          ),
          child: Text(
            'Esqueceu a senha?',
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: AppColors.lightBlue,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(TextTheme textTheme) {
    return Semantics(
      button: true,
      label: 'Login',
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState?.validate() ?? false) {
            // Navegação apenas se existir no Figma
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.login, color: AppColors.white, size: 28),
            const SizedBox(width: 8),
            Text('Login', style: textTheme.labelLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterPrompt(TextTheme textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Não possui uma conta?',
          style: textTheme.bodyLarge,
        ),
        const SizedBox(width: 8),
        Semantics(
          link: true,
          label: 'Crie uma conta',
          child: TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: AppColors.lightBlue,
              padding: const EdgeInsets.symmetric(vertical: 12),
              minimumSize: const Size(48, 48),
            ),
            child: Text(
              'Crie uma',
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.lightBlue,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHelpSection(TextTheme textTheme) {
    return Column(
      children: [
        Text(
          'Precisa de ajuda? Entre em contato ',
          style: textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        Semantics(
          link: true,
          label: 'Contacte apoio: 0-800-123-4567',
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '0-800-123-4567',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightBlue,
                  decoration: TextDecoration.underline,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
