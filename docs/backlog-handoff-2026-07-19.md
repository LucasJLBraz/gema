# GEMA — Backlog handoff (2026-07-19)

Levantamento inicial de 8 itens do backlog, com leitura de PM (impacto × esforço) e achados técnicos concretos no código. Este documento é o ponto de partida para retomar cada item pendente — um de cada vez, via `superpowers:brainstorming`.

**Nota de processo (fixada em 2026-07-20):** specs e planos (`docs/superpowers/specs/`, `docs/superpowers/plans/`) são artefatos de trabalho do fluxo Superpowers, não documentação do produto. Depois que um item é implementado, o commit de spec/plano correspondente é removido do histórico da `main` (via rebase, antes do PR) — este arquivo é que registra o resultado. Enquanto um item está em andamento (spec/plano prontos, implementação não iniciada ou em curso), os arquivos de spec/plano ficam na `main` normalmente como referência de trabalho.

## Concluído

**Bugs #5 (inserção sem confirmação) e #6 (paste trava onboarding)** — corrigidos.
- PR: https://github.com/LucasJLBraz/gema/pull/15 (branch `fix-confirm-onboarding-bugs`)
- `MealQueueNotifier.deleteMeal` agora também apaga o arquivo de foto (best-effort); `ConfirmMealScreen` chama esse método a partir do botão X e do gesto de voltar (via `PopScope`) antes de navegar.
- Botão "Continuar"/"Começar" do onboarding envolvido em `ListenableBuilder` (merge dos 5 controllers) — reage a paste/autofill, não só a digitação.
- `flutter test`: 34/34 passando. Falta o smoke test manual em dispositivo físico (pendente configuração de `adb`).

## Em andamento — spec + plano prontos, implementação pendente

**Itens #1 (acurácia de KCAL) + #2 (migração de modelo Gemini)** — investigados e desenhados juntos, como recomendado abaixo.
- Spec: `docs/superpowers/specs/2026-07-19-kcal-accuracy-and-model-design.md`
- Plano: `docs/superpowers/plans/2026-07-19-kcal-accuracy-and-model-plan.md`
- Achados originais que motivaram a investigação, para contexto:
  - **KCAL:** o prompt em `lib/core/gemini/gemini_service.dart` (`_systemPrompt`) estimava massa/energia inteiramente por raciocínio visual do LLM, sem nenhuma base de dados nutricional injetada.
  - **Modelo:** fixo em `gemini-2.5-flash-lite` (`lib/core/gemini/gemini_service.dart:11`) — a spec já confirma data de desativação (2026-10-16) e recomenda sucessor.

## Fila — próximos itens a brainstormar

### 3. UX do fluxo de câmera (contexto antes do envio)
- **Achado:** a assimetria é real e está no código — o fluxo de galeria (`lib/features/meals/screens/capture_screen.dart`, `_pickFromGallery` → `_GalleryContextSheet`) força um bottom sheet pedindo contexto (texto + STT) antes de salvar; o fluxo de câmera nativa só oferece um `TextField` opcional fixo no topo da tela (fácil de ignorar durante o enquadramento), e o obturador salva e navega imediatamente.
- **Próximo passo:** brainstorm de UX dedicado — decidir se a câmera deve ganhar o mesmo bottom sheet pós-captura da galeria (unificação), ou uma solução diferente que mantenha a fricção baixa mas capture contexto.

### 4. Flash da câmera interna
- **Achado:** `CameraController` (`capture_screen.dart:50-54`) não seta nenhum `flashMode`; não há botão de flash na UI. Feature isolada, sem dependência de outros itens.
- **Próximo passo:** pode ser bundlado com o brainstorm do item #3 (mesma tela, mesmo componente), já que é uma adição trivial ao mesmo arquivo.

### 5. Nutrientes adicionais (sódio, tipos de gordura)
- **Achado:** não investigado a fundo ainda — envolve expansão de schema Isar (`Meal`/`MealComponent`, requer `build_runner`) e do schema de resposta do Gemini (`_responseSchema` em `gemini_service.dart`).
- **Próximo passo:** baixa urgência — esperar o V1 estabilizar (CLAUDE.md já marca edição de macro por macro como "deferred to V2"; sódio/gorduras provavelmente segue o mesmo racional).

### 6. Integração com Galaxy Watch 8 (Wear OS)
- **Achado:** não investigado — é pesquisa de viabilidade pura (complicação Wear OS vs. app companheiro, entrada por voz/texto).
- **Próximo passo:** pode rodar em paralelo a qualquer momento como um spike de pesquisa, já que não bloqueia nem depende de nenhum outro item.

## Como retomar

Para qualquer item acima, o fluxo é o mesmo já seguido para os bugs #5/#6: invocar `superpowers:brainstorming` apontando para a seção correspondente deste documento, decompor em perguntas clarificadoras, propor abordagens, produzir spec em `docs/superpowers/specs/`, depois plano em `docs/superpowers/plans/`, depois execução (inline ou subagent-driven).
