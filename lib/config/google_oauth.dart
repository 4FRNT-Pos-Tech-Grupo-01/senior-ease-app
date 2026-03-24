/// ID do cliente OAuth 2.0 **Web** (tipo "Cliente Web" nas credenciais Google).
///
/// **Android:** após ativar login Google no Firebase e adicionar a SHA-1, volta a
/// descarregar `google-services.json` — ou copia o ID em Firebase Console →
/// Definições do projeto → Suas aplicações → app **Web** (ou Google Cloud →
/// APIs e serviços → Credenciais). Formato: `NNNNNN-xxxxx.apps.googleusercontent.com`
///
/// Cola aqui para o Google Sign-In devolver `idToken` ao Firebase Auth.
/// Se ficar vazio, o login Google em Android pode falhar até configurares.
const String kGoogleOAuthWebClientId = '';
