extends CanvasLayer

@onready var start: Label = $TextMarginContainer/MarginContainer/HBoxContainer/Start
@onready var text_label: RichTextLabel = $TextMarginContainer/MarginContainer/HBoxContainer/Label
@onready var end: Label = $TextMarginContainer/MarginContainer/HBoxContainer/End
@onready var options_margin_container: MarginContainer = $OptionsMarginContainer
@onready var option_1_button: Button = $OptionsMarginContainer/MarginContainer/VBoxContainer/Option1Button
@onready var option_2_button: Button = $OptionsMarginContainer/MarginContainer/VBoxContainer/Option2Button
@onready var player_texture_rect: TextureRect = $TextMarginContainer/Panel/CharactersTexturesControl/PlayerTextureRect
@onready var npc_texture_rect: TextureRect = $TextMarginContainer/Panel/CharactersTexturesControl/NPCHolderControl/NPCTextureRect
@onready var item_received_texture_rect: TextureRect = $ItemReceiveMarginContainer/ItemReceivedTextureRect

var last_dialogue_event: String = ""
var npc_speaking_to: CharacterBody2D
var dialogue_started: bool = false
var items_to_receive: Dictionary = {
	"big_key": preload("res://assets/sprites/environment/rooms/room_type_1/big_key.png")
}

func _ready() -> void:
	SignalHandler.start_dialogue.connect(_on_start_dialogue)
	SignalHandler.enemy_lost_battle.connect(_on_enemy_lost_battle)
	hide_textbox()

func _unhandled_input(_event: InputEvent) -> void:
	if self.visible:#GameManager.is_battle():#is_world():
		if Input.is_action_just_pressed("accept"):
			if dialogue_started:
				if not options_margin_container.visible:
					SignalHandler.emit_dialogue_option_selected_signal(-1)
					get_dialogue_data()
		elif Input.is_action_just_pressed("escape"):
			if dialogue_started and DialogueManager.can_dialogue_be_skipped():
				if self.visible and npc_speaking_to:
					SignalHandler.emit_dialogue_skipped_signal()
					get_dialogue_data()

func _on_start_dialogue(npc: CharacterBody2D) -> void:
	show_textbox()
	npc_speaking_to = npc
	get_dialogue_data()

func _on_enemy_lost_battle() -> void:
	if GameManager.get_enemy_to_battle().get_npc_name() == DialogueManager.current_npc_name:
		if DialogueManager.current_npc_stage_id == 0:
			GameManager.get_enemy_to_battle().increase_story_stage()
			##remove all globally assigned values here

func get_dialogue_data() -> void:
	if dialogue_started:
		var dialogue_content: Dictionary = DialogueManager.get_npc_dialogue(npc_speaking_to.get_npc_name(), npc_speaking_to.get_story_stage())
		if dialogue_content != {}:
			text_label.text = dialogue_content["text"]
			npc_texture_rect.get_child(0).text = dialogue_content["name"]
			npc_texture_rect.texture = dialogue_content["face_texture"]
			last_dialogue_event = dialogue_content["event"]
			set_textbox_input_options_label()
			if dialogue_content["options"].size() > 0:
				show_options_container()
				if dialogue_content["options"].size() > 1:
					option_1_button.get_child(0).text = dialogue_content["options"][0]["text"]
				elif dialogue_content["options"].size() > 2:
					option_2_button.get_child(0).text = dialogue_content["options"][1]["text"]
				option_1_button.grab_focus()
			else:
				hide_options_container()
			set_event_action(dialogue_content)
		else:
			set_event_action(dialogue_content)
			hide_textbox()
			SignalHandler.emit_end_dialogue_signal()

func set_event_action(dialogue_content: Dictionary) -> void:
	if not dialogue_content:
		if last_dialogue_event == "completed":
			npc_speaking_to.increase_story_stage()
			SignalHandler.emit_battle_room_initiator_signal()
		elif last_dialogue_event == "battle":
			#SignalHandler.emit_preparing_to_go_for_battle_signal()
			SignalHandler.emit_battle_room_initiator_signal()
		elif last_dialogue_event == "none":
			SignalHandler.emit_battle_room_initiator_signal()
		elif last_dialogue_event == "give_big_key":
			SignalHandler.emit_battle_room_initiator_signal()
	else:
		if last_dialogue_event == "give_big_key":
			item_received_texture_rect.show()
			item_received_texture_rect.texture = items_to_receive["big_key"]
			GameManager.get_main_player().equip_key()
			npc_speaking_to.increase_story_stage()
		#elif last_dialogue_event == "battle":
			#GameManager.set_enemy_to_battle(npc_speaking_to)

func set_textbox_input_options_label() -> void:
	if DialogueManager.can_dialogue_be_skipped():
		end.text = "[Enter]\nContinue\n\n[ESC]\nSkip"
	else:
		end.text = "[Enter]\nContinue"

func show_textbox() -> void:
	self.show()
	player_texture_rect.get_child(0).text = GameManager.get_player_name()
	dialogue_started = true

func focus_on_player_texture() -> void:
	player_texture_rect.modulate = Color.WHITE
	npc_texture_rect.modulate = Color.DIM_GRAY

func focus_on_npc_texture() -> void:
	player_texture_rect.modulate = Color.DIM_GRAY
	npc_texture_rect.modulate = Color.WHITE

func hide_textbox() -> void:
	self.hide()
	item_received_texture_rect.texture = null
	item_received_texture_rect.hide()
	dialogue_started = false
	options_margin_container.hide()
	npc_speaking_to = null

func show_options_container() -> void:
	options_margin_container.show()
	focus_on_player_texture()

func hide_options_container() -> void:
	focus_on_npc_texture()
	options_margin_container.hide()
	option_1_button.release_focus()
	option_2_button.release_focus()

func _on_option_1_button_pressed() -> void:
	if options_margin_container.visible:#GameManager.is_world():
		if dialogue_started:
			hide_options_container()
			SignalHandler.emit_dialogue_option_selected_signal(0)
			get_dialogue_data()

func _on_option_2_button_pressed() -> void:
	if options_margin_container.visible:#GameManager.is_world():
		if dialogue_started:
			hide_options_container()
			SignalHandler.emit_dialogue_option_selected_signal(1)
			get_dialogue_data()
