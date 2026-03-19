# Senior Ease

Aplicação Flutter para utilizadores sénior, com foco em acessibilidade e fidelidade ao design.

## Estrutura do projeto

```
lib/
  main.dart
  app.dart
  app_router.dart
  models/
  services/
  theme/
  screens/
  widgets/
```

## Lembretes (notificações locais)

Na **Screen 2 (início)**, a secção **Lembretes** guarda dados em `shared_preferences` e agenda **notificações locais** em **Android**, **iOS** e **macOS** (com permissões no manifesto / Info.plist). Na **web** e em **Linux/Windows** desktop, a lista funciona sem notificação do sistema.

- Primeira abertura: três lembretes de exemplo são criados automaticamente.
- Botão **+**: novo lembrete (texto, data/hora, ícone).
- **Apagar**: ícone do caixote no cartão.
- **Após a hora do lembrete**, o cartão continua na lista durante **6 horas**; só depois é **removido automaticamente** (a app verifica a cada 2 s e ao voltar ao primeiro plano). Isto **não depende** de teres visto ou recebido a notificação — se a notificação falhar, ainda podes ver o lembrete na app nesse período. Podes apagar manualmente antes com o ícone do caixote.

### Não recebo notificações — o que verificar

**Android**

1. **Definições → Apps → Senior Ease → Notificações** — ativadas; canal **Lembretes** também.
2. **Alarmes e lembretes / Alarmes exatos** — na primeira execução a app pede; se recusaste, abre **Definições → Apps → Senior Ease → Alarmes e lembretes** e permite.
3. Cria um lembrete **daqui a 1–2 minutos** e **bloqueia o ecrã** ou minimiza a app (alguns fabricantes só mostram fora da app em primeiro plano).
4. No terminal do `flutter run`, procura linhas `NotificationService:` (confirma se agendou e se `POST_NOTIFICATIONS` / alarmes exatos foram aceites).

**iPhone**

1. Quando a app pedir, aceita **Notificações**.
2. **Definições → Notificações → Senior Ease** — **Permitir notificações**, **Alertas** (ou Banners) e **Sons** ativos.
3. Com a app **aberta em primeiro plano**, o iOS só mostra banner se as notificações estiverem bem configuradas; testa também com a app em **segundo plano** ou **ecrã bloqueado**.
4. **Concentração / Focus** — se estiver ativo, permite notificações **Sensíveis ao tempo** para Senior Ease ou testa com Focus desligado.
5. Cria um lembrete **daqui a 1–2 minutos** para validar (app em **segundo plano** ou ecrã bloqueado).
6. No terminal do `flutter run`, confirma linhas `NotificationService:` (`enabled=true`, `agendado id=...`). Em **release** (`flutter run --release`) o comportamento de notificações costuma ser o mais fiável.

**Web / Linux / Windows** — notificações locais deste projeto **não** são suportadas; só a lista na app.

### Como a notificação deve aparecer no iPhone

- **Ecrã bloqueado**: banner na parte superior ou na lista ao desbloquear.
- **Outra app ou ecrã inicial**: **banner** no topo e som (se ativo nas definições).
- **Centro de notificações**: puxar de cima para baixo.
- **Com a Senior Ease aberta em primeiro plano**: também pode aparecer **banner** (depende das opções da app nas definições).

**Teste fiável:** escolhe uma hora **pelo menos 2 minutos à frente** (a app pede isso ao criar o lembrete). Se escolheres só o minuto imediato, ao guardar o relógio muitas vezes **já passou** desse minuto (o picker usa segundos `00`) e **nada é agendado** — não é bug do iOS, é o instante já estar no passado.

Coloca a app em **segundo plano** ou bloqueia o ecrã antes da hora do teste.

## Requisitos

- Flutter (versão estável)
- Dart 3.x

## Como executar

```bash
flutter pub get
flutter run
```

Para listar dispositivos disponíveis:

```bash
flutter devices
```

## Design

Design no Figma: [Senior Ease](https://www.figma.com/design/pvTVSqETPP9BAlnMbaAgI0/Senior-Ease)

## Tecnologias

- Flutter
- Dart
- Material 3
- GoRouter
