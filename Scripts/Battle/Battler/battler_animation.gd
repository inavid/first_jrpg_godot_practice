class_name BattlerAnimation
extends AnimatedSprite2D

# Animation name constants used to keep strings consistent
const IDLE : String = "idle"
const HIT : String = "hit"
const ATTACK : String = "attack"
const EVADE : String = "evade"

func initialize (data : BattlerData):
    # Load the battler's specific sprite frames, then start in idle
    sprite_frames = data.battle_sprite_frames
    play(IDLE)

# Called whenever an animation finishes playing - revert back to IDLE
func _on_animation_finished():
    # Only interrupt non-idle states; idle should not restart itself
    if animation != IDLE:
        play(IDLE)

# Called when the battler performs an action
# Some useables might have a custom animation for the battler to perform
func play_action_animation (action : BattleAction):
    # If this is not a healing action, play the attack animation
    if action.useable and action.useable.output_type != UseableData.OutputType.HEAL:
        play(ATTACK)

# When damaged, we flash the battler for a fraction of a second
func flash_color (color : Color):
    # Apply the flash tint, wait briefly, then restore normal white color
    self_modulate = color
    await get_tree().create_timer(0.1).timeout
    self_modulate = Color.WHITE