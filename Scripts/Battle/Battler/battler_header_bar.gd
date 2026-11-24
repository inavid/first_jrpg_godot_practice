class_name BattleHeaderBar
extends Control

# Child UI nodes used to show the battler's health.
@onready var health_bar : ProgressBar = $HealthBar
@onready var health_label : Label = $HealthLabel

# Child UI nodes used to show the battler's mana.
@onready var mana_bar : ProgressBar = $ManaBar
@onready var mana_label : Label = $ManaLabel

# The battler whose stats this header reflects; assumes the parent node is a Battler.
@onready var battler : Battler = get_parent()

func _ready ():
    # Connect to signals
    battler.HealthChanged.connect(_on_health_changed)
    battler.ManaChanged.connect(_on_mana_changed)

# Update the HEALTH bar when battler's HEALTH changes
func _on_health_changed (cur : int, max : int):
    health_label.text = "HP: %s / %s" % [cur, max]
    health_bar.max_value = max
    health_bar.value = cur

# Update the MANA bar when battler's MANA changes
func _on_mana_changed (cur : int, max : int):
    mana_label.text = "MP: %s / %s" % [cur, max]
    mana_bar.max_value = max
    mana_bar.value = cur