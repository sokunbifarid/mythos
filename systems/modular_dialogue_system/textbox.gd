extends CanvasLayer

@onready var textbox_container = $MarginContainer
@onready var start_symbol = $MarginContainer/MarginContainer/HBoxContainer/Start
@onready var end_symbol = $MarginContainer/MarginContainer/HBoxContainer/End
@onready var label = $MarginContainer/MarginContainer/HBoxContainer/Label

enum State {
	READY,
	SHOWING,
	FINISHED
}

var current_state = State.READY
var text_queue = []
var current_line = ""

func _ready():
	# Called when the node is added to the scene. Hides the textbox initially.
	hide_textbox()

func _process(_delta):
	# Listens for player input to progress or end dialogue depending on the current state.
	if current_state == State.SHOWING:
		if Input.is_action_just_pressed("chat"):
			show_next_line()
	elif current_state == State.FINISHED:
		if Input.is_action_just_pressed("chat"):
			hide_textbox()
			change_state(State.READY)

func queue_text(next_text):
	# Adds a new line of text to the dialogue queue.
	text_queue.append(next_text)

func show_textbox():
	# Displays the textbox UI and sets the symbol markers.
	textbox_container.show()
	start_symbol.text = "*"
	end_symbol.text = "v"

func hide_textbox():
	# Hides the textbox UI and clears any existing text or queued lines.
	label.text = ""
	start_symbol.text = ""
	end_symbol.text = ""
	textbox_container.hide()
	text_queue.clear()
	current_line = ""

func display_text():
	# Sets the label text to the current dialogue line and updates the UI symbols.
	if text_queue.is_empty():
		change_state(State.FINISHED)
		return

	current_line = text_queue.pop_front()
	label.text = current_line
	show_textbox()
	change_state(State.SHOWING)

func show_next_line():
	# Displays the next line in the queue, or finishes dialogue if the queue is empty.
	display_text()

func change_state(next_state):
	# Updates the current state of the dialogue box.
	current_state = next_state
