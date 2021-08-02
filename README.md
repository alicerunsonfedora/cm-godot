# The Costumemaster: Reloaded
**Switch costumes. Solve puzzles. Wake up.**

Acclaimed software engineer and costume designer Zephyr Emerson wakes up from a long and unexpected nap, realizing she's still got her flash drive costume on. Realizing part of the zipper is broken, she needs to get to her home office in the other room to fix it. But she keeps waking up over and over again, with her surroundings changing. Can you solve the puzzles and make it to the home office in time?

_The Costumemaster: Reloaded_ is a modern reimagining of the original game released on the Mac App Store, redesigned from the ground up. For the first time, you can play across macOS, Linux, and Windows with new visuals and lighting effects, expanded sounds and music, and major improvements to the experience.

- Play nine levels inspired by the original levels in The Costumemaster with more reliable mechanics, along with new ones to challenge you further.
- Work with a keyboard and mouse or plug in an Xbox or Playstation controller for a new seamless experience.
- Switch costumes in a pinch or restart the level easily with a brand new heads-up display that displays information when you need it and hides what you don't.

## Get it now

[**Play on Itch.io &rsaquo;**](https://marquiskurt.itch.io/costumemaster-reloaded)

[![Get it from the Snap Store](https://snapcraft.io/static/images/badges/en/snap-store-black.svg)](https://snapcraft.io/costumemaster-reloaded)

## Build from source

**Requirements**

- Godot 3.3 or better
- (Optional) Xcode 12 or better, for signing certificates and iOS exports
- (Optional) iconutil, for creating the Mac icon file
- (Optional) Aseprite, for making the sprite files
- (Optional) clickable, for making the Ubuntu Touch variant

Clone the repository code from GitHub via `git clone`, then open the project in Godot. To export the projects, edit the signing configurations under **Project &rsaquo; Export...** for each platform you want to distribute to, then click "Export Project" for each project.

For instructions on how to build the Ubuntu Touch version of the game, consult the [README file in the clickable subdirectory](./clickable/README.md).

## Debugging options

In addition to the debug options present in Godot under the Debug menu (note: requires running from source), there are a couple of keybindings to assist in debugging levels:

| Shortcut | Debugging action                                              |
| :------- | :------------------------------------------------------------ |
| Shift+Q  | Skip the current level, as if the player opened the exit door |
| Shift+F  | Toggle fullbright mode                                        |
| Shift+E  | Toggle animations at the end of levels                        |
| Shift+N  | Show/hide level name in bottom left corner                    |

Debugging mode must be enabled in Settings to access these debugging features. Note that, for the browser version, you may need to hold Ctrl along with the desired keyboard shortcut.

## Licensing

The source code is licensed under the Mozilla Public License, v2.0.

The visual and audio assets are licensed as follows:
- Rain ambiance and footsteps: CC Universal 1.0
- Tileset: Proprietary (contact LimeZu for permissions)
- Character sprites, soundtrack, sound effects: Creative Commons Attribution-ShareAlike 4.0 International

## Special Thanks

Thanks to the following amazing people for helping make _The Costumemaster: Reloaded_ possible:

- @andy-k, for supporting me on Ko-fi
- @iAlex11, for providing Spanish translations
- @wimpysworld and @popey, for verifying the Linux Snap package works well
- The UBPorts App Development Telegram group, for assisting and verifying the Ubuntu Touch click packages
- The Godot Engine Team, for developing the Godot engine