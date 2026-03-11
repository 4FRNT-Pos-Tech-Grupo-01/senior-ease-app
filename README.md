# Senior Ease

Aplicação Flutter para utilizadores sénior, com base exclusiva no design do Figma. Prioriza acessibilidade e fidelidade ao design.

## Documentação de contexto

Toda a implementação segue o documento em **[docs/SENIOR_EASE_CONTEXT.md](docs/SENIOR_EASE_CONTEXT.md)**:

- Referência do design (Figma)
- Regras (não inventar funcionalidades; apenas o que existe no Figma)
- Stack: Flutter, Material 3, Riverpod, GoRouter
- Arquitetura: `lib/core/`, `lib/features/`, `lib/widgets/`, `lib/services/`
- Processo por etapas (STEP 1–9)

## Estrutura do projeto

```
lib/
  core/
    theme/       # Tema e tokens do Figma
    router/      # GoRouter
    accessibility/
  features/
    login/       # Ecrã de login (Figma node 8:295)
    onboarding/
    home/
    reminders/
    contacts/
    sos/
    settings/
  widgets/
  services/
```

## Como executar

```bash
flutter pub get
flutter run
```

## Design

- **Figma:** [Senior Ease](https://www.figma.com/design/pvTVSqETPP9BAlnMbaAgI0/Senior-Ease?node-id=8-295)
