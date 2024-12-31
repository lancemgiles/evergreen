extends Area2D

var conversation
var counter = 0
var dialog_width

enum Topics {LVL3MILA}
@export var topic : Topics

var dialog_1 = [
	"Mila: Is that you, Cedar?",
	"Cedar: Mila! I am glad you are safe.",
	"Mila: Thank you, Cedar. You, too",
	"Cedar: What happened? I sensed something was wrong, and the creatures have been violent.",
	"Mila: Yes, and thorny, diseased vines are spreading. I would advise against continuing up the tree from outside.",
	"Cedar: But...",
	"Mila: The thorns are too thick here where the shade begins, but they thin-out above.",
	"Cedar: I saw the passage inside was blocked by thorns.",
	"If I can find a way around them, I should be able to climb.",
	"Mila: Yes. Be careful. There is something very strange about all of this...",
	"Cedar: ...I should get going.",
	"Mila: Take this robe of my thread.",
	"It is lightweight and nearly invisible, but it should provide you with much more protection."
	]

# dialog 2 with Mila should check the player's max health and grant them the new robe if they've missed it
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		await get_tree().create_timer(0.2).timeout
		get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		$".".visible = true
		
		match topic:
			Topics.LVL3MILA:
				conversation = dialog_1
				body.max_health = 6
				body.health = 6
				body.update_health.emit(6, 6)
		
		$DialogBox/Textbox/Label.text = conversation[0]
		counter += 1

func _on_next_button_pressed() -> void:
	var size = conversation.size()
	if counter >= size:
		counter = 0
		$".".visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		get_tree().paused = false
	else:
		$DialogBox/Textbox/Label.text = conversation[counter]
		counter += 1
