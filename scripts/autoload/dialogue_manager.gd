extends Node

var dialogue_data = {
 	"Guide Olara": {
		"1": [
			{
			"conversation": "Welcome, traveler, to the lands of Aetheria! It is rare to see a fresh face in these parts. You'll need to find your footing quickly.",
			"options":[]
			},
			{
			"conversation": "Use the [W, A, S, D] keys to move your character. If you see something interesting, press [E] to interact with it.",
			"options": []
			},
			{
			"conversation": "Keep an eye out—some things, like doors or pressure plates, are auto-interactable just by walking over them. Good luck on your journey!",
			"options": []
			}
		],
		"2": [
			{
				"conversation": "You're back. Did you find something interesting?",
				"options": []
			},
			{
				"conversation": "Okay, enjoy",
				"options": [],
			}
		]
	  },
	"Korgak the Scarred": {
		"1": [
		  "This is a private road. You look like you've got a heavy purse and a weak sword arm.",
		  "This one's on the house."
		]
	}
}

func get_dialogue(npc_name: String, stage: int) -> Array:
	# Returns the dialogue lines for a given NPC and story stage (chapter).
	if npc_name in dialogue_data:
		var npc_dialogue = dialogue_data[npc_name]
		if str(stage) in npc_dialogue:
			print("Loaded dialogue for", npc_name, "stage", stage)
			return npc_dialogue[str(stage)]
	print("No dialogue found for", npc_name, "stage", stage)
	return []


#
#{
  #"npcs": [
	#{
	  #"name": "Guide Olara",
	  #"type": "Tutorial",
	  #"dialogue_nodes": {
		#"start": {
		  #"text": "Welcome, traveler, to the lands of Aetheria! It is rare to see a fresh face in these parts. You'll need to find your footing quickly.",
		  #"next_id": "controls"
		#},
		#"controls": {
		  #"text": "Use the [W, A, S, D] keys to move your feet. If you see something interesting, press [E] to interact with it.",
		  #"next_id": "environment"
		#},
		#"environment": {
		  #"text": "Keep an eye out—some things, like doors or pressure plates, are auto-interactable just by walking over them. Good luck on your journey!",
		  #"options": [],
		  #"event": "TUTORIAL_COMPLETE"
		#}
	  #}
	#},
	#{
	  #"name": "Korgak the Scarred",
	  #"type": "Hostile / Battle",
	  #"dialogue_nodes": {
		#"start": {
		  #"text": "This is a private road. You look like you've got a heavy purse and a weak sword arm.",
		  #"options": [
			#{ "text": "I don't want any trouble.", "next_id": "intimidation" },
			#{ "text": "Step aside, or I'll move you myself.", "next_id": "trigger_battle" }
		  #]
		#},
		#"intimidation": {
		  #"text": "Trouble found you anyway. Toss the gold over, or I start cutting.",
		  #"options": [
			#{ "text": "Fine, take it. (Pay 50g)", "next_id": "end_robbed" },
			#{ "text": "Over my dead body!", "next_id": "trigger_battle" }
		  #]
		#},
		#"trigger_battle": {
		  #"text": "Hah! I was hoping you'd say that. Draw your steel!",
		  #"options": [],
		  #"event": "START_COMBAT"
		#},
		#"end_robbed": {
		  #"text": "Smart choice. Now scurry off before I change my mind.",
		  #"options": []
		#}
	  #}
	#},
	#{
	  #"name": "The Weeping Statues",
	  #"type": "Quest / Item Reward",
	  #"dialogue_nodes": {
		#"start": {
		  #"text": "The eyes of the stone watch the setting sun... but they cannot see the truth of the dawn. Do you know the secret of the light?",
		  #"options": [
			#{ "text": "The light is but a shadow of the soul.", "next_id": "wrong_answer" },
			#{ "text": "The light is the memory of those gone before.", "next_id": "correct_answer" }
		  #]
		#},
		#"wrong_answer": {
		  #"text": "Poetic, but hollow. You are not the one we wait for.",
		  #"options": []
		#},
		#"correct_answer": {
		  #"text": "A seeker of truth. You carry the wisdom required to open the Inner Sanctum. Take this.",
		  #"options": [],
		  #"event": "GIVE_ITEM_SKELETON_KEY"
		#}
	  #}
	#}
  #]
#}
