# Design: correção de dois bugs de confiabilidade (confirmação de refeição e onboarding)

**Data:** 2026-07-19
**Status:** aprovado, aguardando plano de implementação
**Escopo:** itens #5 e #6 do backlog GEMA (bugs), tratados juntos por serem pequenos e não relacionados entre si além de ambos serem "quick wins" de confiabilidade.

## Contexto

Levantamento de backlog identificou 8 itens heterogêneos. Este spec cobre apenas os dois bugs de baixo esforço/alto impacto de confiança escolhidos para o primeiro ciclo. Os demais itens (migração de modelo Gemini, acurácia de KCAL via RAG, UX de câmera, flash, nutrientes, Wear OS) ficam para specs futuros e independentes.

## Bug #5 — Refeição inserida mesmo sem confirmação do usuário

### Problema

`CaptureScreen._saveMealFromPath` (`lib/features/meals/screens/capture_screen.dart:137-152`) persiste o `Meal` no Isar via `createMeal` no instante da captura/seleção da foto — antes de qualquer confirmação. Em `ConfirmMealScreen` (`lib/features/meals/screens/confirm_meal_screen.dart`), tanto o botão **X** (linhas 193-196) quanto o botão **Salvar refeição** (linha 481, chamando `_save` na linha 147-149) executam a mesma ação: `context.go('/home')`. Não existe nenhum caminho que descarte o registro — sair da tela por qualquer meio deixa a refeição gravada, mesmo que o usuário nunca tenha confirmado o resultado da IA.

### Comportamento esperado (decidido com o usuário)

1. Tocar em **X** exclui permanentemente o registro `Meal` do Isar e o arquivo de foto associado em disco.
2. O gesto de voltar do Android (hardware back / swipe) tem exatamente o mesmo efeito do X — intercepta via `PopScope`, não apenas navega para trás.
3. Se a análise do Gemini ainda estiver em andamento (`_analyzing == true`) quando o usuário descarta, a requisição HTTP **não** é cancelada (evita complexidade de cancelamento e não desperdiça controle de rate-limit). Quando a resposta chegar, o código que aplica o resultado (`applyGeminiResult`) verifica se o `Meal` ainda existe no Isar antes de escrever; se não existir, a resposta é descartada silenciosamente.
4. Nenhum novo estado é adicionado ao pipeline `provisional → queued → processing → done | error` (ver CLAUDE.md) — o descarte é uma exclusão física do registro, não um novo status.

### Design técnico

- Adicionar `discardMeal(int mealId)` ao `MealQueueNotifier` (`lib/features/meals/providers/meal_provider.dart`):
  - Lê o `Meal` do Isar; se tiver `photoPath`, deleta o arquivo (`File(photoPath).delete()`, ignorando erro se já não existir).
  - Deleta o registro do Isar (`isar.meals.delete(mealId)`).
- `ConfirmMealScreen`:
  - Botão X: `onPressed` passa a ser `async` — chama `await ref.read(mealQueueNotifierProvider.notifier).discardMeal(widget.mealId)` e então `context.go('/home')`.
  - Envolver o `Scaffold` (ou o `body`) em `PopScope(canPop: false, onPopInvokedWithResult: (didPop, result) async { if (!didPop) { await discard...; if (mounted) context.go('/home'); } })`, reaproveitando o mesmo método usado pelo X.
- `MealQueueNotifier.applyGeminiResult`:
  - No início do método, buscar o `Meal` atual por id; se `null` (foi descartado), retornar sem gravar nada.

### Testes

- Widget test: tocar no botão X remove o `Meal` correspondente do Isar (banco em memória de teste).
- Widget test: disparar o `PopScope` (simulando back) tem o mesmo efeito.
- Unit/widget test: chamar `applyGeminiResult` para um `mealId` que não existe mais no Isar não lança exceção e não recria o registro.

## Bug #6 — Colar a chave de API não habilita o botão "Continuar"

### Problema

Nenhum dos 5 `TextEditingController` do onboarding (`_weightCtrl`, `_heightCtrl`, `_ageCtrl`, `_deficitCtrl`, `_apiKeyCtrl` em `lib/features/onboarding/screens/onboarding_screen.dart`) tem um listener chamando `setState`. O botão "Continuar"/"Começar" (linha 196-206) só reavalia `_canAdvance()` (linhas 69-83) quando o widget é reconstruído por outro motivo (mudança de foco, teclado aparecendo/sumindo). Isso faz parecer que digitar funciona (o rebuild incidental do teclado mascara o problema) enquanto colar — que não necessariamente dispara esses eventos — deixa o botão preso em `disabled`. O mesmo problema de raiz existe em todas as 4 etapas do onboarding, não só na etapa da API key.

### Comportamento esperado (decidido com o usuário)

Corrigir a reatividade em todas as etapas do onboarding de uma vez, com um único padrão — não só no campo de API key.

### Design técnico

- Escopar a reatividade ao botão, não à tela inteira, para evitar rebuilds desnecessários de toda a `PageView` a cada tecla digitada.
- Envolver o botão inferior (`lib/features/onboarding/screens/onboarding_screen.dart:192-207`) em um `ListenableBuilder` (ou `AnimatedBuilder`) com `listenable: Listenable.merge([_weightCtrl, _heightCtrl, _ageCtrl, _deficitCtrl, _apiKeyCtrl])`.
- `_canAdvance()` permanece com a mesma lógica; passa a ser chamada dentro do `builder` do `ListenableBuilder`, portanto reavaliada em qualquer mudança de texto — digitação, paste, autofill ou ditado por voz — em qualquer um dos 5 controllers.
- Não é necessário registrar/remover listeners manualmente em `initState`/`dispose`; `ListenableBuilder` cuida disso internamente.

### Testes

- Widget test por etapa (4 etapas): setar `controller.text = '...'` diretamente via código (equivalente a um paste — não passa por eventos de teclado) e verificar que o botão "Continuar"/"Começar" fica habilitado.
- Regressão: garantir que o botão continua desabilitado quando os campos obrigatórios da etapa estão vazios.

## Fora de escopo

- Qualquer mudança nos outros 6 itens do backlog (migração de modelo, acurácia de KCAL, UX de câmera, flash, nutrientes, Wear OS) — cada um recebe seu próprio ciclo de brainstorm → spec → plano.
- Validação de formato da API key (ex: prefixo `AIza`) — não fazia parte do bug relatado.
