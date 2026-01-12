extends Node2D

@onready var front_door_player_entry_marker_2d: Marker2D = $FrontDoorPlayerEntryMarker2D

func get_front_door_player_entry_point() -> Vector2:
	return front_door_player_entry_marker_2d.global_position
