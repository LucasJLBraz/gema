# Design: acurácia de estimativa de KCAL/quantidades + escolha de modelo Gemini

**Data:** 2026-07-19
**Status:** aprovado, aguardando plano de implementação
**Escopo:** itens #1 e #2 do backlog GEMA (`docs/backlog-handoff-2026-07-19.md`), tratados juntos por serem interdependentes — a escolha do modelo Gemini condiciona o orçamento de tokens disponível para qualquer dado injetado no prompt, e ambos são decididos pelo mesmo benchmark.

## Contexto

O prompt de produção (`lib/core/gemini/gemini_service.dart`, `_systemPrompt`) estima a massa de cada componente da refeição por raciocínio visual (objeto de escala) e depois converte massa→energia/macros inteiramente por conhecimento paramétrico do modelo — a instrução do prompt menciona uma "tabela nutricional padrão", mas nenhuma tabela real é injetada no contexto. `docs/spec_diet_tracker_v2.md` §4 já registra uma pequena revisão de literatura anterior (MAPE ~36% peso/energia para GPT-4o/Claude 3.5, Gemini 1.5 Pro pior a 64–110%) e já calibrou os intervalos assimétricos de incerteza do prompt atual (`0.75×`–`1.45×` sem objeto de referência, `0.85×`–`1.25×` com referência) a partir dela, mas nunca propôs injeção de base de dados nutricional — parou em "prompt engineering + intervalos calibrados".

Este spec nasceu de uma sessão de brainstorm que ampliou inicialmente o escopo para tratar a estimativa de porção/volume como alvo primário, mas a pesquisa de literatura conduzida durante a própria sessão (ver "Pesquisa conduzida" abaixo) trouxe evidência forte o suficiente para recalibrar essa decisão de volta ao escopo original do handoff: grounding da conversão massa→kcal, não a estimativa de volume.

## Pesquisa conduzida

Literatura levantada via skill/MCP `paper-rag` (papers indexados em `references/Papers/`, citation keys `dietai24_2025` e `vedovelli_model_dominates_2026`) + web search, complementando a revisão já existente em `docs/spec_diet_tracker_v2.md` §4.

### Achado decisivo: Vedovelli et al. 2026 (*Scientific Reports*, DOI 10.1038/s41598-026-58755-w)

Avaliação sistemática de 40 VLMs (8 provedores) no dataset Nutrition5k contra nutricionistas profissionais:

- **Arquitetura do modelo domina 99,6% da variância de performance** (até 40% de diferença de RMSLE entre modelos) — o fator isoladamente mais importante.
- **Prompt engineering não teve efeito estatisticamente significativo** (CoT, few-shot, persona de especialista — exatamente o padrão usado no `_systemPrompt` atual do GEMA — todas as 6 variações testadas, p > 0.05), apesar de essas técnicas melhorarem 10–50% em tarefas de raciocínio puramente textual.
- **Múltiplas fotos/ângulos não ajudam** (RMSLE 0.627 vs 0.623, p = 0.182).
- Fotos de celular comuns (não padronizadas em laboratório) superam fotos de laboratório em 12,8% (p = 0.020) — relevante porque é exatamente o tipo de foto que o GEMA captura.
- Descrição textual de ingredientes ajuda modestamente (5,5% agregado), mas com heterogeneidade extrema entre modelos (−19,1% a +3,4%).
- Estimativa de porção/volume a partir de imagem 2D única é descrita como **"ill-posed"** — não é resolvida por prompt melhor, apenas por pipelines geométricos separados (depth estimation, reconstrução 3D), um escopo de engenharia muito maior que este item.
- **Recomendação textual dos próprios autores**: abordagens híbridas VLM + base de dados são "a particularly promising direction" — usar o VLM só para identificação (e, opcionalmente, porção) e consultar uma base de composição externa para os valores por item, porque a inferência composicional implícita do VLM é a fonte dominante de erro. Os autores também avisam explicitamente que isso melhora a etapa de composição, **não** a de porção.

### Confirmação prática: DietAI24 (Yan et al. 2025, *Communications Medicine*, DOI 10.1038/s43856-025-01159-0)

RAG (GPT Vision → busca vetorial sobre a base FNDDS, 5624 alimentos, via LangChain + vector DB) reduziu o MAE em **63%** para estimativa de peso/nutrientes vs. abordagens sem base injetada, em pratos reais mistos (ASA24/Nutrition5k). Arquitetura pesada (backend próprio, vector DB, múltiplas chamadas) — incompatível com o modelo do GEMA de chamada única direto do device — mas o princípio (grounding em base real em vez de conhecimento paramétrico) é o que importa aqui, não a implementação literal.

### Decisão de recalibração de escopo

Diante desses achados, o escopo foi restrito a: (1) escolha de modelo Gemini via benchmark, não suposição a priori; (2) grounding da conversão massa→kcal via tabela de referência. **Estimativa de porção/volume fica documentada como limitação conhecida, sem solução barata disponível** — melhorá-la de verdade exigiria um item de backlog separado, futuro, de pipeline de visão computacional geométrica (fora de escopo aqui).

### Gemini — pricing e rate limits (julho/2026)

| Modelo | Preço input/output (por 1M tokens) | Tier grátis |
|---|---|---|
| Gemini 2.5 Flash-Lite (atual) | $0.10 / $0.40 | 5–15 RPM, ~1000 RPD |
| Gemini 2.5 Flash | $0.30 / $2.50 | 5–15 RPM, ~1000 RPD |
| Gemini 2.5 Pro | $1.25–2.50 / $10–15 | sem tier grátis desde abril/2026 |

Fonte: busca web em [ai.google.dev/gemini-api/docs/pricing](https://ai.google.dev/gemini-api/docs/pricing) e agregadores de pricing (jul/2026). Pro está descartado por não ter tier grátis, o que quebraria a premissa "grátis para o usuário único" do app hoje.

### Fonte de dados nutricional: TACO

Avaliadas TACO (UNICAMP, ~600 alimentos, dados abertos em JSON/CSV em repositórios GitHub) e TBCA (USP, ~2088 alimentos, licença/formato de API não confirmados na pesquisa). **Decisão: TACO** — cobertura menor, mas formato e abertura de dados já confirmados; suficiente para o V1 dado que o schema do GEMA já usa categorias fechadas (`grupo_alimentar`, 15 valores) que limitam o espaço de alimentos relevantes.

## Design

### 1. Mudança de prompt e schema (`lib/core/gemini/gemini_service.dart`)

- `_systemPrompt` ganha um bloco de **tabela de referência compacta**: subconjunto curado da TACO (~150–250 linhas), formato compacto `nome|kcal_100g|proteina_100g|carbo_100g|gordura_100g`. Custo de token estimado: ~3–5k tokens/chamada, desprezível mesmo no Flash-Lite (~$0,0005/chamada).
- Instrução do CoT muda de "converta massa→energia por tabela nutricional padrão" (paramétrico) para: "para cada componente, procure a entrada mais próxima na TABELA DE REFERÊNCIA abaixo; se encontrar equivalente razoável, use os valores dela para calcular energia/macros; se não encontrar, estime por conhecimento próprio e marque `matched_reference_food` como `null`".
- `_responseSchema` ganha o campo `matched_reference_food` (string, nullable) por componente — nome da entrada da TACO usada (ou `null`). Serve para auditoria (`aiRawJson` já persiste a resposta crua) e para medir taxa de cobertura no benchmark.
- Estimativa de porção/volume (a cadeia de raciocínio sobre objeto de escala, os intervalos assimétricos `0.75×`–`1.45×`/`0.85×`–`1.25×`) **não muda** — fora de escopo, já calibrada pela literatura anterior.
- Nenhuma mudança de arquitetura fora deste arquivo: continua uma única chamada REST síncrona, mesmo fluxo de retry/backoff em `queue_processor.dart`.

### 2. Curadoria da tabela TACO

- Fonte: repositório JSON aberto da TACO (confirmar licença do repositório específico escolhido antes de vendorizar — passo de implementação, não decidido aqui).
- Processo: mapear os alimentos mais comuns/genéricos de cada um dos 15 valores de `grupo_alimentar` já existentes no schema do GEMA; excluir entradas muito específicas de laboratório (ex. variações de cultivar) que não aparecem em fotos de refeição reais.
- Formato final: asset estático bundled no app (ex. `assets/data/taco_reference.json`, ou constante Dart gerada a partir dele), versionado junto ao código-fonte — sem infraestrutura de atualização em runtime, sem novo schema Isar. Atualização é manual e de baixa frequência (a TACO não é atualizada com frequência).

### 3. Processo de decisão do modelo (item #2)

Não decidir a priori qual modelo usar em produção. Usar o mesmo benchmark da seção 4 para comparar `gemini-2.5-flash-lite` (atual, grátis) vs `gemini-2.5-flash` (pago, ~3–6× mais caro em output) rodando o **mesmo** prompt grounded, e decidir com base no ganho de acurácia observado vs. o custo real projetado para o volume de uso do app. `gemini-2.5-pro` fica fora da comparação por não ter tier grátis.

### 4. Benchmark de avaliação

Não existe conjunto de ground truth hoje — precisa ser criado como parte da implementação.

- **Protocolo:** N=30–50 refeições reais, fotografadas pela mesma pipeline de captura do app (câmera ou galeria, como descrito em `capture_screen.dart`), pesadas em balança de cozinha antes/depois de cada componente.
- **Fonte de referência:** calculada via TACO — com uma ressalva de risco importante: usar a mesma fonte para grounding do prompt e para ground-truth do benchmark pode inflar artificialmente a vantagem da abordagem proposta (comparando contra si mesma). Por isso, incluir também um subconjunto (ex. 8–10 refeições) com referência independente de rótulo nutricional real de produto embalado, para um teste mais justo.
- **Métricas:** MAPE e MAE de peso e kcal (mesmas métricas já citadas em `docs/spec_diet_tracker_v2.md` §4, para comparabilidade direta com a literatura), bias sistemático via Bland-Altman, e taxa de `matched_reference_food != null` (proxy de cobertura da tabela embutida).
- **Matriz de comparação:** prompt atual (produção, sem tabela) × prompt grounded (proposto) × 2 modelos (Flash-Lite, Flash) = 4 combinações rodadas sobre o mesmo conjunto de N fotos.

### 5. Critério de gate e rollout

- Só promover a mudança de `_systemPrompt`/`_responseSchema`/`_model` de produção se o benchmark mostrar melhoria prática de MAPE de kcal sobre a baseline atual, sem estourar o orçamento de rate-limit do tier grátis (caso a decisão seja permanecer em Flash-Lite).
- Sem necessidade de feature flag — é uma troca de constantes (`_systemPrompt`, `_responseSchema`, `_model`) após validação via benchmark, dado o estágio do projeto (app de usuário único, early-stage).
- Thresholds numéricos exatos de "melhoria prática" ficam para o plano de implementação, não fixados aqui.

## Riscos e limitações conhecidas

- Estimativa de porção/volume permanece sem solução barata — item de backlog separado, futuro, se a precisão desse componente específico se tornar prioridade (exigiria pipeline de CV geométrica, não apenas prompt/dados).
- Viés de auto-comparação no benchmark (mesma fonte para grounding e ground-truth) mitigado pelo subconjunto de referência independente, mas não eliminado — o plano de implementação deve tratar os dois resultados separadamente, não como uma média única.
- Cobertura da tabela TACO (~600 itens, subconjunto curado ainda menor) pode ser insuficiente para pratos compostos ou muito regionais — taxa de `matched_reference_food == null` no benchmark é o sinal a observar; se alta, a evolução natural é o lookup determinístico local (Isar, mesmo padrão de `lib/features/products/`) como camada adicional, não implementado neste ciclo.
- Licença de uso dos dados da TACO precisa ser confirmada no repositório específico escolhido antes da implementação — não verificada nesta sessão de pesquisa.

## Referências

- `dietai24_2025` — Yan et al. 2025, DietAI24, *Communications Medicine* (indexado em `references/Papers/`).
- `vedovelli_model_dominates_2026` — Vedovelli et al. 2026, *Scientific Reports* (indexado em `references/Papers/`).
- PMC12513282, arXiv 2601.04491, MDPI Nutrients 17(4):607, PMC12655113 — já citados em `docs/spec_diet_tracker_v2.md` §4.
