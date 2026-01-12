extends Node2D

@export var starting_room: Node2D
@export var room1_front_door_link_room: Node2D 
@export var room2_front_door_link_room: Node2D
@export var room2_back_door_link_room: Node2D
@export var room3_back_door_link_room: Node2D

@onready var room_1_front_door: Node2D = $Room1/Objects/Doors/room1_front_door
@onready var room_2_back_door: Node2D = $Room2/Objects/Doors/room2_back_door
@onready var room_2_front_door: Node2D = $Room2/Objects/Doors/room2_front_door
@onready var room_3_back_door: Node2D = $Room3/Objects/Doors/room3_back_door


var room_details_to_link: Node2D

func _ready() -> void:
	SignalHandler.player_using_door.connect(_on_player_using_door)

func find_next_door_to_link(door: Node2D, player: CharacterBody2D) -> void:
	if room1_front_door_link_room or  room2_front_door_link_room or  room2_back_door_link_room or  room3_back_door_link_room:
		if door == room_1_front_door:
			player.set_connecting_door_endpoint(room1_front_door_link_room.get_back_door_player_entry_point())
		elif door == room_2_front_door:
			player.set_connecting_door_endpoint(room2_front_door_link_room.get_back_door_player_entry_point())
		elif door == room_2_back_door:
			player.set_connecting_door_endpoint(room2_back_door_link_room.get_front_door_player_entry_point())
		elif door == room_3_back_door:
			player.set_connecting_door_endpoint(room3_back_door_link_room.get_front_door_player_entry_point())
	else:
		printerr("room door link not assigned")

func _on_player_using_door(the_door: Node2D, player: CharacterBody2D) -> void:
	find_next_door_to_link(the_door, player)
