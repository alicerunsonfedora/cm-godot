# The Costumemaster: Reloaded
**Switch costumes. Solve puzzles. Wake up.**

[![Clickable](https://github.com/alicerunsonfedora/cm-godot/actions/workflows/clickable.yml/badge.svg)](https://github.com/alicerunsonfedora/cm-godot/actions/workflows/clickable.yml) [![Snapcraft](https://github.com/alicerunsonfedora/cm-godot/actions/workflows/snappy.yml/badge.svg)](https://github.com/alicerunsonfedora/cm-godot/actions/workflows/snappy.yml)

Acclaimed software engineer and costume designer Zephyr Emerson wakes up from a long and unexpected nap, realizing she's still got her flash drive costume on. Realizing part of the zipper is broken, she needs to get to her home office in the other room to fix it. But she keeps waking up over and over again, with her surroundings changing. Can you solve the puzzles and make it to the home office in time?

_The Costumemaster: Reloaded_ is a modern reimagining of the original game released on the Mac App Store, redesigned from the ground up. For the first time, you can play across macOS, Linux, and Windows with new visuals and lighting effects, expanded sounds and music, and major improvements to the experience.

- Play nine levels inspired by the original levels in The Costumemaster with more reliable mechanics, along with new ones to challenge you further.
- Work with a keyboard and mouse or plug in an Xbox or Playstation controller for a new seamless experience.
- Switch costumes in a pinch or restart the level easily with a brand new heads-up display that displays information when you need it and hides what you don't.

## Get it now

[![Available on itch.io](.github/itch-badge-color.png)][itch] [![Get it from the Snap Store](https://snapcraft.io/static/images/badges/en/snap-store-black.svg)][snap]

[itch]: https://marquiskurt.itch.io/costumemaster-reloaded
[snap]: https://snapcraft.io/costumemaster-reloaded

## Build from source

### Developer Tools

For this project, you will need the following tools installed:
- Godot 3.3 or better

The following tools are not required to build the game, but are useful for certain variants or other source purposes:

- Xcode 12 or better, for signing certificates and iOS exports
- iconutil, for creating the Mac icon file
- Aseprite, for making the sprite files
- clickable, for making the Ubuntu Touch variant
- snapcraft, for making the Snapcraft variant

### Export the project
Clone the repository code from GitHub via `git clone`, then open the project in Godot. To export the projects, go to **Project > Export**
and then create the export settings for the platforms you want to target.

> Note: You will need to make sure the export configurations also export JSON files in the "Features" tab to ensure the dialogue appears correctly.

### Ubuntu Touch click packages
For instructions on how to build the Ubuntu Touch version of the game, consult the [README file in the clickable subdirectory](./clickable/README.md).

### Snap packages
After exporting the project, create a ZIP file of the exported `linux` directory and name it `cm-reloaded_linux.zip`. Move the ZIP file to the root directory of the project and run `snapcraft`.

## Debugging options

In addition to the debug options present in Godot under the Debug menu (note: requires running from source), there are a couple of keybindings to assist in debugging levels:

| Shortcut | Debugging action                                              |
| :------- | :------------------------------------------------------------ |
| Shift+Q  | Skip the current level, as if the player opened the exit door |
| Shift+F  | Toggle fullbright mode                                        |
| Shift+E  | Toggle animations at the end of levels                        |
| Shift+N  | Show/hide level name in bottom left corner                    |

Debugging mode must be enabled in Settings to access these debugging features. Note that, for the browser version, you may need to hold Ctrl along with the desired keyboard shortcut.

## Localization

The following list demonstrates the following locales the game currently supports:

| Status | Language                    |
| ------ | :-------------------------- |
| ???     | English (default, fallback) |
| ???     | Spanish                     |
| ???     | French                      |

If you'd like to provide translations for your language, please make a pull request with the appropriate changes to the translations files. More information on the format can be found in the [Godot Engine documentation](https://docs.godotengine.org/en/stable/getting_started/workflow/assets/importing_translations.html#translation-format).

## Licensing

The source code is licensed under the Mozilla Public License, v2.0.

The visual and audio assets are licensed as follows:
- Rain ambiance and footsteps: CC Universal 1.0
- Tileset: Proprietary (contact LimeZu for permissions)
- Character sprites, soundtrack, sound effects: Creative Commons Attribution-ShareAlike 4.0 International
- Analog joypad: MIT

## Special Thanks

Thanks to the following amazing people for helping make _The Costumemaster: Reloaded_ possible:

- @andy-k, for supporting me on Ko-fi
- @iAlex11, for providing Spanish translations
- @wimpysworld and @popey, for verifying the Linux Snap package works well
- The UBPorts App Development Telegram group, for assisting and verifying the Ubuntu Touch click packages
- The Godot Engine Team, for developing the Godot engine
- Shinneider, for the analog joystick plugin