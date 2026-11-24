class_name ButtonContainer
extends Control

@onready var header_label : Label = $Header
@onready var container : VBoxContainer = $ScrollContainer/VBoxContainer
var buttons : Array[Button]

func _ready ():
    # Cache existing buttons once so this list can be reused for all initializations.
    for child in container.get_children():
        if child is Button:
            buttons.append(child)

# Called when the container is triggered, displaying the required buttons
# Each button and its data is stored in a dictionary:
# {"text": String, "info": String, "clicked": Callable}
func initialize (header : String, data : Array[Dictionary]):
    visible = true
    header_label.text = header
    
    # Reuse the cached buttons; hide extras when fewer entries are provided.
    for i in len(buttons):
        if i >= len(data):
            buttons[i].visible = false
            continue
        
        var b : Button = buttons[i]
        
        b.visible = true
        b.text = data[i]["text"]
        
        # Remove old handlers before connecting, so repeated calls don't stack callbacks.
        _clear_signal(b.pressed)
        
        b.pressed.connect(_on_pressed.bind(data[i]["clicked"]))

# Clears all connections for the given signal - resetting it
func _clear_signal (sig : Signal):
    for conn in sig.get_connections():
        sig.disconnect(conn["callable"])

func _on_pressed (callable : Callable):
    callable.call()