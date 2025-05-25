# StickyNoteWidget

A simple, beautiful, and powerful sticky notes application for Windows, macOS desktops, built using Flutter. StickyNoteWidget lets you jot down thoughts, create multiple color-coded notes, set alarms, and enjoy a distraction-free, frameless window experience.

---

## 🚀 Download

**[⬇️ Latest Release (Windows, macOS)](https://github.com/ThiruvidhiRevanth/StickyNoteWidget/releases/tag/main)**

Go to the [Releases page](https://github.com/ThiruvidhiRevanth/StickyNoteWidget/releases/tag/main) and download the installer or zip for your platform.

---

## Features

- **Multi-note support:** Create, switch, and delete multiple notes using the toolbar and navigation arrows.
- **Rich text editing:** Format your notes with bold, italic, underline, checklists, and more, powered by [Flutter Quill](https://pub.dev/packages/flutter_quill).
- **Color customization:** Choose from a palette to color-code your notes for better organization.
- **Alarm functionality:** Set an alarm for any note; the window pops up centered, always on top, and plays a sound until you stop it.
- **Persistent storage:** All notes and their colors are saved automatically with [shared_preferences](https://pub.dev/packages/shared_preferences).
- **Frameless, draggable window:** Modern sticky note UI using [bitsdojo_window](https://pub.dev/packages/bitsdojo_window) and [window_manager](https://pub.dev/packages/window_manager).
- **Always on top when needed:** When an alarm goes off, the window becomes always-on-top and must be dismissed manually.
- **About dialog:** Quick info about the app in the toolbar.
- **Cross-platform:** Works on Windows, macOS, and Linux desktops.

---

## How It Works

- **Window Behavior:**  
  The application cannot be minimized or hidden while running. When an alarm is triggered, the app pops up, becomes always on top, and cannot be dismissed except by pressing the Stop Alarm button.
- **Notes Navigation:**  
  Create as many notes as you want. Navigate between them using the arrow buttons below the note.
- **Rich Editor:**  
  Use the toolbar for checklists, bold, italic, underline, strike-through, and more. Each note has its own formatting.
- **Color Picker:**  
  Click the palette icon to pick a color for the current note.
- **Alarm:**  
  Click the alarm icon, choose a time, and you'll get a popup with sound at that time. Stop the alarm using the stop icon that appears.
- **Persistence:**  
  All your notes and their colors are stored on your computer and loaded automatically next time you launch the app.
- **Exit:**  
  Use the close (X) button in the toolbar to save and quit.

---

## Screenshots

![StickyNoteWidget Screenshot](aasets/ss.png) <!-- Add your screenshot here -->

---

## Getting Started

### Prerequisites

- [Flutter](https://flutter.dev/) (version 3.0+ recommended)
- Desktop platform: Windows, macOS, or Linux

### Installation (From Source)

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/StickyNoteWidget.git
   cd StickyNoteWidget
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run -d windows   # or -d macos / -d linux
   ```

### Pubspec Dependencies

```yaml
window_manager: ^0.4.3
bitsdojo_window: ^0.1.6
shared_preferences: ^2.5.3
audioplayers: ^6.4.0
flutter_quill: ^10.1.1
```

> **Note:** Ensure you have the correct versions for compatibility.

---

## Usage Tips

- **Add a new note:** Click the "Add" (+) icon in the toolbar.
- **Delete a note:** Click the "Delete" (🗑️) icon.
- **Save notes:** Click the "Check" (✔️) icon to force-save, though auto-save is always on.
- **Navigate notes:** Use the left/right arrows below the note.
- **Change note color:** Click the palette (🎨) icon and pick a color.
- **Set alarm:** Click the alarm (⏰) icon and select a time. The app will pop up and play a sound at the selected time.
- **Stop alarm:** When the alarm sounds, a "Stop" button (🛑) appears in the toolbar; click it to stop the alarm and return to normal mode.
- **About:** Click the info (ℹ️) icon for app information.
- **Close app:** Click the close (❌) icon in the toolbar.

---

## Platform Support

- [x] Windows
- [x] macOS

> **Mobile is NOT supported.**

---

## File Structure

- `main.dart`: Main application code and UI logic.
- `assets/alarm.mp3`: Alarm sound file (add your own if not included).
- `pubspec.yaml`: Dependency list.
- `docs/screenshot.png`: Add a screenshot for your README.

---

## Customization

- **Alarm Sound:** Place your desired `alarm.mp3` in the `assets/` folder and add it to `pubspec.yaml`.
- **Window Size:** Edit the `WindowOptions` in `main.dart` to change the default size or position.
- **Colors and Placeholders:** Change `_availableColors` and `_placeholderSuggestions` in the code to fit your style.

---

## Troubleshooting

- If the window does not appear or is not draggable, ensure `bitsdojo_window` and `window_manager` are properly initialized.
- On macOS, some window features may behave differently due to platform limitations.
- If alarm sound does not play, ensure your `assets/alarm.mp3` is present and declared in `pubspec.yaml`.

---

## Contributing

Pull requests are welcome! Please open an issue to discuss your ideas or report bugs.

---

## License

[MIT License](LICENSE)

---

## Credits

- [Flutter Quill](https://pub.dev/packages/flutter_quill)
- [bitsdojo_window](https://pub.dev/packages/bitsdojo_window)
- [window_manager](https://pub.dev/packages/window_manager)
- [audioplayers](https://pub.dev/packages/audioplayers)
- [shared_preferences](https://pub.dev/packages/shared_preferences)

---

Developed with ❤️ using Flutter.
