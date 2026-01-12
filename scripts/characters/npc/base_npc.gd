extends CharacterBody2D

@export var npc_name: String = "Alyra"         # Name identifier for this NPC
@export var story_stage: int = 1               # Stage or chapter for dialogue branching
@onready var chat_area = $chat_detection_area  # Area2D used to detect player proximity
@onready var sprite = $AnimatedSprite2D
@onready var textbox = get_parent().get_node("Textbox")  # Get the textbox from the parent scene

var player_in_range = false
var dialogue_lines = []        # Stores current dialogue lines for this NPC
var dialogue_index = 0         # Tracks current line being shown
var is_chatting = false        # Tracks whether a chat is ongoing

func _ready():
	# Connect area enter/exit signals
	chat_area.body_entered.connect(_on_body_entered)
	chat_area.body_exited.connect(_on_body_exited)

func _process(_delta):
	# Only check for input if the player is in range
	if not player_in_range:
		return

	if Input.is_action_just_pressed("chat"):
		if not is_chatting:
			start_chat()
		elif textbox.current_state == textbox.State.FINISHED:
			start_chat()

func _on_body_entered(body):
	# Triggered when player enters chat area
	if body.name == "Player":
		player_in_range = true
		print("In chat range")
		# Flip sprite to face the player
		sprite.flip_h = body.global_position.x < global_position.x

func _on_body_exited(body):
	# Triggered when player exits chat area
	if body.name == "Player":
		player_in_range = false
		print("Out of chat range")
		sprite.flip_h = body.global_position.x < global_position.x
		if is_chatting:
			end_chat()

func start_chat():
	# Loads dialogue from DialogueManager and shows current line
	print("start_chat() called")
	print("is_chatting:", is_chatting)
	print("dialogue_lines empty?", dialogue_lines.is_empty())
	print("dialogue_index:", dialogue_index)

	if dialogue_lines.is_empty():
		dialogue_lines = DialogueManager.get_dialogue(npc_name, story_stage)
		dialogue_index = 0
		print("Loaded new dialogue:", dialogue_lines.size())

	if dialogue_index < dialogue_lines.size():
		print("Showing line", dialogue_index + 1, "→", dialogue_lines[dialogue_index])
		textbox.queue_text(dialogue_lines[dialogue_index])
		textbox.display_text()
		is_chatting = true
		dialogue_index += 1
	else:
		print("End of dialogue triggered")
		end_chat()

func end_chat():
	# Ends the conversation and resets dialogue tracking
	print("Chat ended.")
	is_chatting = false
	dialogue_index = 0
	dialogue_lines = []  # Replace the array instead of clearing
	textbox.hide_textbox()
