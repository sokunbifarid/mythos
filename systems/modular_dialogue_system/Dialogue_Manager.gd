extends Node

var dialogue_data = {}

func _ready():
	# Automatically called when the node enters the scene tree. Loads the dialogue JSON file.
	load_dialogue_file("res://dialogue/dialogue.json")

func load_dialogue_file(path: String):
	# Opens and parses the dialogue JSON file into a dictionary.
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var text = file.get_as_text()
		var parsed = JSON.parse_string(text)
		if parsed is Dictionary:
			dialogue_data = parsed
		else:
			push_error("Dialogue JSON is not valid.")
	else:
		push_error("Could not load dialogue file at: " + path)

func get_dialogue(npc_name: String, stage: int) -> Array:
	# Returns the dialogue lines for a given NPC and story stage (chapter).
	if npc_name in dialogue_data:
		var npc_dialogue = dialogue_data[npc_name]
		if str(stage) in npc_dialogue:
			print("Loaded dialogue for", npc_name, "stage", stage)
			return npc_dialogue[str(stage)]
	print("No dialogue found for", npc_name, "stage", stage)
	return []

