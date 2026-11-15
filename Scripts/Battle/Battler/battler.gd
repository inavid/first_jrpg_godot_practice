class_name Battler
extends Area2D

signal HealtChanged(cur: int, max: int)
signal ManaChanged(cur: int, max: int)
signal Died

@export var data: BattlerData

var current_healt: int
var current_mana: int
var is_alive: bool = true

@onready var anim: BattlerAnimation = $AnimatedSprite2D

func _ready() -> void:
	# Set current healt/mana
	current_healt = get_stat(BattlerData.Stat.MAX_HEALT)
	current_mana = get_stat(BattlerData.Stat.MAX_MANA)

	HealtChanged.emit(current_healt, current_healt)
	ManaChanged.emit(current_mana, current_mana)

	anim.initialize(data)

func get_stat(stat: BattlerData.Stat):
	var value: float = data.base_stats.get(stat, 0)

	# TODO: Apply status effects

	return value

func take_damage(amount: int):
	var max_healt: int = get_stat(BattlerData.Stat.MAX_HEALT)
	current_healt -= amount
	HealtChanged.emit(current_healt, max_healt)

	anim.play(BattlerAnimation.HIT)

	if current_healt <= 0:
		die()

func heal(amount: int):
	var max_healt: int = get_stat(BattlerData.Stat.MAX_HEALT)
	current_healt += amount

	if current_healt > max_healt:
		current_healt = max_healt

	HealtChanged.emit(current_healt, max_healt)

func die():
	pass

func spend_mana(amount: int):
	if current_mana < amount:
		return false

	var max_mana: int = get_stat(BattlerData.Stat.MAX_MANA)
	current_mana += amount
	ManaChanged.emit(current_mana, max_mana)
	return true

func restore_mana(amount: int):
	var max_mana: int = get_stat(BattlerData.Stat.MAX_MANA)
	current_mana += amount

	if current_mana > max_mana:
		current_mana = max_mana

	ManaChanged.emit(current_mana, max_mana)

func evade():
	pass