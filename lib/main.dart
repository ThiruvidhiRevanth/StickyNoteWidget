import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:window_manager/window_manager.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyWindowListener extends WindowListener {
  @override
  void onWindowMinimize() async {
    // Prevent minimize: immediately restore
    await windowManager.restore();
  }


  void onWindowHide() async {
    // Prevent hiding: immediately show
    await windowManager.show();
  }
}

 
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  // Initialize window manager for desktop platforms
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    await windowManager.ensureInitialized();
    const windowOptions = WindowOptions(
      size: Size(420, 420),
      backgroundColor: Colors.transparent,
      skipTaskbar: true,
      titleBarStyle: TitleBarStyle.hidden,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setAsFrameless();
      await windowManager.show();
      await windowManager.focus();
         await windowManager.setMinimizable(false); // Disable minimize
    await windowManager.setResizable(false); 
    });
    windowManager.addListener(MyWindowListener());
runApp(const StickyNoteApp());
  }


 

  // Handle bitsdojo_window for desktop
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    doWhenWindowReady(() {
      const initialSize = Size(420, 420);
      appWindow.size = initialSize;
      appWindow.alignment = Alignment.topRight;
      appWindow.show();
    });
  }
}

class StickyNoteApp extends StatelessWidget {
  const StickyNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StickyNote(),
    );
  }
}

class StickyNote extends StatefulWidget {
  const StickyNote({super.key});

  @override
  State<StickyNote> createState() => _StickyNoteState();
}

class _StickyNoteState extends State<StickyNote> {
  List<quill.QuillController> _controllers = [];
  List<Color> _noteColors = [];
  int _currentIndex = 0;
  PageController _pageController = PageController();
  Timer? _alarmTimer;
  bool _isAlarmActive = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  final List<Color> _availableColors = [
    Colors.yellow.shade200, // Default yellow
    Colors.lightBlue.shade100,
    Colors.pink.shade100,
    Colors.green.shade100,
    Colors.orange.shade100,
    Colors.purple.shade100,
  ];

  final List<String> _placeholderSuggestions = [
    "Jot down your thoughts...",
    "Add a to-do list...",
    "Write a quick reminder...",
    "Note an idea or task...",
    "Type your notes here...",
  ];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final noteList = prefs.getStringList('all_notes') ?? [];
    final colorList = prefs.getStringList('note_colors') ?? [];

    setState(() {
      _controllers = noteList.isNotEmpty
          ? noteList.map((noteJson) {
              final doc = quill.Document.fromJson(jsonDecode(noteJson));
              return quill.QuillController(
                document: doc,
                selection: const TextSelection.collapsed(offset: 0),
              );
            }).toList()
          : [quill.QuillController.basic()];

      _noteColors = colorList.isNotEmpty
          ? colorList.map((colorStr) => Color(int.parse(colorStr))).toList()
          : [_availableColors[0]];

      while (_noteColors.length < _controllers.length) {
        _noteColors.add(_availableColors[0]);
      }

      _currentIndex = 0;
    });
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final noteList = _controllers.map((controller) {
      return jsonEncode(controller.document.toDelta().toJson());
    }).toList();
    await prefs.setStringList('all_notes', noteList);
    await prefs.setStringList(
      'note_colors',
      _noteColors.map((color) => color.value.toString()).toList(),
    );
  }

  Future<void> setAlarmTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      DateTime now = DateTime.now();
      DateTime alarmTime = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );
      if (alarmTime.isBefore(now)) {
        alarmTime = alarmTime.add(const Duration(days: 1));
      }
      final Duration delay = alarmTime.difference(now);
      _alarmTimer?.cancel();
      _alarmTimer = Timer(delay, () async {
        if (!mounted) return;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          setState(() {
            _isAlarmActive = true;
          });
          await windowManager.setAlwaysOnTop(true);
          await windowManager.show();
          await windowManager.focus();
          if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
            appWindow.alignment = Alignment.center;
          }
          try {
            await _audioPlayer.play(AssetSource('alarm.mp3'));
          } catch (e) {
            print('Audio playback error: $e');
          }
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Alarm set for ${picked.format(context)}')),
      );
    }
  }

  void stopAlarm() {
    _alarmTimer?.cancel();
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _audioPlayer.stop();
      setState(() {
        _isAlarmActive = false;
      });
      await windowManager.setAlwaysOnTop(false);
      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        appWindow.alignment = Alignment.topRight;
      }
    });
  }

  void _addNewNote() {
    setState(() {
      _controllers.add(quill.QuillController.basic());
      _noteColors.add(_availableColors[Random().nextInt(_availableColors.length)]);
      _currentIndex = _controllers.length - 1;
      _pageController.jumpToPage(_currentIndex);
    });
    _saveNotes();
  }

  void _deleteCurrentNote() {
    if (_controllers.length > 1) {
      setState(() {
        _controllers.removeAt(_currentIndex);
        _noteColors.removeAt(_currentIndex);
        _currentIndex = (_currentIndex - 1).clamp(0, _controllers.length - 1);
        _pageController.jumpToPage(_currentIndex);
      });
      _saveNotes();
    }
  }

  void _goToPreviousNote() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _pageController.jumpToPage(_currentIndex);
      });
    }
  }

  void _goToNextNote() {
    if (_currentIndex < _controllers.length - 1) {
      setState(() {
        _currentIndex++;
        _pageController.jumpToPage(_currentIndex);
      });
    }
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Sticky Note Widget'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('A simple widget to create and manage sticky notes with alarms and color customization.'),
            SizedBox(height: 8),
            Text('Developed with Flutter'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _saveNotes();
    for (var controller in _controllers) {
      controller.dispose();
    }
    _alarmTimer?.cancel();
    _audioPlayer.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controllers.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: MoveWindow(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: _noteColors[_currentIndex],
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(5, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              quill.QuillSimpleToolbar(
                configurations: quill.QuillSimpleToolbarConfigurations(
                  color: _noteColors[_currentIndex],
                  controller: _controllers[_currentIndex],
                  customButtons: [
                    quill.QuillToolbarCustomButtonOptions(
                      tooltip: 'Add New Note',
                      icon: const Icon(Icons.add),
                      onPressed: _addNewNote,
                    ),
                    quill.QuillToolbarCustomButtonOptions(
                      tooltip: 'Delete This Note',
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: _deleteCurrentNote,
                    ),
                    quill.QuillToolbarCustomButtonOptions(
                      tooltip: 'Save Notes',
                      icon: const Icon(Icons.check),
                      onPressed: _saveNotes,
                    ),
                    quill.QuillToolbarCustomButtonOptions(
                      tooltip: 'Close',
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _saveNotes();
                        exit(0);
                      },
                    ),
                    quill.QuillToolbarCustomButtonOptions(
                      icon: const Icon(Icons.alarm),
                      tooltip: 'Set Alarm Time',
                      onPressed: () => setAlarmTime(context),
                    ),
                    if (_isAlarmActive)
                      quill.QuillToolbarCustomButtonOptions(
                        icon: const Icon(Icons.stop_circle, color: Colors.red),
                        tooltip: 'Stop Alarm',
                        onPressed: stopAlarm,
                      ),
                    quill.QuillToolbarCustomButtonOptions(
                      icon: const Icon(Icons.color_lens),
                      tooltip: 'Pick Note Color',
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (_) => SizedBox(
                            height: 80,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: _availableColors.map((color) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                    setState(() {
                                      _noteColors[_currentIndex] = color;
                                    });
                                    _saveNotes();
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.all(8),
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                      border: Border.all(width: 2, color: Colors.black),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      },
                    ),
                    quill.QuillToolbarCustomButtonOptions(
                      icon: const Icon(Icons.info),
                      tooltip: 'About',
                      onPressed: () => _showAboutDialog(context),
                    ),
                  ],
                  showFontFamily: false,
                  showFontSize: false,
                  multiRowsDisplay: false,
                  showDirection: false,
                  showAlignmentButtons: false,
                  showColorButton: false,
                  showCodeBlock: false,
                  showListCheck: true,
                  showHeaderStyle: false,
                  showQuote: false,
                  showIndent: false,
                  showBackgroundColorButton: false,
                  showSearchButton: false,
                  showClearFormat: false,
                  showLink: false,
                  showUndo: false,
                  showRedo: false,
                  showJustifyAlignment: false,
                  showUnderLineButton: true,
                  showStrikeThrough: true,
                  showInlineCode: false,
                  showSubscript: false,
                  showSuperscript: false,
                  showClipboardCopy: false,
                  showClipboardPaste: false,
                  showClipboardCut: false,
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemCount: _controllers.length,
                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.all(8),
                      child: quill.QuillEditor.basic(
                        controller: _controllers[index],
                        configurations: quill.QuillEditorConfigurations(
                          placeholder: _placeholderSuggestions[
                              Random().nextInt(_placeholderSuggestions.length)],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_left_rounded),
                    color: _currentIndex > 0 ? Colors.black : Colors.grey,
                    onPressed: _currentIndex > 0 ? _goToPreviousNote : null,
                    tooltip: 'Previous Note',
                  ),
                  ...List.generate(_controllers.length, (index) {
                    final isSelected = index == _currentIndex;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0.5),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color.fromARGB(140, 0, 0, 0) : Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    );
                  }),
                  IconButton(
                    icon: const Icon(Icons.arrow_right_rounded),
                    color: _currentIndex < _controllers.length - 1 ? Colors.black : Colors.grey,
                    onPressed: _currentIndex < _controllers.length - 1 ? _goToNextNote : null,
                    tooltip: 'Next Note',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
