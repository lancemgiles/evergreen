extends Area2D

var conversation
var counter = 0

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
	"Cedar: I saw the passage inside was blocked by thorns. If I can find a way around them, I should be able to climb.",
	"Mila: Yes. Be careful. There is something very strange about all of this..."
	]

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		set_physics_process(false)
		$DialogBox.visible = true
		
		match topic:
			Topics.LVL3MILA:
				conversation = dialog_1
		
		$DialogBox/Textbox/Label.text = conversation[0]
		counter += 1

func _on_next_button_pressed() -> void:
	var size = conversation.size()
	if counter >= size:
		$DialogBox.visible = false
		set_physics_process(true)
	else:
		$DialogBox/Textbox/Label.text = conversation[counter]
		counter += 1
