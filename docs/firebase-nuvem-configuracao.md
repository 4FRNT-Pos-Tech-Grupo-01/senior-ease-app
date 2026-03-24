# Configuração: dados na nuvem por utilizador (Firebase Auth + Firestore)

Este documento orienta a configuração completa para **login**, **persistência por utilizador**, **vários dispositivos** e **backup** após reinstalar ou mudar de telemóvel, usando **Firebase Authentication** e **Cloud Firestore** num projeto **Flutter**.

> **Pré-requisitos:** conta Google, Flutter SDK instalado, projeto Flutter (ex.: Senior Ease) a compilar para Android e/ou iOS.

---

## 1. Visão geral da arquitetura

| Componente | Função |
|------------|--------|
| **Firebase Auth** | Identifica o utilizador (`uid`). Sem sessão válida, não acedes aos dados desse utilizador nas regras do Firestore. |
| **Cloud Firestore** | Base de dados na nuvem; documentos organizados por `uid` (ou com campo `userId`). |
| **Regras de segurança** | Garantem no **servidor** que cada utilizador só lê/escreve os **seus** dados. |
| **Notificações locais** (opcional) | Continuam no dispositivo; sincronizas a lista de lembretes a partir do Firestore quando a app arranca ou quando os dados mudam. |

Fluxo típico: utilizador faz login → app obtém `uid` → leitura/escrita em caminhos como `users/{uid}/...` → noutro telemóvel, o mesmo login mostra os mesmos dados.

---

## 2. Criar o projeto Firebase

1. Abre [Firebase Console](https://console.firebase.google.com/).
2. **Adicionar projeto** → nome (ex.: `senior-ease`) → podes desativar o Google Analytics no primeiro passo se quiseres simplificar (ou ativar para métricas).
3. Conclui a criação.

---

## 3. Registar as apps (Android e iOS)

### 3.1 Android

1. No painel do projeto Firebase: ícone **Android** → adicionar app Android.
2. **Nome do pacote Android** tem de ser **igual** ao do teu `android/app/build.gradle.kts` (ou `build.gradle`), em `defaultConfig.applicationId` (ex.: `com.example.senior_ease` — confirma no teu projeto).
3. Descarrega `google-services.json`.
4. Coloca o ficheiro em **`android/app/google-services.json`** (não na pasta `android/` raiz).

No **`android/settings.gradle.kts`** (projeto novo) ou **`android/build.gradle`**, o plugin Google Services é necessário; no template atual do Flutter costuma estar no **`android/app/build.gradle.kts`**:

- No ficheiro **a nível do projeto** (`android/settings.gradle.kts`), o plugin `com.google.gms.google-services` pode vir declarado na secção `plugins`.
- No **`android/app/build.gradle.kts`**, aplica o plugin no final:

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Firebase
}
```

Se o build falhar a dizer que falta o plugin, segue a [documentação oficial FlutterFire](https://firebase.flutter.dev/docs/manual-installation/android/) para a versão do teu template.

**SHA-1 (para Google Sign-In e outras APIs):**

- Desenvolvimento: `cd android && ./gradlew signingReport` (ou no Android Studio: Gradle → `signingReport`) e adiciona o **SHA-1** de debug em Firebase → Definições do projeto → a tua app Android.

### 3.2 iOS

1. No Firebase Console: ícone **iOS** → adicionar app iOS.
2. **Bundle ID** igual ao de **`ios/Runner.xcodeproj`** / `PRODUCT_BUNDLE_IDENTIFIER` em `ios/Runner.xcconfig` ou no Xcode (ex.: `com.example.seniorEase`).
3. Descarrega `GoogleService-Info.plist`.
4. Arrasta para **`ios/Runner/`** no Xcode (ou copia para `ios/Runner/GoogleService-Info.plist`) e garante que o target **Runner** está marcado.

**Nota:** no `ios/Podfile`, a plataforma mínima deve ser compatível com as versões dos pods do Firebase (muitas vezes **iOS 13+**).

---

## 4. Ativar Authentication e Firestore

### 4.1 Authentication

1. Firebase Console → **Authentication** → **Começar**.
2. Em **Sign-in method**, ativa os métodos que vais usar:
   - **E-mail/palavra-passe** — o mais simples para começar.
   - **Google** — comum em Android; requer configuração extra no iOS (URL schemes no `Info.plist`).
   - **Apple** — recomendado se ofereceres **outros** logins de terceiros na app iOS (requisito típico da App Store).

### 4.2 Firestore

1. **Firestore Database** → **Criar base de dados**.
2. Modo: para aprender, podes começar em **modo de teste** (expira em 30 dias) **mas** deves substituir rapidamente por regras seguras (secção 6).
3. Escolhe uma localização (ex.: `europe-west1` ou `europe-west3`) — **não muda** depois.

---

## 5. Flutter: FlutterFire CLI e dependências

### 5.1 Instalar CLI (uma vez na máquina)

```bash
dart pub global activate flutterfire_cli
```

Garante que o diretório do pub global está no `PATH` (a mensagem do comando indica o caminho).

### 5.2 Configurar o projeto Flutter

Na **raiz** do projeto Flutter:

```bash
flutterfire configure
```

- Seleciona o projeto Firebase e as plataformas (Android, iOS, macOS, web, etc.).
- Isto gera **`lib/firebase_options.dart`** com as chaves do projeto — **não commits** este ficheiro em repositórios públicos se contiverem dados sensíveis do projeto; em muitos casos é aceitável em repo privado de faculdade, mas evita expor chaves em projetos abertos.

### 5.3 Dependências no `pubspec.yaml`

Adiciona (versões atuais em [pub.dev](https://pub.dev)):

```yaml
dependencies:
  firebase_core: ^<versão>
  firebase_auth: ^<versão>
  cloud_firestore: ^<versão>
```

Depois:

```bash
flutter pub get
```

### 5.4 Inicializar o Firebase no arranque

No **`main.dart`**, antes de `runApp`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
```

(Adapta o nome da classe da app ao teu projeto.)

---

## 6. Regras de segurança do Firestore (obrigatório para produção)

Exemplo para dados **só do utilizador autenticado**, em subcoleções sob `users/{userId}/...`:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

- **`request.auth.uid`** tem de coincidir com **`userId`** no caminho.
- Publica as regras em **Firestore** → **Regras**.

**Nunca** deixes `allow read, write: if true` em produção.

---

## 7. Modelo de dados sugerido

Exemplo alinhado com lembretes / tarefas / histórico:

| Caminho | Conteúdo |
|---------|----------|
| `users/{uid}/reminders/{reminderId}` | `title`, `scheduledAt` (Timestamp), `notificationId`, `iconIndex` |
| `users/{uid}/home/tasks` | Documento com array `items`: tarefas (`id`, `title`, `completed`) |
| `users/{uid}/home/guided` | Documento com array `steps`: etapas guiadas (`id`, `title`, `completed`, `order`); migração antiga: `stepsDone` (bool[]) |
| `users/{uid}/meta/local` | `nextNotificationId` (contador para IDs de notificação local) |
| `users/{uid}/activityHistory/{entryId}` | `title`, `recordedAt` (Timestamp) |

Usa **tipos compatíveis com Firestore** (Timestamp para datas, não `DateTime` Dart direto — converte com `Timestamp.fromDate` / `.toDate()`).

---

## 8. Fluxo na app Flutter (resumo de implementação)

1. **Ecrã de login / registo** com `FirebaseAuth.instance.createUserWithEmailAndPassword` / `signInWithEmailAndPassword` (ou outros providers).
2. **Listener** de estado: `FirebaseAuth.instance.authStateChanges()` para mostrar a app principal só quando `user != null`.
3. **Firestore:** `FirebaseFirestore.instance.collection('users').doc(uid).collection('reminders')` — sempre com o `uid` do utilizador atual.
4. **Logout:** `FirebaseAuth.instance.signOut()`.
5. **Offline:** o Firestore pode manter cache local; consulta [documentação `enablePersistence`](https://firebase.google.com/docs/firestore/manage-data/enable-offline) / comportamento predefinido nas plataformas móveis.

---

## 9. Checklist antes de publicar nas stores

- [ ] Regras do Firestore restritivas e testadas (utilizador A não vê dados de B).
- [ ] Política de **privacidade** (URL) nas lojas; mencionar Firebase/Google conforme o que recolhes.
- [ ] **Eliminação de conta** e dados (requisito comum Apple/Google): ou fluxo na app ou página de suporte com processo claro.
- [ ] iOS: se usares login Google/Facebook, avalia **Sign in with Apple**.
- [ ] `google-services.json` e `GoogleService-Info.plist` no repositório apenas se o repo for privado e a equipa estiver alinhada; para open source, usa variáveis/segredos ou documentação sem ficheiros reais.

---

## 10. Documentação oficial útil

- [FlutterFire](https://firebase.flutter.dev/)
- [Firebase Auth](https://firebase.google.com/docs/auth)
- [Cloud Firestore](https://firebase.google.com/docs/firestore)
- [Regras de segurança](https://firebase.google.com/docs/firestore/security/get-started)

---

## 11. Próximo passo no código (Senior Ease)

Integrar de forma incremental:

1. `main.dart` + `firebase_options.dart` + dependências.
2. Ecrã de **login/registo** e **guard** de rotas (ex.: `go_router` com redirect se não houver sessão).
3. Serviço que **espelha** o que hoje está em `SharedPreferences` para **Firestore** (lembretes, definições, histórico), mantendo notificações locais sincronizadas após `load`/`snapshot`.

Quando fores implementar, podes pedir no projeto para ligar um fluxo concreto (por exemplo só **reminders** primeiro).
