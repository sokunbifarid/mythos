# Godot Dialogue System (Used in *Evenrift*)

This is a lightweight, modular dialogue system built in Godot 4, created for my narrative-driven RPG *Evenrift*. It's designed to help solo devs and small teams get started with NPC dialogue quickly.

## 📂 Included Files

- `textbox.tscn` – The UI scene for the dialogue textbox.
- `textbox.gd` – Controls when to show/hide text and process input.
- `Dialogue_Manager.gd` – Loads dialogue from a JSON file and serves lines to the textbox.
- `sample_dialogue.json` – Example structure to use for your own NPC dialogue.
- `npc.gd` – Script for an interactable NPC that triggers dialogue when approached.
- `npc.tscn` – A pre-configured NPC scene ready to be dropped into your level.
- `README.txt` – (This file) Setup instructions and notes.

## 🧠 Requirements

- Basic understanding of **Godot 4** and **GDScript**
- Ability to modify scenes and code to fit your own game

## 🚀 Setup

1. Copy the included files into your Godot project.
2. Set `Dialogue_Manager.gd` as an **Autoload** in your project settings (Project > Project Settings > Autoload).
3. Customize the `textbox.tscn` layout as needed (fonts, colors, borders).
4. Add `textbox.tscn` as a child node to any scene where you want dialogue to appear.
5. Use `npc_example.tscn` as a ready-to-go NPC scene, or create your own and attach `npc_example.gd` to it.
6. Create an `Area2D` or detection zone to detect when the player is near.
7. Use `Dialogue_Manager.get_dialogue(npc_name, stage)` to retrieve dialogue from your JSON files.
8. Queue lines of dialogue using `textbox.queue_text(line)` and call `display_text()` to begin.

## 🗂️ Dialogue JSON Format

Here's an example of how your JSON should look:

```json
{{
  "npc_name": {{
    "1": [
      "Hello, traveler.",
      "It's dangerous to go alone."
    ],
    "2": [
      "You've grown stronger since we last met."
    ]
  }}
}}
```

- `"npc_name"`: Name of the NPC (must match what you pass to the dialogue manager).
- `"1"`, `"2"`: Story stage or chapter ID.
- Each array contains a list of dialogue lines.

## 💬 Notes

- The system uses a basic input action called `"chat"`. Be sure to define this in your Input Map.
- This is not plug-and-play for all games. You'll need to hook up the system to your own scene logic (like using `Area2D` or character detection).
- The code is clean, commented, and beginner-friendly.

## ☕ Support

If this helped you, consider donating to support my solo dev journey. Thanks!
