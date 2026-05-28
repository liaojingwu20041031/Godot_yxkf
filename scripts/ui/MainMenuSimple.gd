extends Control

func _ready():
	print("MainMenuSimple ready!")
	var label = Label.new()
	label.text = "TEST"
	label.position = Vector2(300, 180)
	add_child(label)
