# Design: duplicar refeição recorrente a partir do Quick Add

**Data:** 2026-07-21
**Status:** aprovado, aguardando plano de implementação
**Escopo:** item #7 (novo) do backlog GEMA (`docs/backlog-handoff-2026-07-19.md`) — QoL para refeições repetidas (ex.: mesmo café da manhã todo dia), evitando redigitar/redescrever a mesma refeição.

## Contexto

Hoje toda refeição — mesmo uma idêntica a uma já logada dias antes — precisa passar pelo fluxo normal de captura (foto/galeria/quick add) e, se envolver estimativa por IA, pelo pipeline completo `provisional → queued → processing → done`. Para refeições rotineiras (o exemplo motivador é um café da manhã que se repete quase todo dia), isso é atrito puro: o usuário já sabe o resultado esperado, mas paga o custo total de descrição + espera + cota de rate-limit do Gemini de novo.

O schema atual (`lib/features/meals/models/meal.dart`) já guarda tudo que uma duplicação precisa: `Meal` tem `capturedAt`, `userNote`, `source`, `status`, os campos min/max/point de kcal/carb/protein/fat, `aiConfidence`, `aiEmoji`, e a lista de `MealComponent` via `IsarLinks`. `MealQueueNotifier` (`lib/features/meals/providers/meal_provider.dart`) já expõe o padrão de criação (`createMeal`) e de remoção com limpeza de foto (`deleteMeal`), que servem de referência direta para a nova operação.

## Design

### 1. Sugestão de refeições recorrentes

Novo provider (`lib/features/meals/providers/`, ex. `recurringMealSuggestionsProvider`), consumido pela tela de Quick Add:

- Consulta `Meal` com `status == done`, `capturedAt` dentro dos últimos 14 dias, filtrando por uma janela de ±90 minutos em torno do horário atual (usando o índice existente em `capturedAt`).
- Normaliza o texto de cada candidata: usa `userNote` se não vazio, senão concatena os nomes dos `MealComponent` vinculados.
- Agrupa candidatas por similaridade fuzzy de texto (Jaccard sobre tokens normalizados — minúsculas, sem acento/pontuação, split por espaço; interseção/união ≥ 0.6 = mesmo grupo), pura Dart, sem dependência nova.
- De cada grupo, mantém só a ocorrência mais recente (por `capturedAt`).
- Retorna até 3 candidatas, ordenadas por recência.

### 2. Operação de duplicar

Novo método em `MealQueueNotifier`: `duplicateMeal(Meal original)`.

- Cria um novo `Meal` copiando: `userNote`, os campos min/max/point de kcal/carb/protein/fat, `aiConfidence`, `aiEmoji`.
- Define para o novo registro: `capturedAt = createdAt = updatedAt = now`, `status = MealStatus.done` (não passa pelo pipeline de IA — os valores já são conhecidos), `source = MealSource.quickAdd`, `retryCount = 0`, `userEditedKcal = false`.
- **Não copia** `photoPath`/`photoDeletedAt` — duas refeições apontando pro mesmo arquivo quebraria a contabilidade do job de limpeza semanal de fotos (`lib/core/background/background_tasks.dart`, `_taskPhotoCleanup`), que assume relação 1:1 entre foto e refeição.
- Copia os `MealComponent` vinculados ao original (`name`, `normalizedTag`, `kcalPoint`, `grupoAlimentar`, `metodoPreparo`, `estimatedMassG`) como novos registros linkados ao novo `Meal` — nunca reaproveita o mesmo `MealComponent` em duas refeições.
- Toda a criação roda em uma única `isar.writeTxn`, espelhando o padrão de `createMeal`/`deleteMeal` já existente.

### 3. UI no Quick Add

- Seção compacta ("Refeições recentes parecidas") no topo da tela de Quick Add, com até 3 cards/chips vindos do provider da seção 1. Cada card mostra `aiEmoji` (se houver), o texto normalizado e o horário original.
- Vazio (sem candidatas na janela) → seção não aparece; não há estado vazio dedicado.
- Tocar num card chama `duplicateMeal` diretamente — sem tela de confirmação intermediária — e mostra um `SnackBar`: "Refeição duplicada · Desfazer".
- Ação "Desfazer" do snackbar chama a lógica já existente de `deleteMeal` (que já cuida de remover `MealComponent`s e arquivo de foto, este último não aplicável aqui pois a duplicata nunca tem foto) passando o id do `Meal` recém-criado.
- Fora do escopo desta versão: editar valores antes de duplicar, marcar refeições como favoritas, e qualquer sugestão fora da tela de Quick Add.

### 4. Testes

- **Unit (`test/unit/`):** função de normalização + agrupamento fuzzy — casos: notas idênticas, pequena variação de digitação (mesmo grupo), refeições em horários fora da janela (não aparecem), refeições com `userNote` vazio caindo no fallback de nomes de componentes.
- **Unit/provider:** `duplicateMeal` — cobre cópia correta de `MealComponent`s, campos zerados/resetados (`retryCount`, `userEditedKcal`), e que `photoPath` do novo registro é sempre `null` mesmo quando o original tinha foto.
- **Widget (`test/widget/`):** seção de sugestões no Quick Add renderiza 0–3 cards conforme o provider mockado; toque aciona `duplicateMeal` e exibe o snackbar de desfazer.

## Riscos e limitações conhecidas

- Grouping fuzzy roda em memória a cada abertura do Quick Add sobre um conjunto pequeno (refeições de 14 dias) — sem necessidade de otimização agora; se o volume de refeições por usuário crescer muito (não é o caso do app de usuário único atual), reavaliar com um fingerprint pré-computado no `Meal`.
- Duplicar sempre marca a nova refeição como `done` com os valores herdados — se a porção real da refeição repetida for visivelmente diferente da original, o usuário precisa editar manualmente depois (via edição de `kcal_point`, já existente); não há re-estimativa automática por IA neste fluxo.
- O limiar de similaridade (0.6) e a janela de horário (±90 min) são heurísticas iniciais — ajustar durante a implementação/plano se os testes com dados reais do usuário mostrarem falso-positivos/negativos.

## Referências

- `docs/backlog-handoff-2026-07-19.md` — documento de origem do backlog.
- `lib/features/meals/models/meal.dart`, `lib/features/meals/providers/meal_provider.dart`, `lib/core/background/background_tasks.dart` — pontos de integração já existentes usados como referência de padrão.
