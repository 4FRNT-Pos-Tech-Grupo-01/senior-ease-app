import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_ease/app_router.dart';
import 'package:senior_ease/services/auth_error_messages.dart';
import 'package:senior_ease/theme/app_theme.dart';

class Screen1 extends StatefulWidget {
  const Screen1({super.key});

  @override
  State<Screen1> createState() => _Screen1State();
}

class _Screen1State extends State<Screen1> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _signIn() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      if (_rememberMe) {
        _showSnack('Sessão mantida neste dispositivo.');
      }
    } on FirebaseAuthException catch (e) {
      _showSnack(messageForFirebaseAuthException(e));
    } catch (_) {
      _showSnack('Não foi possível iniciar sessão. Tente novamente.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _sendPasswordReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showSnack('Indique um email válido no campo acima.');
      return;
    }
    setState(() => _submitting = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      _showSnack('Enviámos instruções para o seu email.');
    } on FirebaseAuthException catch (e) {
      _showSnack(messageForFirebaseAuthException(e));
    } catch (_) {
      _showSnack('Não foi possível enviar o email. Tente novamente.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
          style: textTheme.bodyMedium?.copyWith(fontSize: 16, height: 24 / 16),
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
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(34),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.outline, width: 2),
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
            const SizedBox(height: 12),
            _buildRememberMeRow(theme),
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
    // Não envolver o TextFormField em Semantics(textField: true) no pai — em
    // alguns alvos (ex.: macOS) isso pode roubar foco/toques do campo.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Endereço de email', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          decoration: const InputDecoration(hintText: 'exemplo@exemplo.com'),
          style: theme.textTheme.bodyMedium,
          validator: (value) {
            final v = value?.trim() ?? '';
            if (v.isEmpty) return 'Insira o seu email';
            if (!v.contains('@')) return 'Email inválido';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Senha', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Stack(
          alignment: Alignment.centerRight,
          children: [
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              autofillHints: const [AutofillHints.password],
              decoration: const InputDecoration(hintText: 'Insira sua senha'),
              style: theme.textTheme.bodyMedium,
              validator: (value) {
                final v = value ?? '';
                if (v.isEmpty) return 'Insira a sua senha';
                if (v.length < 6) {
                  return 'A senha deve ter pelo menos 6 caracteres';
                }
                return null;
              },
            ),
            Semantics(
              label: _obscurePassword ? 'Mostrar senha' : 'Ocultar senha',
              button: true,
              child: IconButton(
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRememberMeRow(ThemeData theme) {
    return Semantics(
      checked: _rememberMe,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _rememberMe = !_rememberMe),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(
                  value: _rememberMe,
                  onChanged: (value) {
                    setState(() => _rememberMe = value ?? false);
                  },
                  activeColor: AppColors.lightBlue,
                  side: BorderSide(color: theme.colorScheme.outline, width: 2),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                Expanded(
                  child: Text(
                    'Manter-me conectado neste dispositivo',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
          onPressed: _submitting ? null : _sendPasswordReset,
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
        onPressed: _submitting ? null : _signIn,
        child: _submitting
            ? const SizedBox(
                height: 28,
                width: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
            : Row(
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
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      children: [
        Text('Não possui uma conta?', style: textTheme.bodyLarge),
        Semantics(
          link: true,
          label: 'Crie uma conta',
          child: TextButton(
            onPressed: _submitting ? null : () => context.push(AppRouter.register),
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
            onTap: () {
              _showSnack('Ligue para o apoio: 0-800-123-4567');
            },
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
