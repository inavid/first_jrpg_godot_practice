class_name ButtonContainer
extends Control

@onready var header_label: Label = $Header
@onready var container: VBoxContainer = $ScrollContainer/VBoxContainer

const BUTTON_SCENE: PackedScene = preload("res://Scenes/Battle/UI/battle_button.tscn")

var buttons: Array[Button]

func _ready() -> void:
	visible = false # hidden until initialize() is called
	for child in container.get_children():
		if child is Button:
			buttons.append(child)

#Called when the container is triggered
# each button and its data is 
func initialize(header: String, data: Array[Dictionary]):
	visible = true
	header_label.text = header

	# create extra buttons if data has more entries than we have buttons
	while len(buttons) < len(data):
		var new_button: Button = BUTTON_SCENE.instantiate()
		container.add_child(new_button)
		buttons.append(new_button)

	for i in len(buttons):
		if i >= len(data):
			buttons[i].visible = false
			continue

		var b: Button = buttons[i]

		b.visible = true
		b.text = data[i]["text"]

		_clear_signal(b.pressed)

		b.pressed.connect(_on_pressed.bind(data[i]["clicked"]))

func _clear_signal(sig: Signal):
	for conn in sig.get_connections():
		print(conn)
		sig.disconnect(conn["callable"])

func _on_pressed(callable: Callable):
	callable.call()
