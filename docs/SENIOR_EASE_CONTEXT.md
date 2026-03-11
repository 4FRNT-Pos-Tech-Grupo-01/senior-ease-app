# Senior Ease — Documentação de Contexto

Documentação de contexto para implementação da aplicação **Senior Ease** em Flutter, com base exclusiva no design do Figma.

---

## Referência do design

- **Figma:** https://www.figma.com/design/pvTVSqETPP9BAlnMbaAgI0/Senior-Ease?node-id=8-295&t=ykosDlo4HFcWpzW8-0
- **Nome da aplicação:** Senior Ease
- **Público-alvo:** Utilizadores sénior — priorizar acessibilidade.

---

## Regra mais importante

**NÃO INVENTAR FUNCIONALIDADES.**

A aplicação deve implementar **apenas**:

- Ecrãs existentes no Figma  
- Componentes existentes no Figma  
- Fluxos existentes no Figma  

Se alguma funcionalidade **não** estiver no Figma: **não implementar.**

Se algo estiver pouco claro no design:

1. Assumir o comportamento mais simples possível  
2. Manter a interface consistente com o design  
3. **Não** adicionar novas features  

---

## Objetivo

Converter o design do Figma numa aplicação Flutter funcional, mantendo:

- Layout  
- Componentes  
- Hierarquia visual  
- Tipografia  
- Cores  
- Espaçamento  
- Navegação  

exatamente como definido no Figma.

---

## Stack técnico

| Área | Tecnologia |
|------|------------|
| Framework | Flutter (última versão estável) |
| Design system | Material 3 |
| Linguagem | Dart |
| Gestão de estado | Riverpod ou Provider |
| Navegação | GoRouter |

---

## Arquitetura do projeto

Estrutura recomendada:

```
lib/
  core/
    theme/
    router/
    accessibility/
  features/
    onboarding/
    home/
    reminders/
    contacts/
    sos/
    settings/
  widgets/
  services/
```

---

## Acessibilidade (obrigatório)

A aplicação é destinada a utilizadores sénior. Implementar acessibilidade **sem** alterar o design visual do Figma.

Requisitos:

- Suporte para screen readers  
- Uso de `Semantics` onde fizer sentido  
- Text scaling (respeitar configurações do sistema)  
- Alvos de toque **≥ 48px**  
- Labels acessíveis  
- Contraste adequado  
- Focus traversal correto  

**Não** alterar o layout para adicionar novas features de acessibilidade visuais; apenas garantir que o que existe no Figma seja acessível.

---

## Processo de implementação

Cada etapa deve gerar **um commit**. Cada commit deve incluir:

- Mensagem de commit clara  
- Ficheiros alterados (resumidos na mensagem ou em descrição)  
- Explicação do que foi feito  
- Comandos git utilizados  

---

### STEP 1 — Projeto Flutter

- Criar projeto: `flutter create senior_ease`  
- **Commit:** `Initial Flutter project setup`  

---

### STEP 2 — Estrutura de pastas

- Criar pastas conforme a arquitetura (`lib/core/`, `lib/features/`, etc.).  
- **Commit:** `Project structure setup`  

---

### STEP 3 — Tema a partir do Figma

- Extrair do Figma: cores, tipografia, spacing, componentes.  
- Criar `theme.dart` (em `core/theme/`).  
- **Commit:** `Theme based on Figma design`  

---

### STEP 4 — Navegação

- Configurar navegação **apenas** para as telas presentes no Figma.  
- **Commit:** `Navigation system`  

---

### STEP 5 — Componentes reutilizáveis

- Criar componentes baseados no Figma: botões, cards, listas, componentes de navegação.  
- **Commit:** `Reusable UI components`  

---

### STEP 6 — Implementação de ecrãs

Implementar **cada** tela existente no Figma. Para cada tela:

1. Criar pasta da feature  
2. Criar screen  
3. Criar widgets necessários  

Cada tela deve gerar **um commit** próprio, por exemplo:

- `Home screen implementation`  
- `Reminders screen implementation`  
- `Contacts screen implementation`  
- `SOS screen implementation`  
- `Settings screen implementation`  

(Os nomes exatos das features/ecrãs devem ser validados no Figma.)

---

### STEP 7 — Acessibilidade

- Adicionar Semantics, labels e ordem de foco **sem** alterar layout.  
- **Commit:** `Accessibility improvements`  

---

### STEP 8 — Refino da UI

- Alinhar 100% com o Figma: cores, fontes, spacing, ícones, layout.  
- **Commit:** `UI refinement based on Figma`  

---

### STEP 9 — Preparação para GitHub

- Adicionar README, screenshots e descrição da estrutura do projeto.  
- **Commit:** `Project ready for GitHub`  

---

## Output esperado por etapa

Para cada etapa, documentar ou entregar:

1. Código Flutter relevante  
2. Ficheiros criados/alterados  
3. Estrutura de pastas afetada  
4. Mensagem de commit  
5. Comandos git (ex.: `git add .`, `git commit -m "..."`, `git push`)  

Exemplo:

```bash
git add .
git commit -m "Home screen implementation"
git push
```

---

## Regras finais

- **Nunca** inventar novas funcionalidades.  
- **Nunca** alterar o fluxo definido no Figma.  
- **Sempre** priorizar fidelidade ao design do Figma.  

---

*Documento de contexto — Senior Ease. Consultar o Figma como fonte única de verdade para ecrãs, componentes e fluxos.*
