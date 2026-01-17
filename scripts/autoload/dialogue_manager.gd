extends Node

var current_npc_name: String = ""
var current_npc_stage_id: int = 0
var current_npc_dialogue_data_next_id: String = "start"
var current_npc_dialogue_last_id: String =  ""

var dialogue_data = {
	"npcs": {
		"Guide Olara": {
			"name": "Guide Olara",
			"face_texture": preload("res://assets/sprites/character/npc/female_adventurer/face.png"),
			"0": {
				"start": {
					"text": "Welcome, traveler, to the lands of Aetheria! It is rare to see a fresh face in these parts. You'll need to find your footing quickly.",
					"options": [],
					"next_id": "controls",
					"event": "none",
					"last_id": "environment"
				},
				"controls": {
					"text": "Use the [W, A, S, D] keys to move your feet. If you see something interesting, press [E] to interact with it.",
					"options": [],
					"next_id": "environment",
					"event": "none",
					"last_id": "environment"
				},
				"environment": {
					"text": "Keep an eye out—some things, like doors or pressure plates, are auto-interactable just by walking over them. Good luck on your journey!",
					"options": [],
					"next_id": "none",
					"event": "completed",
					"last_id": "environment"
				},
			},
			"1":{
				"start": {
					"text": "I hope you like it here.",
					"options": [],
					"next_id": "none",
					"event": "none",
					"last_id": "start"
				}
			}
		},
		"Korgak the Scarred": {
			"name": "Korgak the Scarred",
			"face_texture": preload("res://assets/sprites/character/npc/fox_boy_kamari/face.png"),
			"0": {
				"start": {
					"text": "Grrr! Who are you??",
					"options": [],
					"next_id": "charge",
					"event": "none",
					"last_id": "trigger_battle"
				},
				"charge": {
					"text": "This is a private road. You look like you've got a heavy purse and a weak sword arm.",
					"options": [
						{"id": 0, "text": "I don't want any trouble.", "next_id": "mood" },
						{"id": 1, "text": "Step aside, or I'll move you myself.", "next_id": "trigger_battle" }
					],
					"event": "none",
					"last_id": "trigger_battle"
				},
				"mood": {
					"text": "You are in for it, I am in a bad mood",
					"options": [],
					"next_id": "intimidation",
					"event": "none",
					"last_id": "trigger_battle"
				},
				"intimidation": {
					"text": "Trouble found you anyway. Toss the gold over, or I start cutting.",
					"options": [
						{"id": 0, "text": "Fine, take it. (Pay 50g)", "next_id": "end_robbed" },
						{"id": 1, "text": "Over my dead body!", "next_id": "trigger_battle" }
					],
					"event": "none",
					"last_id": "trigger_battle"
				},
				"trigger_battle": {
					"text": "Hah! I was hoping you'd say that. Draw your steel!",
					"options": [],
					"next_id": "none",
					"event": "battle",
					"last_id": "trigger_battle"
				},
				"end_robbed": {
					"text": "Smart choice. Now scurry off before I change my mind.",
					"options": [],
					"next_id": "none",
					"event": "none",
					"last_id": "trigger_battle"
				},
			},
			"1": {
				"start": {
					"text": "You got luck last time.",
					"options": [],
					"next_id": "none",
					"event": "none",
					"last_id": "start"
			}
		}
		},
		"The Weeping Statues": {
			"name": "The Weeping Statues",
			"face_texture": preload("res://assets/sprites/character/npc/wizard_man_boy/face.png"),
			"0": {
				"start": {
					"text": "Provide your wisdom O! special one",
					"options": [],
					"event": "none",
					"next_id": "question",
					"last_id": "correct_answer"
				},
				"question": {
					"text": "The eyes of the stone watch the setting sun... but they cannot see the truth of the dawn. Do you know the secret of the light?",
					"options": [
						{ "text": "The light is but a shadow of the soul.", "next_id": "wrong_answer" },
						{ "text": "The light is the memory of those gone before.", "next_id": "correct_answer" }
					],
					"event": "none",
					"last_id": "correct_answer"
				},
				"wrong_answer": {
					"text": "Poetic, but hollow. You are not the one we wait for.",
					"options": [],
					"next_id": "none",
					"event": "none",
					"last_id": "correct_answer"
				},
				"correct_answer": {
					"text": "A seeker of truth. You carry the wisdom required to open the Inner Sanctum. Take this.",
					"options": [],
					"event": "give_big_key",
					"next_id": "none",
					"last_id": "correct_answer"
				}
			},
			"1": {
				"start": {
					"text": "Hello adventurer",
					"options": [],
					"next_id": "none",
					"event": "none",
					"last_id": "start"
				}
			}
		}
	}
}

func _ready() -> void:
	SignalHandler.end_dialogue.connect(_on_end_dialogue)
	SignalHandler.dialogue_option_selected.connect(_on_dialogue_option_selected)
	SignalHandler.dialogue_skipped.connect(_on_dialogue_skipped)

func _on_end_dialogue() -> void:
	current_npc_dialogue_data_next_id = "start"

func _on_dialogue_option_selected(id: int) -> void:
	if id != -1:
		current_npc_dialogue_data_next_id = dialogue_data["npcs"][str(current_npc_name)][str(current_npc_stage_id)][current_npc_dialogue_data_next_id]["options"][id]["next_id"]
	else:
		current_npc_dialogue_data_next_id = dialogue_data["npcs"][str(current_npc_name)][str(current_npc_stage_id)][current_npc_dialogue_data_next_id]["next_id"]

func _on_dialogue_skipped() -> void:
	current_npc_dialogue_data_next_id = current_npc_dialogue_last_id

func can_dialogue_be_skipped() -> bool:
	if current_npc_dialogue_data_next_id == current_npc_dialogue_last_id:
		return false
	return true

func check_if_dialogue_is_present(npc_name: String, stage: int) -> bool:
	if npc_name in dialogue_data["npcs"]:
		var npc_dialogue = dialogue_data["npcs"][npc_name]
		if str(stage) in npc_dialogue:
			return true
	return false

func get_npc_dialogue(npc_name: String, stage: int) -> Dictionary:
	if check_if_dialogue_is_present(npc_name, stage):
		current_npc_name = npc_name
		current_npc_stage_id = stage
		var dialogue_to_return: Dictionary = {
			"name": "",
			"face_texture": "",
			"text": "",
			"options": [],
			"event": ""
		}
		if current_npc_dialogue_data_next_id != "none":
			dialogue_to_return["name"] = dialogue_data["npcs"][str(npc_name)]["name"]
			dialogue_to_return["face_texture"] = dialogue_data["npcs"][str(npc_name)]["face_texture"]
			dialogue_to_return["text"] = dialogue_data["npcs"][str(npc_name)][str(stage)][current_npc_dialogue_data_next_id]["text"]
			dialogue_to_return["options"] = dialogue_data["npcs"][str(npc_name)][str(stage)][current_npc_dialogue_data_next_id]["options"]
			dialogue_to_return["event"] = dialogue_data["npcs"][str(npc_name)][str(stage)][current_npc_dialogue_data_next_id]["event"]
			current_npc_dialogue_last_id = dialogue_data["npcs"][str(npc_name)][str(stage)][current_npc_dialogue_data_next_id]["last_id"]
			return dialogue_to_return
	return {}
