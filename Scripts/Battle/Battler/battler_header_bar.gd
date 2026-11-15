class_name BattleHeaderBar
extends Control

@onready var healt_bar: ProgressBar = $HealtBar
@onready var healt_label: Label = $HealtLabel

@onready var mana_bar: ProgressBar = $ManaBar
@onready var mana_label: Label = $ManaLabel

@onready var battler: Battler = get_parent()

func _ready() -> void:
	#Connect to signals
	battler.HealtChanged.connect(_on_healt_changed)
	battler.ManaChanged.connect(_on_mana_changed)

func _on_healt_changed(cur: int, max: int):
	healt_label.text = "HP: %s / %s" % [cur, max]
	healt_bar.max_value = max
	healt_bar.value = cur

func _on_mana_changed(cur: int, max: int):
	mana_label.text = "MP: %s / %s" % [cur, max]
	mana_bar.max_value = max
	mana_bar.value = cur