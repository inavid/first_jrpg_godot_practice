class_name BattlerAnimation
extends AnimatedSprite2D

const IDLE: String = "idle"
const HIT: String = "hit"
const ATTACK: String = "attack"
const EVADE: String = "evade"

func initialize(data: BattlerData):
	sprite_frames = data.battle_sprite_frames
	play(IDLE)

func _on_animation_finished() -> void:
	if animation != IDLE:
		play(IDLE)