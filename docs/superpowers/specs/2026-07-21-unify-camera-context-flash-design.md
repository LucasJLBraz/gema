# Design: unificar contexto pós-captura (câmera/galeria) + flash da câmera interna

**Data:** 2026-07-21
**Status:** aprovado, aguardando plano de implementação
**Escopo:** itens #3 e #4 do backlog GEMA (`docs/backlog-handoff-2026-07-19.md`), bundlados por afetarem o mesmo arquivo/componente (`lib/features/meals/screens/capture_screen.dart`). Prioridade alta — assimetria de UX reportada como impacto real na userbase.

## Contexto

Hoje os dois caminhos de captura de foto tratam contexto (texto + STT) de forma assimétrica:

- **Galeria** (`_pickFromGallery`): força um `showModalBottomSheet` (`_GalleryContextSheet`) pedindo contexto antes de salvar a refeição.
- **Câmera nativa** (`_capture`): só oferece um `TextField` opcional fixo sobreposto no topo da tela (fácil de ignorar durante o enquadramento); o obturador salva e navega imediatamente, sem nunca mostrar o sheet.

Além disso, `CameraController` (`capture_screen.dart:50-54`) não seta nenhum `flashMode` e não existe botão de flash na UI — item #4, isolado, mas na mesma tela.

Durante o brainstorm, identificado um bug pequeno no componente que será reaproveitado com mais peso: em `_GalleryContextSheetState`, os botões "Pular" e "Adicionar" chamam ambos `Navigator.of(context).pop(_ctrl.text)` — ou seja, "Pular" não descarta o texto digitado, apesar do nome sugerir isso.

## Design

### 1. Unificação do fluxo pós-captura

- `_capture()` passa a seguir o mesmo padrão de `_pickFromGallery()`: tira a foto → abre `_GalleryContextSheet` (mesmo widget, texto + STT) → só então chama `_saveMealFromPath`.
- O `TextField` fixo hoje sobreposto no topo da tela de câmera (`capture_screen.dart:214-246`) é removido.
- A lógica de STT duplicada em `_CaptureScreenState` (`_stt`, `_sttAvailable`, `_listening`, `_toggleListening`, inicialização em `_initStt`) é removida da tela principal — passa a existir só dentro de `_GalleryContextSheetState`, que já implementa o mesmo comportamento. Isso elimina duplicação de código, não só a assimetria de UX.
- `_saveMealFromPath` permanece inalterado — continua recebendo o `sourcePath` e usando `_noteCtrl.text` como nota, agora sempre populado (ou não) pelo mesmo sheet em ambos os fluxos.

### 2. Correção do botão "Pular"

- Em `_GalleryContextSheetState`, o botão "Pular" passa a chamar `Navigator.of(context).pop(null)` (descarta o texto digitado); "Adicionar" continua chamando `Navigator.of(context).pop(_ctrl.text)`.
- Em `_pickFromGallery` e no novo fluxo de `_capture`, o tratamento de retorno permanece o mesmo já existente: só sobrescreve `_noteCtrl.text` quando o valor retornado não é nulo/vazio.

### 3. Botão de flash na câmera interna

- Novo estado local em `_CaptureScreenState`: `bool _flashOn = false` (sem persistência entre sessões — cada abertura da tela começa com flash desligado).
- Novo botão (reaproveitando o widget `_CircleBtn` já existente) posicionado no canto superior direito da tela, substituindo o espaço hoje ocupado pelo `TextField` removido. Top bar final: "voltar" (esquerda) e "flash" (direita).
- Toque alterna `_flashOn` e chama `_controller!.setFlashMode(_flashOn ? FlashMode.torch : FlashMode.off)`; ícone alterna entre `Icons.flash_on` e `Icons.flash_off`.
- Comportamento de dois estados (desligado/tocha contínua) — sem modo `auto`, fora de escopo.

### 4. Testes

- **Widget (`test/widget/`):**
  - Capturar foto pela câmera → sheet de contexto aparece → "Pular" → `createMeal` chamado com `userNote` vazio.
  - Capturar foto pela câmera → sheet → "Adicionar" com texto → `createMeal` chamado com o texto correto.
  - Fluxo de galeria não regride: mesmo comportamento de antes, agora com "Pular" corrigido (mesmo teste de descarte de texto aplicado aqui também).
  - Toggle de flash chama `setFlashMode` com o valor esperado (`FlashMode.torch` / `FlashMode.off`) e atualiza o ícone.

## Processo de integração

Diferente do processo padrão do backlog (rebase de spec/plano antes do merge direto — ver nota de processo em `docs/backlog-handoff-2026-07-19.md`), esta mudança **deve** passar por Pull Request antes de entrar na `main`, dado o impacto direto na userbase e o desejo explícito do usuário de revisar antes de integrar. Branch dedicada, PR aberto ao final da implementação, sem squash-merge direto sem revisão.

## Riscos e limitações conhecidas

- Adicionar um passo (sheet) ao fluxo da câmera nativa aumenta levemente a fricção desse caminho especificamente — é a troca deliberada desta unificação (consistência + qualidade de contexto para a IA) em vez de reduzir a fricção da galeria para o nível da câmera.
- `FlashMode.torch` mantém a lanterna ligada continuamente enquanto ativa — pode drenar bateria mais rápido em sessões longas de enquadramento; aceito como comportamento padrão de apps de câmera com essa mesma escolha.
- Remoção da lógica de STT duplicada da tela principal é uma limpeza dentro do escopo (mesmo arquivo, mesmo componente sendo alterado) — não uma refatoração não relacionada.

## Referências

- `docs/backlog-handoff-2026-07-19.md` — itens #3 e #4.
- `lib/features/meals/screens/capture_screen.dart` — arquivo único afetado por toda a mudança.
