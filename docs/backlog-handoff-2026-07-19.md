# GEMA — Backlog handoff (2026-07-19)

Levantamento inicial de 8 itens do backlog, com leitura de PM (impacto × esforço) e achados técnicos concretos no código. Este documento é o ponto de partida para retomar cada item pendente — um de cada vez, via `superpowers:brainstorming`.

**Nota de processo (fixada em 2026-07-20):** specs e planos (`docs/superpowers/specs/`, `docs/superpowers/plans/`) são artefatos de trabalho do fluxo Superpowers, não documentação do produto. Depois que um item é implementado, o commit de spec/plano correspondente é removido do histórico da `main` (via rebase, antes do PR) — este arquivo é que registra o resultado. Enquanto um item está em andamento (spec/plano prontos, implementação não iniciada ou em curso), os arquivos de spec/plano ficam na `main` normalmente como referência de trabalho.

## Concluído

**Bugs #5 (inserção sem confirmação) e #6 (paste trava onboarding)** — corrigidos.
- PR: https://github.com/LucasJLBraz/gema/pull/15 (branch `fix-confirm-onboarding-bugs`)
- `MealQueueNotifier.deleteMeal` agora também apaga o arquivo de foto (best-effort); `ConfirmMealScreen` chama esse método a partir do botão X e do gesto de voltar (via `PopScope`) antes de navegar.
- Botão "Continuar"/"Começar" do onboarding envolvido em `ListenableBuilder` (merge dos 5 controllers) — reage a paste/autofill, não só a digitação.
- `flutter test`: 34/34 passando. Falta o smoke test manual em dispositivo físico (pendente configuração de `adb`).

**Itens #1 (acurácia de KCAL) e #2 (migração de modelo Gemini)** — investigados, benchmarkados e implementados juntos.
- PR: https://github.com/LucasJLBraz/gema/pull/20 (branch `kcal-accuracy-and-model-migration`)
- Benchmark contra 100 fotos reais (Nutrition5k + SNAPMe, ambos CC BY 4.0) testou 6 variantes de prompt/modelo com teste t pareado por amostra (não só MAPE agregado, que mascarava outliers). Único achado estatisticamente significativo: remover o chain-of-thought explícito (`no_cot`, t=2.08) — o grounding com a tabela TACO não ajudou sozinho (t=0.40) e apagou o ganho do `no_cot` quando combinado (t=0.26).
- Primeira versão que foi para produção: `no_cot_with_scale` (sem CoT + detecção de balança na foto, sem TACO) + `gemini-3.1-flash-lite`. Esse arm não era estatisticamente diferente do baseline neste benchmark (t=0.23).
- **Revisão adicional (mesmo dia):** uma revisão externa de prompt engineering sugeriu que, como a saída estruturada em JSON do Gemini não permite ao modelo "pensar" silenciosamente antes de gerar um campo (a geração de tokens É o raciocínio), pedir raciocínio multi-etapa só via instrução em prosa — sem um campo de schema para externalizá-lo — pode explicar por que os prompts estilo CoT pioravam a acurácia. Testado como novo arm (`no_cot_with_scale_reasoning`): adiciona um campo `raciocinio_volumetrico` declarado **primeiro** no schema (forçando o modelo a gerar esse texto antes de qualquer campo numérico) e aperta a faixa de incerteza quando a balança é confirmada. Resultado: t pareado subiu de 0.23 para **1.43** (ainda não significativo sozinho, mas o 2º melhor entre os 7 arms testados, recuperando quase todo o ganho do `no_cot` que a detecção de balança havia apagado), MAPE caiu de 95.7% para 57.4%, sem piora de latência. Promovido para produção, substituindo a primeira versão.
- Em ambas as versões: nenhuma foto de teste tem balança visível, então o valor real do recurso de leitura de balança não pôde ser totalmente medido aqui — essa parte da decisão de embarcar continua sendo uma aposta de produto, documentada como tal no `README.md`.
- Migração de modelo era necessária independentemente da acurácia: `gemini-2.5-flash-lite` já retorna HTTP 404 para chaves de API novas hoje, antes mesmo do desligamento anunciado (2026-10-16).
- Resultados completos, tabelas (copiadas verbatim de `benchmark_results/report.md`) e citações da literatura documentados na seção "Meal estimation accuracy" do `README.md`, incluindo onde os resultados contrariaram a literatura citada (direção do efeito de chain-of-thought; valor do grounding tipo RAG) e uma seção nova explicando por que o campo de raciocínio estruturado é um mecanismo diferente dos prompts CoT rejeitados.
- `flutter test`: 49/49 passando. `flutter analyze`: 78 issues, igual ao baseline, zero novos. Smoke test manual completo (onboarding → câmera/galeria → chamada Gemini → tela de confirmação → salvar) feito subindo a imagem devcontainer `gema-dev` diretamente via Docker (`--device=/dev/kvm`) com uma foto real do Nutrition5k — pipeline `provisional → processing → done` confirmado (na primeira versão; a troca de prompt seguinte não altera esse fluxo).
- Revisão de branch completa (subagente dedicado): 0 Critical, 2 Important (corrigidos antes do PR: asset TACO não utilizado removido de `pubspec.yaml` — estava embarcado em todo APK sem uso e com licença da base não confirmada; teste de regressão adicionado travando a wiring de produção contra reversão silenciosa), 6 Minor triados como dívida técnica aceita (ver `.superpowers/sdd/progress.md` na branch para detalhe por item).
- **Pendência antes do merge:** a branch precisa de rebase sobre a `main` atual, que ganhou bumps do Dependabot e a correção da PR #15 desde que essa branch foi criada. Recomendado squash-merge ao mesclar — a branch ainda carrega seus próprios commits de spec/plano (`docs/superpowers/specs/2026-07-19-kcal-accuracy-and-model-design.md`, `docs/superpowers/plans/2026-07-19-kcal-accuracy-and-model-plan.md`), e squash evita que eles voltem ao histórico permanente da `main`, sem precisar de cirurgia manual de histórico.

**Itens #3 (UX do fluxo de câmera) e #4 (flash da câmera interna)** — unificados e implementados juntos.
- PR: https://github.com/LucasJLBraz/gema/pull/21 (branch `unify-camera-context-and-flash`), squash-merged em 2026-07-21.
- Captura via câmera agora passa pelo mesmo bottom sheet pós-captura da galeria (`MealContextSheet`, renomeado a partir do antigo `_GalleryContextSheet`) — elimina a assimetria descrita no achado original; o `TextField` fixo no topo da câmera foi removido.
- Corrigido de quebra um bug latente: o botão "Pular" do sheet mantinha silenciosamente qualquer texto já digitado em vez de descartá-lo.
- Flash de dois estados (desligado/tocha) adicionado ao `CameraController` com botão dedicado na UI da câmera.
- Foto capturada/selecionada agora fica congelada na tela (em vez do preview ao vivo da câmera) entre a captura e a confirmação do contexto.
- `flutter test`: 55/55 passando (inclui `test/widget/capture_screen_test.dart`, novo). `flutter analyze`: sem issues novos vs. baseline da `main`.
- Smoke test manual em dispositivo físico (Samsung SM-S926B, via adb wireless): captura → sheet de contexto monta (prompt de permissão de microfone confirma) → chega à tela de confirmação; toggle de flash liga/desliga a tocha física com o ícone refletindo o estado. Fluxo de seleção via galeria não foi reexercitado manualmente nesta rodada (mesmo caminho de código da câmera, já coberto por testes automatizados e revisão de código).
- Achado colateral durante o smoke test, já registrado à parte: texto de exemplo da chave de API no onboarding está desatualizado (item #8 abaixo).

## Fila — próximos itens a brainstormar

### 7. Duplicar refeição recorrente a partir do Quick Add
- **Achado:** refeições repetidas (ex.: mesmo café da manhã quase todo dia) hoje pagam o custo total do fluxo de captura + pipeline de IA mesmo quando o resultado já é conhecido. Design já aprovado: `docs/superpowers/specs/2026-07-21-duplicate-recurring-meal-design.md` — cobre provider de sugestões por similaridade fuzzy (Jaccard sobre tokens, janela de ±90 min / 14 dias), método `duplicateMeal` em `MealQueueNotifier` (nunca copia foto, sempre cria `MealComponent`s novos), UI de até 3 cards no Quick Add com desfazer via snackbar.
- **Status:** spec aprovada, **plano de implementação ainda não escrito**.
- **Próximo passo:** indicado pelo usuário como próximo item a atacar — seguir para `superpowers:writing-plans` a partir da spec existente, depois execução.

### 5. Nutrientes adicionais (sódio, tipos de gordura)
- **Achado:** não investigado a fundo ainda — envolve expansão de schema Isar (`Meal`/`MealComponent`, requer `build_runner`) e do schema de resposta do Gemini (`_responseSchema` em `gemini_service.dart`).
- **Próximo passo:** baixa urgência — esperar o V1 estabilizar (CLAUDE.md já marca edição de macro por macro como "deferred to V2"; sódio/gorduras provavelmente segue o mesmo racional).

### 6. Integração com Galaxy Watch 8 (Wear OS)
- **Achado:** não investigado — é pesquisa de viabilidade pura (complicação Wear OS vs. app companheiro, entrada por voz/texto).
- **Próximo passo:** pode rodar em paralelo a qualquer momento como um spike de pesquisa, já que não bloqueia nem depende de nenhum outro item.

### 8. Onboarding com texto desatualizado sobre a chave da API Gemini (achado em 2026-07-21)
- **Achado:** durante o smoke test manual do item #3 (ver spec `2026-07-21-unify-camera-context-flash-design.md`), a tela final do onboarding (`lib/features/onboarding/screens/onboarding_screen.dart`, em torno das linhas 536/558) mostra um texto de exemplo dizendo que a chave "começa com AIza" — o usuário confirmou que chaves novas do Google AI Studio hoje começam com `AQ`, não `AIza`. O código em si **não valida o formato da chave** (nenhum `startsWith`/regex encontrado — confirmado por investigação de código), então chaves `AQ` são aceitas normalmente; o texto é só um exemplo desatualizado que pode confundir o usuário. Também vale checar se os números de rate limit exibidos na mesma tela ("15 requisições/minuto e 1.000/dia") ainda batem com o que está documentado em `CLAUDE.md` (≤15 RPM / ~1.500 RPD) e com o limite real atual do tier grátis do `gemini-3.1-flash-lite`.
- **Nota:** o erro "Erro: verifique os dados e tente novamente" que apareceu no primeiro teste não era sobre a chave — é um `catch` genérico em `_finish()` (mesmo arquivo) que também dispara se os campos de peso/altura/idade da etapa 1 estiverem vazios. Não investigado se vale a pena separar essa mensagem de erro por campo — anotado aqui só como observação, não como parte deste item.
- **Próximo passo:** baixa urgência, mas rápido de resolver — atualizar o texto de exemplo e os números de rate limit no onboarding. Brainstorm dedicado opcional dado o tamanho pequeno do escopo.

## Como retomar

Para qualquer item acima, o fluxo é o mesmo já seguido para os bugs #5/#6: invocar `superpowers:brainstorming` apontando para a seção correspondente deste documento, decompor em perguntas clarificadoras, propor abordagens, produzir spec em `docs/superpowers/specs/`, depois plano em `docs/superpowers/plans/`, depois execução (inline ou subagent-driven).
