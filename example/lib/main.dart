import 'dart:typed_data';
import 'package:ares_edge/ares_edge.dart';
import 'package:flutter/material.dart';
import 'workbench/performance_workbench.dart';

// Set this in developer source/build configuration, never through an end-user UI.
// No licence key is committed; omitting the define tests the process trial.
const _licence = String.fromEnvironment('ARES_EDGE_LICENCE');

void main() => runApp(
  MaterialApp(
    title: 'AresEdge example',
    theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
    home: const ExampleHome(),
  ),
);

/// Demonstrates both public presentation modes and the editor-skip flag.
class ExampleHome extends StatefulWidget {
  const ExampleHome({super.key});
  @override
  State<ExampleHome> createState() => _ExampleHomeState();
}

class _ExampleHomeState extends State<ExampleHome> {
  bool _edit = true;
  Uint8List? _image;
  String? _error;
  Future<void> _scan({required bool embedded}) async {
    try {
      final bytes = embedded
          ? await Navigator.of(context).push<Uint8List>(
              MaterialPageRoute(builder: (_) => const CustomCamera()),
            )
          : await AresEdgeScreen.open(
              context,
              licenceKey: _licence,
              editAfterCapture: _edit,
            );
      if (mounted) {
        setState(() {
          _image = bytes;
          _error = null;
        });
      }
    } on Object catch (error) {
      if (mounted) setState(() => _error = error.toString());
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('AresEdge example')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Choose the ready-made scanner or supply your own controls.',
        ),
        SwitchListTile(
          title: const Text('Edit after capture'),
          value: _edit,
          subtitle: const Text(
            'Ready-made scanner: crop and edit, or return the original.',
          ),
          onChanged: (value) => setState(() => _edit = value),
        ),
        FilledButton(
          onPressed: () => _scan(embedded: false),
          child: const Text('Open AresEdgeScreen'),
        ),
        OutlinedButton(
          onPressed: () => _scan(embedded: true),
          child: const Text('Open custom AresEdgeEmbedded'),
        ),
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (_) => const PerformanceWorkbench(licenceKey: _licence),
            ),
          ),
          icon: const Icon(Icons.speed),
          label: const Text('Open performance workbench'),
        ),
        if (_error != null) Text(_error!),
        if (_image case final image?) ...[
          Text('Returned ${image.lengthInBytes} compressed bytes'),
          Image.memory(image),
        ],
      ],
    ),
  );
}

/// SDK camera/overlay underneath host-owned capture and torch buttons.
class CustomCamera extends StatefulWidget {
  const CustomCamera({super.key});
  @override
  State<CustomCamera> createState() => _CustomCameraState();
}

class _CustomCameraState extends State<CustomCamera> {
  final _camera = AresEdgeController();
  String? _error;
  Future<void> _command(Future<void> Function() command) async {
    try {
      await command();
      if (mounted) setState(() {});
    } on Object catch (error) {
      if (mounted) setState(() => _error = error.toString());
    }
  }

  @override
  void dispose() {
    _camera.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Your custom camera')),
    body: Stack(
      children: [
        Positioned.fill(
          child: AresEdgeEmbedded(
            controller: _camera,
            licenceKey: _licence,
            options: const AresEdgeOptions(overlayColor: Colors.orange),
            onCapture: (image) {
              if (mounted) Navigator.of(context).pop(image.bytes);
            },
            onLicenceRequired: () {
              if (mounted) Navigator.of(context).pop();
            },
            onError: (error) {
              if (mounted) setState(() => _error = error);
            },
          ),
        ),
        if (_error != null)
          Center(
            child: Text(_error!, style: const TextStyle(color: Colors.white)),
          ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton.filled(
                    tooltip: 'Toggle flashlight',
                    onPressed: () => _command(_camera.toggleFlash),
                    icon: Icon(
                      _camera.flashEnabled ? Icons.flash_on : Icons.flash_off,
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => _command(_camera.capture),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Capture'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
