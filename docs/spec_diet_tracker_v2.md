# Especificação Técnica — Personal Diet Tracker (Offline-First)

> Documento de arquitetura + planejamento de produto. Stack recomendada, modelo de dados local,
> algoritmos estatísticos, wireframes e contrato da IA.
>
> **v2 — correções aplicadas:** numeração de seções, schema de dados (goals, daily_summary, tabelas
> faltantes), ciclo de vida de fotos, fórmula de transição do bootstrap, máquina de estados
> provisional→IA, seção de onboarding, limitação de edição de macros, exportação de dados,
> tratamento de Retry-After.

---

## 0. Decisões de arquitetura (resumo executivo)

| Camada | Escolha recomendada | Por quê |
|---|---|---|
| Mobile | **Flutter** | Câmera nativa madura (`camera`), background tasks (`workmanager`), e o ecossistema de banco local reativo (Isar) encaixa melhor no Analytics que recalcula sozinho. RN/Expo funciona, mas background processing real fora do Expo Go é mais chato. |
| Banco local | **Isar** | Reativo (queries que emitem `Stream` → a aba Analytics atualiza sem boilerplate), rápido, schema tipado em Dart. **Alternativa:** Drift (SQLite) se você preferir escrever as agregações em SQL — mas note que SQLite puro não tem `STDEV`/`MEDIAN` nativos. |
| IA | Gemini API (free tier) chamado **direto do device** | Use **structured output** (`responseMimeType: application/json` + `responseSchema`) para garantir JSON válido sem precisar limpar ` ```json ` na mão. |
| Chave da API | **`flutter_secure_storage`** (Keychain no iOS / Keystore no Android) | ⚠️ **Não** guarde a API key em SQLite/Isar. Banco local não é criptografado por padrão e vaza em backup. Secure storage usa o enclave do SO. A chave é **fornecida pelo próprio usuário** no onboarding (§5) — nunca embutida no bundle. |
| Fila offline | Tabela `meals` com campo `status` + `workmanager` | Padrão *outbox*: o próprio registro da refeição é o item da fila. Não precisa de tabela separada. |

> **Nada disto está em pedra.** As escolhas acima otimizam velocidade de implementação + qualidade,
> mas são substituíveis. Trocas razoáveis: **Expo + expo-camera + expo-sqlite/op-sqlite** se você
> preferir o ecossistema RN/TS; **React Native puro** se quiser background mais livre que o Expo Go;
> **Drift** no lugar de Isar se a estatística em SQL te agradar mais. O resto da spec (modelo de
> dados, algoritmos, contrato da IA) é agnóstico de stack.

---

## 1. Arquitetura de Dados (modelo local)

Oito coleções. Apresento como pseudo-SQL pela clareza; em Isar viram `@collection class`.

---

### `meals` — refeições

```sql
id               INTEGER PK
captured_at      DATETIME            -- quando o usuário tirou a foto / criou a entrada
photo_path       TEXT NULL           -- caminho local do arquivo (NULL se barcode/manual/quick_add)
photo_deleted_at DATETIME NULL       -- timestamp da deleção da foto local (ver §1.1)
user_note        TEXT                -- input texto/voz ("whey com leite desnatado")
source           TEXT                -- 'ai_photo' | 'barcode' | 'quick_add' | 'manual'
status           TEXT                -- 'provisional' | 'queued' | 'processing' | 'done' | 'error'
-- Estimativas em INTERVALO (a IA sempre devolve min/max/point)
kcal_min         INTEGER
kcal_max         INTEGER
kcal_point       INTEGER             -- ponto central, usado nas somas/estatísticas
carb_min/max/point       INTEGER
protein_min/max/point    INTEGER
fat_min/max/point        INTEGER
ai_confidence    TEXT                -- 'high' | 'medium' | 'low' | NULL (não-IA)
ai_raw_json      TEXT NULL           -- resposta crua do Gemini (auditoria/reprocesso)
retry_count      INTEGER DEFAULT 0
created_at / updated_at
```

> **Regra de total vs. componentes:** `meals.kcal_point` é a fonte de verdade para todas as somas
> diárias e estatísticas. Os campos `meal_components.kcal_point` são **informativos** (usados apenas
> na Análise de Frequência e no histórico de itens), nunca somados para recalcular o total do prato —
> a estimativa holística da IA para o prato completo é mais confiável do que a soma dos componentes
> individualmente.

---

### `meal_components` — itens normalizados (chave para Frequência)

```sql
id              INTEGER PK
meal_id         INTEGER FK -> meals.id
name            TEXT                -- "arroz branco cozido"
normalized_tag  TEXT                -- "arroz" (slug normalizado p/ agrupar)
kcal_point      INTEGER             -- informativo; NÃO somar para total do prato (ver nota acima)
grupo_alimentar TEXT                -- enum controlado (ver §4.2)
metodo_preparo  TEXT                -- enum controlado (ver §4.2)
estimated_mass_g INTEGER NULL
```

> A **normalização** (`normalized_tag`) é o que torna a Análise de Frequência confiável: "arroz",
> "Arroz", "arroz branco" precisam colapsar num só bucket. Faça isso no app (lowercase + remoção de
> acento + um pequeno dicionário de sinônimos), não confie só na string da LLM.

---

### `weight_history` — histórico de peso/composição

```sql
id              INTEGER PK
measured_on     DATE                -- registro esporádico, NÃO diário
weight_kg       REAL
body_fat_pct    REAL NULL           -- opcional
note            TEXT NULL
```

---

### `goals` — metas (versionadas por data de vigência)

```sql
id                    INTEGER PK
effective_from        DATE          -- nova linha sempre que recalcular
goal_type             TEXT          -- 'cut' | 'maintain' | 'bulk'
target_weight         REAL NULL
target_date           DATE NULL
prior_activity_factor REAL NULL     -- ⚠️ usado APENAS durante bootstrap (dias 0–14, ver §2.3)
                                    -- NULL após calibração empírica do TDEE; NÃO é fator permanente
bmr                   REAL          -- TMB calculada (Katch-McArdle ou Mifflin) — só prior
tdee                  REAL          -- gasto total: prior nos dias 0–14, empírico depois
kcal_target           INTEGER
protein_target_g / carb_target_g / fat_target_g  INTEGER
```

> Versione por `effective_from` (não faça `UPDATE` destrutivo). Assim o gráfico de progresso mostra
> honestamente *quando* a meta mudou, e o cálculo de "déficit acumulado" usa a meta vigente em cada
> dia.
>
> **Sobre `prior_activity_factor`:** o TDEE dinâmico (§2.3) abandona o multiplicador fixo assim que
> há dados suficientes (~14 dias). O campo é `NULL`ável justamente para sinalizar que, após a
> calibração, ele deixou de ter função — o `tdee` passa a refletir o balanço empírico, não a fórmula.

---

### `daily_summary` — materializada de forma híbrida (ver §1.2)

```sql
day             DATE PK
total_kcal      INTEGER
total_protein/carb/fat  INTEGER
total_water_ml  INTEGER             -- total de água do dia (de water_log)
kcal_target     INTEGER             -- snapshot da meta daquele dia
deficit         INTEGER             -- target - consumido
meals_logged    INTEGER
xp_earned       INTEGER             -- XP acumulado no dia (eventos de §2.7)
is_cheat        BOOLEAN DEFAULT 0   -- flag de cheat day/meal
```

---

### `xp_log` — eventos de XP (base para níveis de §2.7)

```sql
id              INTEGER PK
day             DATE                -- FK -> daily_summary.day
event_type      TEXT                -- 'all_meals_logged' | 'protein_goal' | 'weight_logged'
                                    --   | 'cheat_planned' | 'water_goal'
xp_amount       INTEGER
created_at      DATETIME
```

> `xp_total` e `nivel` são **derivados** (soma de `xp_log.xp_amount`); não guardar como campos
> persistentes — recalcular sob demanda para evitar dessincronização.

---

### `products` — cache de produtos escaneados (barcode)

```sql
barcode         TEXT PK             -- EAN / UPC
name            TEXT
brand           TEXT NULL
kcal_100g       REAL
protein_100g    REAL
carb_100g       REAL
fat_100g        REAL
last_scanned_at DATETIME
```

> Alimenta tanto o scanner (§8) quanto a busca do Quick Add. No primeiro scan requer rede (Open Food
> Facts); após o cache, funciona 100% offline.

---

### `water_log` — registro de água

```sql
id              INTEGER PK
day             DATE
ml              INTEGER
logged_at       DATETIME
```

---

### 1.1 Política de ciclo de vida das fotos

O acúmulo de fotos sem gestão é um dos maiores drenos de armazenamento em trackers de refeições
(3–4 fotos/dia × semanas = centenas de MBs). Política recomendada:

**Formato salvo:** armazene sempre a versão já comprimida (≤800 px, JPEG ~65%) — é suficiente
para reprocessamento e custa ~50–100 KB por foto em vez de 3–5 MB.

**Ciclo de vida por status:**

| Status final | Política da foto |
|---|---|
| `done` (sucesso) | Manter 7 dias após processamento, depois deletar automaticamente. Atualizar `photo_deleted_at`. |
| `error` (após N tentativas) | Manter indefinidamente até resolução manual pelo usuário. |
| `provisional` sem foto | `photo_path = NULL`; nada a gerenciar. |

**Configurações expostas ao usuário:**
- "Limpar fotos já processadas" — ação manual nas configurações (libera espaço imediatamente).
- Indicador de uso de armazenamento estimado (KB por refeição × contagem).

---

### 1.2 Estratégia de materialização do `daily_summary`

Usar abordagem **híbrida** em vez de escolher entre view pura ou batch noturno:

**Dia atual** → query reativa sobre `meals` (Isar `Stream`) em tempo real. O `daily_summary` de
hoje nunca é materializado até a virada de meia-noite — o app lê direto, sem latência de batch.

**Dias anteriores** → materializar via `workmanager` job diário (dispara à meia-noite no fuso
local). Dias passados não mudam no fluxo normal, então o batch noturno é suficiente.

**Edição retroativa** → se o usuário editar ou deletar uma refeição de dia anterior, recalcular o
`daily_summary` daquele dia imediatamente (Isar watcher no registro `meals` editado → trigger de
recálculo síncrono do summary afetado).

---

## 2. Algoritmos Matemáticos

### 2.1 Suavização do peso — EMA *time-aware*

O problema: peso é registrado **de forma irregular** (esporádico). Uma EMA discreta padrão
(`S_t = α·yₜ + (1−α)·S_{t−1}`) assume passo fixo e distorce quando você pula 5 dias. Use a versão
de **tempo contínuo**, que pondera pelo intervalo real Δt (em dias):

```
α_eff = 1 − exp(−Δt / τ)
S_novo = S_anterior + α_eff · (y_observado − S_anterior)
```

- `τ` = constante de tempo em dias. **τ ≈ 7–10** dá a suavização de ~1 semana que você quer
  (filtra glicogênio/retenção). τ menor = mais reativo, maior = mais liso.
- Δt = dias desde a última medição. Quanto maior o intervalo, mais a nova leitura "puxa" a média —
  que é exatamente o comportamento correto.
- Aplique a **mesma fórmula** ao `body_fat_pct`.

Isso é matematicamente o filtro exponencial de John Walker (*The Hacker's Diet*), generalizado para
amostragem irregular. A meta calórica (§2.3) só reage a `S` (peso suavizado), nunca ao valor cru
do dia.

---

### 2.2 Projeção da data-meta — regressão sobre o peso suavizado

A forma estatisticamente honesta de responder "quando vou atingir o peso-alvo" é uma **OLS do peso
suavizado contra o tempo**, numa janela móvel recente (sugiro `W = 21–28 dias`), com intervalo de
confiança.

Sobre os pontos `(tᵢ, Sᵢ)` da janela:

```
β1 (kg/dia) = Σ(tᵢ − t̄)(Sᵢ − S̄) / Σ(tᵢ − t̄)²
β0          = S̄ − β1·t̄
SSE         = Σ(Sᵢ − (β0 + β1·tᵢ))²
σ²          = SSE / (n − 2)
SE(β1)      = sqrt( σ² / Σ(tᵢ − t̄)² )
```

Projeção (dias até a meta a partir de hoje):

```
dias_restantes = (peso_alvo − S_atual) / β1
```

**Banda de incerteza** (o que dá credibilidade ao card): use o IC do slope para gerar cenário
otimista/pessimista:

```
β1_lo, β1_hi   = β1 ∓ t(n−2, 0.975) · SE(β1)
data_otimista  = hoje + (alvo − S_atual) / β1_rápido
data_pessimista= hoje + (alvo − S_atual) / β1_lento
```

Mostre **uma faixa de datas**, não uma data falsamente precisa. Se o IC do slope cruza zero
(tendência não significativa) ou o sinal do slope é contrário à meta, **não projete** — mostre
"tendência ainda inconclusiva".

#### ⚠️ Sobre a "regressão múltipla" do prompt

Déficit acumulado ≈ déficit_médio × t, ou seja é quase **colinear** com o tempo — jogar os dois
crus numa OLS dá coeficientes instáveis/sem sentido. Duas saídas melhores:

1. **Cross-check físico independente** (não regressão): `taxa_kg_dia ≈ déficit_médio_diário / 7700`.
   (≈7700 kcal/kg de gordura é a aproximação clássica; o valor real varia ~7000–9400 conforme o
   tecido — exiba como estimativa, não verdade.) Reconcilie as duas estimativas: se a regressão
   empírica diverge muito do previsto pelo balanço energético, isso *é* o insight (adesão
   imperfeita, adaptação metabólica, sub-registro).

2. **Multivariada de verdade, se quiser:** modele em painel semanal a
   `taxa_de_perda ~ déficit_médio_semanal (+ atividade, se tiver)`. Aí o "déficit" entra como
   driver real, não como soma cumulativa redundante. Ou modele a razão de adesão
   `perda_observada / perda_prevista_pelo_déficit` ao longo do tempo — ótimo para detectar platô
   metabólico.

---

### 2.3 Meta calórica — TDEE Dinâmico (adaptativo), com fórmula só como prior

O multiplicador de atividade fixo (1.2–1.9) é o elo fraco — o NEAT varia demais dia a dia pra um
único fator fazer sentido. O estado da arte (estilo MacroFactor) **abandona o multiplicador
estático** e estima a manutenção a partir do **balanço energético real observado**.

**Estimador de manutenção (TDEE dinâmico)** — sobre uma janela móvel de `W` dias:

```
C̄       = consumo médio diário registrado na janela (usa kcal_point)
ΔS      = S_fim − S_início    (variação do PESO SUAVIZADO, §2.1)
TDEE_est = C̄ − (ΔS · k) / W
  k ≈ 7700 kcal/kg  (densidade energética da variação de massa)
```

O sinal se resolve sozinho: se o peso suavizado caiu (`ΔS<0`) consumindo `C̄`, então a manutenção
estava *acima* do consumo — o termo `−(ΔS·k)/W` soma de volta o déficit médio.

A meta vira:

```
kcal_target = TDEE_est − déficit_desejado
```

onde `déficit_desejado` é **parâmetro escolhido pelo usuário** (kcal/dia, ou %/semana de peso
convertido). O app não impõe um valor.

**Bootstrap / handoff — transição explícita:**

O ponto mais sensível a bugs é a transição do prior fórmula → TDEE empírico. A abordagem
recomendada é uma **ponderação por confiança**:

```
w_empirico = clamp( (n_dias_com_dado − 7) / 14, 0.0, 1.0 )
  -- 0.0 nos primeiros 7 dias; cresce linearmente; 1.0 após 21 dias

TDEE_efetivo = (1 − w_empirico) · TDEE_prior  +  w_empirico · TDEE_est
```

Onde `TDEE_prior = BMR · prior_activity_factor` (Mifflin ou Katch-McArdle do onboarding) e
`TDEE_est` é o estimador da janela acima. `n_dias_com_dado` conta apenas dias com pelo menos
uma refeição registrada E pelo menos uma pesagem na janela.

- **Dias 0–6:** `w = 0.0` → prior puro. Sem dados de peso suficientes, não há sinal confiável.
- **Dias 7–20:** transição linear. O prior vai perdendo peso conforme o balanço empírico acumula.
- **Dias 21+:** `w = 1.0` → TDEE inteiramente data-driven. `prior_activity_factor` se torna
  irrelevante (campo `NULL`ável em `goals` por isso).

> Use **janela ≥14–21 dias** justamente porque mudanças de curto prazo são glicogênio/água (por
> isso a suavização da §2.1 alimenta esse cálculo, não o peso cru).

- **Prior TMB:** Katch-McArdle (`370 + 21.6·LBM`, `LBM=peso·(1−BF%)`) se houver BF; senão
  Mifflin-St Jeor. **Só prior** — o motor real é o balanço energético.

---

### 2.4 Estatística descritiva do consumo

Sobre o `kcal_point` (ou o ponto médio do intervalo) dos últimos 7/14/30 dias: **média, mediana,
desvio-padrão**. Sugestão: troque o SD cru pelo **coeficiente de variação `CV = SD/média`** como
métrica de "constância" — é adimensional, então comparável entre fases de cut/bulk com médias
diferentes. Mostre também mediana vs média lado a lado: divergência grande = dias de exagero
pontuais (distribuição assimétrica).

---

### 2.5 Análise de frequência

`GROUP BY normalized_tag` em `meal_components`, ordenado por contagem (top-N). Se quiser
sofisticar, pondere por recência (decaimento exponencial na data) para "o que ando comendo
*ultimamente*".

---

### 2.6 Triagem (alertas de adesão)

Janela deslizante sobre `daily_summary`: conta dias consecutivos abaixo do `protein_target_g`
(ou gordura). Dispara alerta após `k` dias seguidos (`k` configurável). Os limiares vêm do cálculo
de meta (§2.3), não são chutados. Mantenha como *nudge* informativo, não alarme.

---

### 2.7 Progressão por XP (substitui streak) + cheat day

O streak de registro sofre do efeito "quebrei a corrente de 40 dias, abandonei tudo". Em vez disso,
**XP + níveis cumulativos** (modelo de progressão, comum em treino de força estruturado):

```
Eventos de XP (configuráveis, persistidos em xp_log):
  registrar todas as refeições do dia .. +100 XP
  bater a meta de proteína ............. +50 XP
  registrar uma pesagem ................ +30 XP
  marcar/usar um cheat planejado ....... +10 XP  (premia planejar, não pune)
  bater a meta diária de água .......... +20 XP

Nível = floor( sqrt(xp_total / 100) )   -- curva de raiz quadrada: crescimento decrescente
```

Regra-chave: **falhar um dia = 0 ponto naquele dia, e nada se perde.** XP total e nível ficam
intactos. Os eventos são inseridos em `xp_log` no fechamento do dia (workmanager noturno) e
somados para `daily_summary.xp_earned`. O nível é derivado da soma total de `xp_log.xp_amount` —
nunca persistido diretamente (evita dessincronização).

`cheat day/meal`: flag `is_cheat` em `daily_summary`. Não derruba progressão, fica **fora** das
estatísticas de constância (§2.4) e dos alertas (§2.6), mas continua somando no total real. Sugiro
orçamento configurável (ex.: 1/semana). Quem ainda quiser uma streak pode tê-la como elemento
secundário **com "streak freeze"** (1–2 perdões/mês), mas o XP é o motor principal.

---

## 3. Wireframes — 3 abas

### Aba 1 — Tracker / Home (abre aqui)

A home **não** abre numa câmera crua. Abre num painel enxuto com **as métricas do dia no topo** e
o botão de foto dominando a metade de baixo — o usuário vê onde está antes de registrar, e registra
em 1 toque.

```
┌─────────────────────────────┐
│   ◯ 1.480 / 2.050 kcal       │   ← anel de progresso do dia
│   P 92g · C 150g · G 48g     │   ← barras de macro vs meta
│   Restam ~570 kcal · ⭐ Nv 4  │   ← saldo + nível XP atual
│   💧 1.250 ml  [ +250 ] [+500]│   ← faixa de água
│   ─────────────────────────  │
│      ╭───────────────╮        │
│      │  📷  REGISTRAR │       │   ← botão gigante (abre câmera)
│      ╰───────────────╯        │
│  [ 🎤 falar ] [ ✏️ escrever ] │   ← atalhos opcionais
│  [ 📦 barcode ] [ ⚡ quick ] │   ← scanner e Quick Add
└─────────────────────────────┘
        ↓ (toque em REGISTRAR → câmera → captura)
┌─────────────────────────────┐
│  ◀  Confirmar refeição        │
│  [ thumbnail da foto ]        │
│  Calorias    420 – 520 kcal   │   ← intervalo exibido (leitura)
│  ▶  kcal: [ ─────●───── ] 470 │   ← único campo editável (slider)
│  Proteína     28 – 34 g       │   ← macros exibidos (leitura)
│  Carbo        40 – 50 g       │
│  Gordura      12 – 16 g       │
│  ⚠ "Leite integral?" (se houver clarifying_question)
│        [  SALVAR  ]           │
└─────────────────────────────┘
```

**Edição = só no `kcal_point`:** editar ranges no mobile é horrível. A folha de confirmação
**mostra** o intervalo e *explica* a largura ("estreito: havia talher de referência" / "largo: sem
referência de escala"), mas o **único campo editável é o `kcal_point`**, via stepper/slider de 1
toque. Ao mudar o ponto, o app **recalcula o intervalo automaticamente** ao redor dele (mesma
lógica ±% da §4.0) e escala os macros proporcionalmente.

> **Limitação conhecida (V1):** ao ajustar `kcal_point`, os macros escalam proporcionalmente
> (ex.: +20% kcal → +20% em P/C/G). Isso é tecnicamente impreciso — o erro da IA pode estar
> concentrado num único macro (ex.: subestimou a gordura, não a proteína), mas ajuste macro
> a macro tornaria a UX complexa demais para uma V1. Registrar como débito de UX: edição
> individual de macros é candidata natural a V2. O `ai_raw_json` sempre é salvo, então
> reprocessamento futuro é possível.

**Quick Add / nunca ficar "cego" (resolve o paradoxo offline):** além da foto, a home tem um atalho
**Quick Add** que cria uma entrada **provisória imediata** sem IA:
- digita só o `kcal_point` (e macros opcionais), OU
- escolhe de uma **busca local** de alimentos frequentes/favoritos (construída do histórico) + um
  pequeno seed de itens comuns + produtos já escaneados (§8).

A entrada provisória **já entra na soma do dia na hora** (`status='provisional'`). Se o usuário
também tirou foto, ela segue na fila e, ao sincronizar, a estimativa da IA **reconcilia** a
provisional conforme §9.2.

---

### Aba 2 — Histórico do Dia

```
┌─────────────────────────────┐
│   ◯ 1.480 / 2.050 kcal       │   ← anel de progresso vs meta do dia
│   P 92g · C 150g · G 48g     │   ← barras de macro
│   ─────────────────────────  │
│  08:12  🍳 Ovos + pão  ~380   │
│  12:40  🍛 Almoço      ~620   │
│  16:05  🥤 Whey (fila ⏳)     │   ← item ainda na fila offline
│  ...                          │
│   Déficit estimado: −570 kcal │
└─────────────────────────────┘
```

---

### Aba 3 — Analytics

```
┌─────────────────────────────┐
│  PESO                         │
│   •    pontos = pesagens crus │
│  ╲___  linha = peso suavizado │
│      ╲╌╌ projeção + faixa     │
│  "Meta provável: 12–19 set"   │
│  ─────────────────────────    │
│  CONSUMO (30d)                │
│  [Média 1.9k][Mediana 1.85k]  │
│  [SD 320][CV 17%]             │
│  ─────────────────────────    │
│  MAIS CONSUMIDOS              │
│  arroz · frango · ovo · café  │
│  ─────────────────────────    │
│  ⭐ Nível 4  (1.230 XP total) │
│  🔥 9 dias batendo proteína   │
│  ⚠ 3 dias seguidos com        │
│      proteína baixa           │
└─────────────────────────────┘
```

---

## 4. Contrato da IA (Gemini) — versão revisada

### 4.0 O que a literatura diz sobre a margem de erro

Antes de fixar a UI em "±20%", veja o que os estudos recentes de estimativa nutricional por LLM
multimodal medem de fato:

| Estudo | Modelo | Métrica medida |
|---|---|---|
| *Performance Eval. of 3 LLMs* (PMC12513282) | GPT-4o / Claude 3.5 | **MAPE ~36% peso, ~36% energia**; Gemini 1.5 Pro pior (64–110%) |
| Multi-agente *closed-loop* (arXiv 2601.04491) | GPT-4o / Gemini 2.5 | energia **~12–34% COM objeto de referência**, **~16–50% SEM** |
| Aval. ChatGPT-4 (MDPI Nutrients 17/4/607) | GPT-4 | só **66% das estimativas de energia** ficaram com erro <10% |
| CNN dedicada (wellally) | ResNet50 | "best case **±25%**", limitada por falta de volume/profundidade em 2D |

Três conclusões de design, todas com respaldo nos papers:

1. **A margem real não é 20% — é maior e assimétrica.** Use **±35% como padrão** para o intervalo
   de energia (alinhado ao MAPE de GPT-4o/Claude), estreitando para ~±20–25% **só quando houver
   objeto de referência claro na cena** (talher/mão/lata), porque os estudos mostram erro ~2× menor
   com referência de escala.
2. **Viés sistemático de subestimativa que cresce com a porção** (Bland-Altman, slopes −0,23 a
   −0,50). Então o intervalo deve ser **assimétrico para cima**:
   `min = ponto·0,80`, `max = ponto·1,40`.
3. **Contexto reduz erro de forma comprovada** (ChatGPT-5, PMC12655113; O'Hara et al.): descritores
   não-visuais + lista de ingredientes derrubam MAE. → justifica o input de texto/voz e o uso de
   persona/CoT no prompt.

---

### 4.1 System prompt robusto (persona + CoT + few-shot)

Estrutura recomendada (persona no `system_instruction`, imagem+nota no `user`):

```
[system_instruction]
PERSONA: Você é um nutricionista clínico com 15 anos de experiência em
avaliação dietética por fotografia e porcionamento visual. É meticuloso com
escala e calibrado contra subestimativa.

TAREFA: A partir de UMA foto (+ nota opcional), estime energia e macros da
refeição. Raciocine internamente nesta ordem (não exponha o raciocínio):
  1. Liste os componentes visíveis do prato.
  2. Para cada um, ache um objeto de escala (talher, copo, mão, lata, prato).
     Estime diâmetro/área e a PROFUNDIDADE do recipiente (fundo vs. raso).
  3. Estime massa (g) de cada componente a partir da escala+profundidade.
  4. Converta massa → energia e macros por tabela nutricional padrão.
  5. Calibre contra subestimativa: a literatura mostra viés de subestimar,
     crescente com a porção. Ajuste o ponto central para cima nesse sentido.

INCERTEZA: devolva intervalo POR componente e total. Largura do intervalo:
  - SEM objeto de referência confiável → min = ponto×0.75, max = ponto×1.45
  - COM objeto de referência claro       → min = ponto×0.85, max = ponto×1.25
  Defina "ai_confidence": low / medium / high conforme a referência de escala.

TAGS (controlado — NÃO invente fora desta lista; mapeie p/ a mais próxima):
  grupo_alimentar ∈ {proteina_animal, proteina_vegetal, laticinio, graos_cereais,
    tuberculo, leguminosa, vegetal, fruta, gordura_oleo, doce_acucar,
    bebida_calorica, bebida_zero, molho_condimento, ultraprocessado, outro}
  metodo_preparo ∈ {cru, cozido, grelhado, frito, assado, refogado,
    no_vapor, liquido, desconhecido}
  Cada componente recebe EXATAMENTE um grupo_alimentar e um metodo_preparo.

FILTRO DE PERGUNTA: só preencha "clarifying_question" se a dúvida alterar a
  energia em >300 kcal (ex.: integral vs. desnatado num copo grande). Senão,
  null, assuma o cenário mais provável e registre em "assumptions".

SAÍDA: responda SOMENTE o JSON do schema. Sem markdown, sem texto fora do JSON.

EXEMPLO (few-shot):
[entrada: foto de prato fundo com arroz, feijão, frango grelhado; nota vazia]
[saída JSON esperada conforme schema, com tags do vocabulário acima]

[user]
{imagem} + {nota opcional do usuário, ex.: "whey com leite desnatado"}
```

Use `responseMimeType: "application/json"` + `responseSchema` → JSON válido garantido pela API;
`temperature` baixa (0.2–0.4) p/ consistência.

---

### 4.2 Tags controladas (por que enum, não texto livre)

Sem vocabulário fechado a LLM retorna "frango", "frango grelhado", "peito de frango", "chicken" —
e a Análise de Frequência vira ruído. Por isso `grupo_alimentar` e `metodo_preparo` são **enums
fixos**. O `name` fica livre (descritivo p/ o usuário ler), mas o agrupamento estatístico usa
**só os enums + o `normalized_tag`** (slug do `name`).

---

### 4.3 Schema de resposta

```json
{
  "meal_summary": "string",
  "ai_confidence": "high | medium | low",
  "scale_reference_found": true,
  "estimates": {
    "calories_kcal": { "min": 0, "max": 0, "point": 0 },
    "macros_g": {
      "protein":       { "min": 0, "max": 0, "point": 0 },
      "carbohydrates": { "min": 0, "max": 0, "point": 0 },
      "fat":           { "min": 0, "max": 0, "point": 0 }
    }
  },
  "components": [
    {
      "name": "string",
      "normalized_tag": "string",
      "grupo_alimentar": "proteina_animal | proteina_vegetal | laticinio | graos_cereais | tuberculo | leguminosa | vegetal | fruta | gordura_oleo | doce_acucar | bebida_calorica | bebida_zero | molho_condimento | ultraprocessado | outro",
      "metodo_preparo": "cru | cozido | grelhado | frito | assado | refogado | no_vapor | liquido | desconhecido",
      "estimated_mass_g": 0,
      "kcal_point": 0
    }
  ],
  "clarifying_question": null,
  "assumptions": ["string"]
}
```

> `scale_reference_found` é o que o app usa para decidir a largura do intervalo e o `ai_confidence`.
> `meals.kcal_point` = `estimates.calories_kcal.point` (fonte de verdade para somas).
> `meal_components` = array `components` (informativo para frequência — ver nota §1).

---

## 5. Onboarding — coleta de dados iniciais

O TDEE prior (§2.3) requer: altura, sexo biológico, peso inicial e idade. Sem esses dados, não há
`BMR` → não há `kcal_target` → a Home fica em estado indefinido no dia 0.
A chave da API Gemini também precisa ser coletada aqui — não pode ser embutida no bundle.

### Fluxo (4 telas, não pulável)

**Tela 1 — Dados físicos** (obrigatórios para Mifflin-St Jeor):
- Peso atual (kg)
- Altura (cm)
- Sexo biológico (M / F) — com 1 frase explicando que é usado apenas para o cálculo de TMB
- Idade ou data de nascimento

**Tela 2 — Composição corporal** (opcional, melhora prior):
- % gordura corporal — input livre ou botão "não sei" (→ usa Mifflin em vez de Katch-McArdle)

**Tela 3 — Meta:**
- Objetivo: corte / manutenção / ganho de massa
- Peso-alvo (opcional; se preenchido, habilita a projeção de §2.2)
- Data-alvo (opcional)
- Déficit/superávit desejado: input em kcal/dia **ou** "X% do peso/semana" (app converte)
- Nível de atividade estimado: 5 opções (sedentário → muito ativo) → salvo como
  `prior_activity_factor`; será calibrado e descartado após ~21 dias de dados

**Tela 4 — Configurações do app:**
- Janelas de refeição para notificações (horários padrão editáveis)
- Chave da API Gemini (campo de senha, salvo em `flutter_secure_storage` — **nunca** no Isar)
- Permissão de notificação: solicitada aqui, com 1 frase ("para te lembrar de registrar sua
  próxima refeição")

### Persistência pós-onboarding

```
Dados físicos     → primeiro registro em weight_history
                  + primeira linha em goals (effective_from = hoje)
                     com bmr, tdee (prior), kcal_target calculados na hora
API key           → flutter_secure_storage
Preferências      → tabela settings (chave-valor simples)
```

> A ausência de onboarding é o único bloqueador absoluto para o dia 0: sem `goals.kcal_target`,
> a Home não tem meta para exibir e o deficit fica `NULL`. Implementar antes de qualquer outra tela.

---

## 6. Sistema de notificações

Objetivo: lembrar de registrar e abrir **direto na câmera** com um toque. Tudo local (sem servidor)
— combina com a arquitetura offline-first.

**Lib:** `flutter_local_notifications` + `timezone` (agendamento por fuso correto).
Em RN: `notifee` ou `expo-notifications`.

**Estratégia de agendamento — adaptativa, não spam:**

```
Padrão: notificações em janelas de refeição configuráveis
        (ex.: 08:00 / 12:30 / 20:00) — agendadas como repeating local notifications.

Inteligente (recomendado): antes de disparar, cheque o estado do dia:
  - já registrou algo nessa janela?  → cancela/suprime a notificação
  - dia marcado como cheat?          → suprime alertas
  - passou X h do último registro num horário típico? → 1 lembrete gentil
Reagenda diariamente a partir dos horários reais de registro do usuário
(média dos últimos N dias) em vez de horários fixos.
```

**Deep-link "abrir já na câmera":**

```
Notificação carrega payload: { "action": "open_capture" }
  → onTap / onDidReceiveNotificationResponse lê o payload
  → app navega direto para a rota de captura (pula a home)
  → câmera já ativa, 1 toque pra foto

Android: PendingIntent com intent extra (FLAG_ACTIVITY_SINGLE_TOP);
         no Flutter o plugin entrega via onDidReceiveNotificationResponse.
iOS:     UNNotificationResponse.userInfo → roteia no AppDelegate/plugin.
Use um esquema de rota tipo  app://capture  e trate no onboarding de navegação.
```

**Permissões/robustez:**
- Peça permissão de notificação no onboarding (Tela 4), explicando o valor em 1 frase.
- Android 13+: `POST_NOTIFICATIONS` em runtime. iOS: `requestPermissions`.
- Agendamento exato em Android 12+ pode exigir `SCHEDULE_EXACT_ALARM`; se não tiver, use janela
  inexata (suficiente pra lembrete).
- Deixe **frequência e horários 100% configuráveis** e fáceis de silenciar — um lembrete que
  irrita é desinstalado.

---

## 7. Nota de produto (papel de PM)

Uma decisão de design vale repensar: **streak de "dias consecutivos em déficit"**. Como métrica de
gamificação ela premia o resultado errado — empurra a pessoa a evitar dias de manutenção/descanso
só pra não "quebrar a sequência", e transforma um dia normal de mais comida numa punição. Por isso
o sistema de XP (§2.7) substitui o streak como motor principal.

**Exportação de dados.** Para um app offline-first, a ausência de export cria risco de lock-in
percebido — o usuário não confia em colocar meses de dados num app sem saber que pode tirá-los.
Implementar nas configurações:

- **CSV**: uma linha por `meals` (date, kcal_point, macros, source, status) + aba separada para
  `weight_history`. Trivial de implementar; cobre a maioria dos casos.
- **JSON**: dump completo de todas as tabelas (útil para backup e migração de dispositivo).
- Entrega via share sheet nativo do SO — sem infraestrutura de servidor.

Baixo esforço de implementação, alto impacto em confiança e retenção.

---

## 8. Funcionalidades essenciais adicionais

### Leitor de código de barras (industrializados / whey)

Rodar foto na IA para um produto de rótulo é desperdício de token e de precisão. Use
**`mobile_scanner`** (Flutter) → lê o EAN/UPC → consulta a API gratuita do **Open Food Facts** →
retorna nutrição por 100 g/porção → usuário só ajusta a quantidade. **Instantâneo e exato**, zero
token de IA.

- Cache local de cada produto escaneado (`products`, §1) → no próximo scan funciona **offline** e
  alimenta a busca do Quick Add.
- Open Food Facts requer rede no 1º scan; depois é inteiramente local.
- `meals.source = 'barcode'` para distinguir na Análise de Frequência.

### Registro rápido de água

Botão `+` persistente na Home, sem IA: toques fixos de **250 ml / 500 ml**. Registrado em
`water_log` (§1). Mostra total do dia na faixa da Home e soma em `daily_summary.total_water_ml`.
É baixo esforço e um dos maiores fatores de retenção diária — gente abandona tracker que torna
água trabalhosa.

---

## 9. Pipeline Offline-First

### 9.1 Fluxo principal

```
Captura → grava meal(status='queued') + salva foto local → some da UI
   │
   ├─ se online: dispara processamento na hora
   └─ se offline: workmanager observa connectivity_plus
                     │
           (conexão volta) → pega meals 'queued' (FIFO)
                     │  status='processing'
                     ▼
           chama Gemini (com a foto comprimida + nota)
               ├─ sucesso → preenche estimativas, status='done'
               │            reconcilia se havia 'provisional' (§9.2)
               │            agenda deleção de foto (§1.1)
               └─ erro    → retry_count++, backoff exponencial
                            status='error' após N tentativas (revisão manual)
```

- **Idempotência:** processe por `id`; nunca duplique se o job rodar duas vezes.
- **Rate limit (verificado jun/2026):** o tier grátis cobre só os modelos **Flash**. **Gemini 2.5
  Flash ≈ 10 RPM / 250 RPD**; **Flash-Lite ≈ 15 RPM / 1.000 RPD**; ambos ~250k tokens/min.
  Recomendo **Flash-Lite como default**. Processe **estritamente em série, com delay intencional**
  (≥1 chamada a cada 4–6 s) — descarregar 5 fotos de uma vez ao reconectar dispara 429.
- **Compressão agressiva:** reduza para **~800 px no lado maior**, JPEG ~65%, antes de enviar.
  Economiza tokens e mantém a estimativa boa — o gargalo é referência de escala, não megapixels.
- **Tratamento de 429:**

```dart
final retryAfterHeader = response.headers['retry-after'];
int waitSecs;
if (retryAfterHeader != null) {
  // Pode ser inteiro (segundos) ou HTTP-date; tratar ambos
  waitSecs = int.tryParse(retryAfterHeader)
      ?? _parseHttpDate(retryAfterHeader).difference(DateTime.now()).inSeconds;
  waitSecs = waitSecs.clamp(1, 120);
} else {
  waitSecs = min(baseBackoff * pow(2, retryCount), 64).toInt();
}
await Future.delayed(Duration(seconds: waitSecs));
```

---

### 9.2 Máquina de estados e reconciliação provisional → IA

**Diagrama de estados de `meals.status`:**

```
provisional ──────────────────────────────────────► done
    │        (entrada manual sem foto; não vai à IA)
    │
    ├─(usuário tirou foto junto)──► queued
    │
queued ──────────────────────────► processing ──► done
                                        │
                                        └──► error ──(reprocessamento manual)──► queued
```

**Lógica de reconciliação** (quando uma entrada `provisional` tem foto associada que volta da IA):

1. Verificar se o usuário **editou** o `kcal_point` da provisional manualmente (comparar com o
   valor inicial inserido no Quick Add).

2. **Não editou** → substituir silenciosamente pelo valor da IA. Atualizar `kcal_point`,
   `kcal_min/max`, macros, `ai_confidence`, `meal_components`, `ai_raw_json`. Status → `done`.

3. **Editou** → exibir notificação inline na Aba 2:
   > "IA estimou **X kcal** para esta refeição. Manter sua edição (**Y kcal**) ou usar a estimativa?"
   
   O usuário escolhe; o valor eleito vira o `kcal_point` final. Em ambos os casos:
   `ai_raw_json`, `ai_confidence` e `meal_components` são **sempre salvos** — servem ao Analytics
   independentemente da escolha do usuário.

4. **Após qualquer reconciliação:** recalcular `daily_summary` do dia afetado imediatamente
   (não aguardar o batch noturno).

---

### Ordem de implementação sugerida

1. **Onboarding** (§5) — bloqueador absoluto: sem `goals.kcal_target`, a Home não funciona.
2. **Modelo de dados completo** (§1) — todas as tabelas, incluindo `xp_log`, `products`, `water_log`.
3. **Captura + salvamento local** — sem IA ainda; estimativa manual via Quick Add.
4. **Integração Gemini + fila offline** (§9) — com reconciliação provisional.
5. **EMA do peso + TDEE dinâmico** (§2.1, §2.3) — prior → calibração.
6. **Aba Analytics** — estatística descritiva → projeção OLS com IC (§2.2, §2.4).
7. **Barcode scanner + Open Food Facts** (§8).
8. **Sistema de XP + cheat day** (§2.7).
9. **Notificações adaptativas** (§6).
10. **Exportação de dados** (§7) — baixo custo, fechar no mesmo sprint das notificações.
