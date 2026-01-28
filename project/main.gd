extends Control

func _ready():
	print("Godot 4.6 Web Template is running!")

func _on_button_pressed():
	$CenterContainer/VBoxContainer/Subtitle.text = "Button clicked! Template is working! ✓"
	print("Button was pressed!")
