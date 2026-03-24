import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_ease/app_router.dart';
import 'package:senior_ease/services/auth_error_messages.dart';
import 'package:senior_ease/theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      context.go(AppRouter.screen2);
    } on FirebaseAuthException catch (e) {
      _showSnack(messageForFirebaseAuthException(e));
    } catch (_) {
      _showSnack('Não foi possível criar a conta. Tente novamente.');
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    'Criar conta',
                    style: textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Preencha email e senha para se registar.',
                    style: textTheme.bodyMedium?.copyWith(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(34),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.outline,
                        width: 2,
                      ),
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
                          Text(
                            'Endereço de email',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            decoration: const InputDecoration(
                              hintText: 'exemplo@exemplo.com',
                            ),
                            validator: (value) {
                              final v = value?.trim() ?? '';
                              if (v.isEmpty) return 'Insira o seu email';
                              if (!v.contains('@')) return 'Email inválido';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          Text('Senha', style: theme.textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Stack(
                            alignment: Alignment.centerRight,
                            children: [
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                autofillHints: const [AutofillHints.newPassword],
                                decoration: const InputDecoration(
                                  hintText: 'Mínimo 6 caracteres',
                                ),
                                validator: (value) {
                                  final v = value ?? '';
                                  if (v.isEmpty) return 'Insira uma senha';
                                  if (v.length < 6) {
                                    return 'A senha deve ter pelo menos 6 caracteres';
                                  }
                                  return null;
                                },
                              ),
                              Semantics(
                                label: _obscurePassword
                                    ? 'Mostrar senha'
                                    : 'Ocultar senha',
                                button: true,
                                child: IconButton(
                                  onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 48,
                                    minHeight: 48,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Confirmar senha',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Stack(
                            alignment: Alignment.centerRight,
                            children: [
                              TextFormField(
                                controller: _confirmController,
                                obscureText: _obscureConfirm,
                                autofillHints: const [AutofillHints.newPassword],
                                decoration: const InputDecoration(
                                  hintText: 'Repita a senha',
                                ),
                                validator: (value) {
                                  if ((value ?? '').isEmpty) {
                                    return 'Confirme a senha';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'As senhas não coincidem';
                                  }
                                  return null;
                                },
                              ),
                              Semantics(
                                label: _obscureConfirm
                                    ? 'Mostrar confirmação'
                                    : 'Ocultar confirmação',
                                button: true,
                                child: IconButton(
                                  onPressed: () => setState(
                                    () => _obscureConfirm = !_obscureConfirm,
                                  ),
                                  icon: Icon(
                                    _obscureConfirm
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 48,
                                    minHeight: 48,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Semantics(
                            button: true,
                            label: 'Registar',
                            child: ElevatedButton(
                              onPressed: _submitting ? null : _submit,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.person_add_outlined,
                                          color: AppColors.white,
                                          size: 28,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Registar',
                                          style: textTheme.labelLarge,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: _submitting
                        ? null
                        : () => context.go(AppRouter.screen1),
                    child: Text(
                      'Já tem conta? Iniciar sessão',
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.lightBlue,
                      ),
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
}
