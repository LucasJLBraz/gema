import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../core/theme/app_theme.dart';
import '../models/meal.dart';
import '../providers/meal_provider.dart';

class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({super.key});

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen> {
  CameraController? _controller;
  bool _initializing = true;
  bool _capturing = false;
  String? _error;
  final _noteCtrl = TextEditingController();
  bool _flashOn = false;
  String? _capturedPhotoPath;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _error = 'Câmera não disponível.';
          _initializing = false;
        });
        return;
      }
      _controller = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _controller!.initialize();
      if (mounted) setState(() => _initializing = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erro ao iniciar câmera: $e';
          _initializing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _capturing) {
      return;
    }
    setState(() => _capturing = true);
    try {
      final xFile = await _controller!.takePicture();
      await _handleCapturedPhoto(xFile.path);
    } catch (e) {
      if (mounted) setState(() => _error = 'Erro ao capturar: $e');
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final next = !_flashOn;
    try {
      await _controller!.setFlashMode(next ? FlashMode.torch : FlashMode.off);
      if (mounted) setState(() => _flashOn = next);
    } catch (e) {
      if (mounted) setState(() => _error = 'Erro ao ajustar o flash: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (xFile == null || !mounted) return;
    await _handleCapturedPhoto(xFile.path);
  }

  // Shared by both the camera shutter and the gallery pick, so the two
  // paths always ask for context the same way.
  Future<void> _handleCapturedPhoto(String sourcePath) async {
    // Freeze the last-captured/picked photo in place of the live camera
    // preview so the user can see what they're describing.
    setState(() => _capturedPhotoPath = sourcePath);
    final note = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MealContextSheet(existingNote: _noteCtrl.text),
    );
    if (!mounted) return;
    if (note != null && note.isNotEmpty) _noteCtrl.text = note;
    await _saveMealFromPath(sourcePath);
  }

  Future<void> _saveMealFromPath(String sourcePath) async {
    final dir = await getApplicationDocumentsDirectory();
    final destPath =
        '${dir.path}/meal_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await File(sourcePath).copy(destPath);

    final mealId = await ref
        .read(mealQueueNotifierProvider.notifier)
        .createMeal(
          source: MealSource.aiPhoto,
          photoPath: destPath,
          userNote: _noteCtrl.text,
        );

    if (mounted) context.pushReplacement('/confirm?mealId=$mealId');
  }

  @override
  Widget build(BuildContext context) {
    const primary = GemaColors.darkPrimary;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            if (_initializing)
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            else if (_error != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.pop(),
                        child: const Text('Voltar'),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              // Camera preview — invert sensor ratio for portrait orientation.
              // Once a photo has been captured/picked, show it frozen in
              // place of the live feed so the user can see what they're
              // describing in the context sheet.
              Center(
                child: _capturedPhotoPath != null
                    ? Image.file(
                        File(_capturedPhotoPath!),
                        fit: BoxFit.contain,
                      )
                    : AspectRatio(
                        aspectRatio: 1.0 / _controller!.value.aspectRatio,
                        child: CameraPreview(_controller!),
                      ),
              ),

              // Top bar: back + flash toggle
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                    _CircleBtn(
                      icon: _flashOn ? Icons.flash_on : Icons.flash_off,
                      size: 44,
                      onTap: _toggleFlash,
                      tooltip: _flashOn ? 'Desligar flash' : 'Ligar flash',
                    ),
                  ],
                ),
              ),

              // Bottom controls: gallery + capture button
              Positioned(
                bottom: 32,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Gallery button
                    _CircleBtn(
                      icon: Icons.photo_library_outlined,
                      size: 52,
                      onTap: _pickFromGallery,
                      tooltip: 'Galeria',
                    ),

                    // Shutter
                    GestureDetector(
                      onTap: _capture,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: primary, width: 4),
                        ),
                        child: _capturing
                            ? const Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                ),
                              )
                            : const Icon(
                                Icons.camera_alt,
                                size: 32,
                                color: Colors.black,
                              ),
                      ),
                    ),

                    // Placeholder to balance layout
                    const SizedBox(width: 52),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  const _CircleBtn({
    required this.icon,
    required this.size,
    required this.onTap,
    required this.tooltip,
  });
  final IconData icon;
  final double size;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: tooltip,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withValues(alpha: 0.5),
            border: Border.all(color: Colors.white54, width: 1.5),
          ),
          child: Icon(icon, color: Colors.white, size: size * 0.45),
        ),
      ),
    );
  }
}

class MealContextSheet extends StatefulWidget {
  const MealContextSheet({super.key, required this.existingNote});
  final String existingNote;

  @override
  State<MealContextSheet> createState() => _MealContextSheetState();
}

class _MealContextSheetState extends State<MealContextSheet> {
  late final TextEditingController _ctrl;
  final _stt = SpeechToText();
  bool _sttAvailable = false;
  bool _listening = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.existingNote);
    _stt.initialize().then((ok) {
      if (mounted) setState(() => _sttAvailable = ok);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _stt.stop();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (!_sttAvailable) return;
    if (_listening) {
      await _stt.stop();
      setState(() => _listening = false);
    } else {
      setState(() => _listening = true);
      await _stt.listen(
        onResult: (r) {
          _ctrl.text = r.recognizedWords;
          _ctrl.selection = TextSelection.collapsed(offset: _ctrl.text.length);
          if (r.finalResult) setState(() => _listening = false);
        },
        listenOptions: SpeechListenOptions(
          listenFor: const Duration(minutes: 2),
          pauseFor: const Duration(seconds: 30),
          localeId: 'pt_BR',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Adicionar contexto',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Descreva a refeição para melhorar a estimativa (opcional)',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _ctrl,
            autofocus: true,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Ex: frango grelhado com arroz, porção média',
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.08),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              suffixIcon: _sttAvailable
                  ? IconButton(
                      icon: Icon(
                        _listening ? Icons.mic : Icons.mic_none,
                        color: _listening ? Colors.redAccent : Colors.white54,
                      ),
                      onPressed: _toggleListening,
                    )
                  : null,
            ),
          ),
          if (_listening) ...[
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.mic, color: Colors.redAccent, size: 14),
                SizedBox(width: 6),
                Text(
                  'Ouvindo… toque no mic para parar',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Pular'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(_ctrl.text),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Adicionar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
