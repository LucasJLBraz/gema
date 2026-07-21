# Onboarding: Chave da API Gemini Atualizada — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Corrigir o texto desatualizado do passo-a-passo de obtenção da chave Gemini no onboarding (formato da chave, limites de taxa) e tornar o processo mais claro para usuários leigos, incluindo um link clicável direto para o Google AI Studio.

**Architecture:** Mudança isolada em `_StepConfig`/`_Step` (`lib/features/onboarding/screens/onboarding_screen.dart`) — sem nova tela, sem novo provider. Adiciona a dependência `url_launcher` para abrir `https://aistudio.google.com` no navegador do usuário; corrige as strings de texto (formato de chave, limites de taxa) para bater com a realidade atual e com `CLAUDE.md`.

**Tech Stack:** Flutter, `url_launcher`, `flutter_test`.

## Global Constraints

- Origem: item #8 do backlog (`docs/backlog-handoff-2026-07-19.md`), achado durante o smoke test manual do PR #21, mais escopo adicional pedido pelo usuário nesta sessão (link clicável + passo-a-passo mais claro para leigos).
- Chaves novas do Google AI Studio hoje começam com `AQ`, não `AIza` (confirmado pelo usuário) — texto de exemplo e `hintText` devem refletir isso.
- Limite de rate do tier grátis documentado em `CLAUDE.md`: `≤15 RPM / ~1 500 RPD`. O texto atual do onboarding diz "1.000/dia" — deve ser corrigido para "1.500/dia".
- O código **não valida** o formato da chave (sem `startsWith`/regex) — isso continua fora de escopo; só o texto de exemplo muda.
- Nenhuma nova tela, nenhuma mudança de fluxo dos outros 3 passos do onboarding (dados físicos, composição corporal, meta) — escopo restrito ao `_StepConfig` (passo 4).
- Link deve abrir no navegador externo do dispositivo (`LaunchMode.externalApplication`), não em WebView interno.

---

## File Structure

- **Modify** `pubspec.yaml` — adiciona dependência `url_launcher`.
- **Modify** `android/app/src/main/AndroidManifest.xml` — adiciona entrada de `<queries>` para resolução de intents `https` (necessário no Android 11+ para `canLaunchUrl`/`launchUrl` funcionarem de forma confiável).
- **Modify** `lib/features/onboarding/screens/onboarding_screen.dart` — link clicável no passo 1, textos corrigidos (chave/rate limit), passo 1 reescrito com reforço de clareza.
- **Test** `test/widget/onboarding_screen_test.dart` (arquivo já existe — adiciona novos casos).

---

### Task 1: Link clicável para o Google AI Studio

**Files:**
- Modify: `pubspec.yaml`
- Modify: `android/app/src/main/AndroidManifest.xml`
- Modify: `lib/features/onboarding/screens/onboarding_screen.dart`
- Test: `test/widget/onboarding_screen_test.dart`

**Interfaces:**
- Produces: `Future<void> _openAiStudioLink()` (top-level, privado ao arquivo `onboarding_screen.dart`) — usa `package:url_launcher/url_launcher.dart`. `_Step` ganha os parâmetros opcionais `linkLabel`/`onLinkTap` e a `Key` fixa `onboarding-aistudio-link` no link renderizado (usada pelo teste).

- [ ] **Step 1: Adicionar a dependência `url_launcher`**

Run: `flutter pub add url_launcher`
Expected: `pubspec.yaml` ganha uma linha `url_launcher: ^<versão resolvida>` em `dependencies:`, e `flutter pub get` roda automaticamente sem erro.

Run: `flutter pub add --dev url_launcher_platform_interface`
Expected: `pubspec.yaml` ganha `url_launcher_platform_interface: ^<versão resolvida>` em `dev_dependencies:` (necessário para o teste no Step 2 substituir a plataforma por um fake).

- [ ] **Step 2: Escrever o teste que falha**

No topo de `test/widget/onboarding_screen_test.dart`, adicionar os imports:

```dart
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
```

Adicionar, antes de `void main() {`, a classe fake:

```dart
class _FakeUrlLauncher extends UrlLauncherPlatform {
  String? launchedUrl;

  @override
  Future<bool> canLaunch(String url) async => true;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launchedUrl = url;
    return true;
  }
}
```

Dentro de `void main() { ... }`, adicionar um novo `testWidgets` (após o teste já existente):

```dart
  testWidgets(
    'tapping the AI Studio link on step 4 opens the URL externally',
    (tester) async {
      final fakeLauncher = _FakeUrlLauncher();
      UrlLauncherPlatform.instance = fakeLauncher;

      await pumpOnboarding(tester);

      // Advance to step 3 (index), the API key / config step.
      await tester.enterText(
        find.byKey(const Key('onboarding-weight-field')),
        '80',
      );
      await tester.enterText(
        find.byKey(const Key('onboarding-height-field')),
        '178',
      );
      await tester.enterText(
        find.byKey(const Key('onboarding-age-field')),
        '30',
      );
      await tester.pump();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('onboarding-aistudio-link')));
      await tester.pumpAndSettle();

      expect(fakeLauncher.launchedUrl, 'https://aistudio.google.com');
    },
  );
```

- [ ] **Step 3: Rodar o teste e confirmar que falha**

Run: `flutter test test/widget/onboarding_screen_test.dart`
Expected: FAIL — `Bad state: No element` ou `finds 0 widgets` ao procurar `Key('onboarding-aistudio-link')` (ainda não existe na UI).

- [ ] **Step 4: Adicionar a entrada de `<queries>` no manifest**

Em `android/app/src/main/AndroidManifest.xml`, dentro do bloco `<queries>` já existente (que hoje só tem a entrada de `PROCESS_TEXT`), adicionar:

```xml
    <queries>
        <intent>
            <action android:name="android.intent.action.PROCESS_TEXT"/>
            <data android:mimeType="text/plain"/>
        </intent>
        <intent>
            <action android:name="android.intent.action.VIEW"/>
            <data android:scheme="https"/>
        </intent>
    </queries>
```

- [ ] **Step 5: Implementar o link no onboarding**

Em `lib/features/onboarding/screens/onboarding_screen.dart`, adicionar o import (após a linha 3):

```dart
import 'package:url_launcher/url_launcher.dart';
```

Adicionar a função top-level, logo antes de `class OnboardingScreen` (linha 12):

```dart
Future<void> _openAiStudioLink() async {
  await launchUrl(
    Uri.parse('https://aistudio.google.com'),
    mode: LaunchMode.externalApplication,
  );
}

```

Modificar a classe `_Step` (linhas 578-621) para aceitar um link opcional:

```dart
class _Step extends StatelessWidget {
  const _Step({
    required this.number,
    required this.primary,
    required this.text,
    this.linkLabel,
    this.onLinkTap,
  });
  final String number;
  final Color primary;
  final String text;
  final String? linkLabel;
  final Future<void> Function()? onLinkTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(right: 12, top: 1),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: Theme.of(context).textTheme.bodyMedium),
                if (linkLabel != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: InkWell(
                      key: const Key('onboarding-aistudio-link'),
                      onTap: onLinkTap,
                      child: Text(
                        linkLabel!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: primary,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

Modificar a chamada do passo 1 dentro de `_StepConfig.build()` (linhas 514-519) para:

```dart
                _Step(
                  number: '1',
                  primary: primary,
                  text:
                      'Toque no link abaixo para abrir o Google AI Studio no navegador e faça login com sua conta Google (é gratuito e leva menos de 2 minutos).',
                  linkLabel: 'aistudio.google.com',
                  onLinkTap: _openAiStudioLink,
                ),
```

- [ ] **Step 6: Rodar o teste e confirmar que passa**

Run: `flutter test test/widget/onboarding_screen_test.dart`
Expected: PASS (2 testes: o já existente + o novo do link)

- [ ] **Step 7: Rodar analyze**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 8: Commit**

```bash
git add pubspec.yaml pubspec.lock android/app/src/main/AndroidManifest.xml lib/features/onboarding/screens/onboarding_screen.dart test/widget/onboarding_screen_test.dart
git commit -m "feat: make the AI Studio step in onboarding a tappable link"
```

---

### Task 2: Corrigir formato de chave, limite de taxa e clareza do passo-a-passo

**Files:**
- Modify: `lib/features/onboarding/screens/onboarding_screen.dart:507-547` (bloco "Como obter sua chave gratuita" em `_StepConfig`)
- Modify: `lib/features/onboarding/screens/onboarding_screen.dart:558` (`hintText` do campo de chave)
- Test: `test/widget/onboarding_screen_test.dart`

**Interfaces:**
- Nenhuma nova interface pública — apenas texto estático dentro de `_StepConfig`.

- [ ] **Step 1: Escrever o teste que falha**

Adicionar a `test/widget/onboarding_screen_test.dart` (após o teste do Task 1):

```dart
  testWidgets(
    'step 4 shows the current API-key format and rate limits, not the stale ones',
    (tester) async {
      await pumpOnboarding(tester);

      await tester.enterText(
        find.byKey(const Key('onboarding-weight-field')),
        '80',
      );
      await tester.enterText(
        find.byKey(const Key('onboarding-height-field')),
        '178',
      );
      await tester.enterText(
        find.byKey(const Key('onboarding-age-field')),
        '30',
      );
      await tester.pump();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Stale copy must be gone.
      expect(find.textContaining('AIza'), findsNothing);
      expect(find.textContaining('1.000/dia'), findsNothing);

      // Current copy must be present.
      expect(find.textContaining('AQ'), findsWidgets);
      expect(find.textContaining('1.500/dia'), findsOneWidget);
      expect(find.textContaining('gratuito'), findsWidgets);
    },
  );
```

- [ ] **Step 2: Rodar o teste e confirmar que falha**

Run: `flutter test test/widget/onboarding_screen_test.dart`
Expected: FAIL — `find.textContaining('AIza')` encontra 1 widget (`hintText: 'AIza...'` e o texto do passo 4 ainda mencionam "AIza"); `find.textContaining('1.500/dia')` encontra 0 widgets.

- [ ] **Step 3: Corrigir os textos**

Em `lib/features/onboarding/screens/onboarding_screen.dart`, substituir o bloco inteiro de `_Step`s + texto de rate limit (linhas 520-544, ou seja, os passos 2/3/4 e a linha de limite — o passo 1 já foi reescrito na Task 1):

```dart
                _Step(
                  number: '2',
                  primary: primary,
                  text:
                      'No menu à esquerda, clique em "Get API key". Em seguida, clique em "Create API key".',
                ),
                _Step(
                  number: '3',
                  primary: primary,
                  text:
                      'Selecione "Create API key in new project" (ou escolha um projeto existente, se já tiver um). Clique em "Create".',
                ),
                _Step(
                  number: '4',
                  primary: primary,
                  text:
                      'Copie a chave gerada — hoje ela começa com "AQ" (chaves mais antigas podem começar com "AIza", e ambas funcionam). Cole no campo abaixo.',
                ),
                const SizedBox(height: 6),
                Text(
                  'A chave gratuita tem limite de 15 requisições/minuto e 1.500/dia — suficiente para uso pessoal normal.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: textSub),
                ),
```

Substituir o `hintText` do `TextField` (linha 558):

```dart
              hintText: 'AQ...',
```

- [ ] **Step 4: Rodar o teste e confirmar que passa**

Run: `flutter test test/widget/onboarding_screen_test.dart`
Expected: PASS (3 testes)

- [ ] **Step 5: Rodar analyze + suíte completa**

Run: `flutter analyze && flutter test`
Expected: `No issues found!`, todos os testes passando.

- [ ] **Step 6: Commit**

```bash
git add lib/features/onboarding/screens/onboarding_screen.dart test/widget/onboarding_screen_test.dart
git commit -m "fix: update onboarding API-key format and rate-limit copy"
```

---

## Self-Review

**1. Cobertura do pedido:**
- Formato da chave desatualizado ("AIza" → "AQ") → Task 2.
- Rate limits desatualizados (1.000/dia → 1.500/dia, batendo com `CLAUDE.md`) → Task 2.
- Link clicável para o AI Studio → Task 1.
- Passo-a-passo mais claro para leigos (reforço de "gratuito"/"leva menos de 2 minutos", números de projeto opcional detalhado no passo 3) → Tasks 1 e 2.

**2. Placeholder scan:** nenhum "TBD"/texto genérico — todas as strings finais estão escritas por extenso em cada step.

**3. Consistência:** `_openAiStudioLink` (Task 1) é a mesma função referenciada em `onLinkTap` no passo 1 (Task 1) e não é tocada pela Task 2. `linkLabel`/`onLinkTap` de `_Step` (Task 1) não conflitam com os `_Step`s sem link dos passos 2-4 (Task 2), já que ambos os parâmetros são opcionais.

## Execution Handoff

Duas opções de execução:

1. **Subagent-Driven (recomendado)** — um subagente por task, revisão entre tasks, iteração rápida.
2. **Inline Execution** — execução em lote nesta sessão via `executing-plans`, com checkpoints de revisão.
