extends Node2D

@onready var back_door_player_entry_marker_2d: Marker2D = $BackDoorPlayerEntryMarker2D

func get_back_door_player_entry_point() -> Vector2:
	return back_door_player_entry_marker_2d.global_position
