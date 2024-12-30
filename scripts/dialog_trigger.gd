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
	"Cedar: I saw the passage inside was blocked by thorns. If I can find a way around them, I should be able to climb.",
	"Mila: Yes. Be careful. There is something very strange about all of this..."
	]

#func _process(delta: float) -> void:
	#if $CollisionShape2D/DialogBox.visible == true:
		#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#elif $CollisionShape2D/DialogBox.visible == false:
		#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		await get_tree().create_timer(0.2).timeout
		get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		#body.ui_state = body.UIState.MENU
		$CollisionShape2D/DialogBox.visible = true
		
		match topic:
			Topics.LVL3MILA:
				conversation = dialog_1
		
		$CollisionShape2D/DialogBox/Textbox/Label.text = conversation[0]
		counter += 1

func _on_next_button_pressed() -> void:
	print("next button pressed")
	var size = conversation.size()
	print("conversation size:")
	print(size)
	print("counter:")
	print(counter)
	if counter >= size:
		counter = 0
		$CollisionShape2D/DialogBox.visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		get_tree().paused = false
	else:
		$CollisionShape2D/DialogBox/Textbox/Label.text = conversation[counter]
		print("conversation[counter]")
		print(conversation[counter])
		counter += 1
