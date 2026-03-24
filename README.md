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

Com **sessão Firebase Auth**, lembretes, tarefas, etapas guiadas e histórico ficam em **Cloud Firestore** sob `users/{uid}/...` (cada utilizador só vê o que criou). As **notificações** dos lembretes continuam **locais** em **Android**, **iOS** e **macOS** (manifesto / Info.plist). Na **web** e em **Linux/Windows** desktop, a lista funciona sem notificação do sistema.

- Os lembretes são **criados por ti** e guardados na tua conta (Firestore); não há lista de exemplo automática.
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

- [Flutter](https://docs.flutter.dev/get-started/install) (canal **stable**, SDK compatível com o `environment` do `pubspec.yaml`)
- [Dart](https://dart.dev/get-dart) (incluído no Flutter)
- Conta e projeto **Firebase** configurados para esta app (Auth, Firestore, ficheiros nativos — vê `docs/firebase-nuvem-configuracao.md`)
- Para **login Google em Android**: `lib/config/google_oauth.dart` com o ID cliente Web e `google-services.json` atualizado (SHA-1 no Firebase)

## Executar em modo de desenvolvimento

1. **Clonar o repositório** e entrar na pasta do projeto.

2. **Instalar dependências**

   ```bash
   flutter pub get
   ```

3. **Verificar o ambiente** (opcional mas recomendado)

   ```bash
   flutter doctor
   ```

   Corrige o que o comando indicar (Xcode, Android SDK, licenças, etc.).

4. **Ligar um dispositivo ou arrancar um emulador/simulador**

   ```bash
   flutter devices
   ```

   Escolhe o alvo com `-d`:

   ```bash
   flutter run -d chrome          # Web
   flutter run -d macos           # macOS desktop
   flutter run -d <device_id>     # telemóvel ou emulador listado
   ```

5. **Arrancar a app em modo debug** (padrão)

   ```bash
   flutter run
   ```

   - **Hot reload:** guardar ficheiros ou premir `r` no terminal.
   - **Hot restart:** `R` (maiúsculo).
   - **Sair:** `q`.

6. **Modo profile ou release** (mais próximo do que o utilizador final vê, útil para notificações no iOS)

   ```bash
   flutter run --profile
   flutter run --release
   ```

7. **Testes automatizados**

   ```bash
   flutter test
   ```

## Gerar builds (produção / instalação)

Os comandos abaixo geram artefactos na pasta `build/` (exceto onde indicado). Ajusta **nome da app**, **versão** e **assinaturas** em `pubspec.yaml`, Xcode e Gradle conforme as lojas.

### Android (APK — instalação direta)

```bash
flutter build apk --release
```

Ficheiro típico: `build/app/outputs/flutter-apk/app-release.apk`.

### Android (App Bundle — Google Play)

```bash
flutter build appbundle --release
```

Ficheiro típico: `build/app/outputs/bundle/release/app-release.aab`.

Configura **assinatura de release** em `android/app/build.gradle.kts` (ou via `key.properties`); o template do projeto pode ainda usar a chave de debug em release — altera antes de publicar.

### iOS (sem arquivo Xcode interativo — IPA para CI ou export manual)

```bash
flutter build ipa --release
```

Ou abre `ios/Runner.xcworkspace` no Xcode, escolhe **Any iOS Device**, **Product → Archive** e segue o assistente para App Store Connect / Ad Hoc.

Requisitos: Apple Developer, perfis de provisionamento e certificados corretos.

### Web

```bash
flutter build web --release
```

Saída em `build/web/` — serve com qualquer servidor estático ou hospeda em Firebase Hosting / outro hosting.

### macOS

```bash
flutter build macos --release
```

### Windows

```bash
flutter build windows --release
```

### Linux

```bash
flutter build linux --release
```

### Obter só os pacotes (CI)

```bash
flutter pub get
dart analyze
flutter test
```

Documentação oficial: [Build and release an app](https://docs.flutter.dev/deployment).

## Design

Design no Figma: [Senior Ease](https://www.figma.com/design/pvTVSqETPP9BAlnMbaAgI0/Senior-Ease)

## Documentação adicional

- Firebase, Auth, Firestore e login Google: [`docs/firebase-nuvem-configuracao.md`](docs/firebase-nuvem-configuracao.md)

## Tecnologias

- Flutter / Dart
- Material 3
- GoRouter
- Firebase (Core, Auth, Firestore)
- Google Sign-In
- Notificações locais (`flutter_local_notifications`)
