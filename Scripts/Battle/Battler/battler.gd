class_name Battler
extends Area2D

# Signals that let UI and combat logic observe this battler’s resource changes.
signal HealthChanged (cur : int, max : int)
signal ManaChanged (cur : int, max : int)
signal Died

@export var data : BattlerData

var current_health : int
var current_mana : int
var is_alive : bool = true

@onready var anim : BattlerAnimation = $AnimatedSprite2D
@onready var turn_indicator : Node2D = $TurnIndicator

@onready var battle_manager : BattleManager = get_tree().root.get_node("Main/BattleManager")

func _ready ():
    # Set current health/mana
    current_health = get_stat(BattlerData.Stat.MAX_HEALTH)
    current_mana = get_stat(BattlerData.Stat.MAX_MANA)
    
    # Let UI know the starting values before the battle begins.
    HealthChanged.emit(current_health, current_health)
    ManaChanged.emit(current_mana, current_mana)
    
    anim.initialize(data)
    
    # Connect to BattleManager signals
    battle_manager.TurnBegan.connect(_on_turn_began)
    battle_manager.TurnEnded.connect(_on_turn_ended)

func _on_turn_began (battler : Battler):
    # Only show the indicator when this battler becomes the active fighter.
    if battler == self:
        turn_indicator.visible = true

func _on_turn_ended (battler : Battler):
    if battler == self:
        turn_indicator.visible = false

# Returns the value of the requested stat, with modifiers applied.
func get_stat (stat : BattlerData.Stat) -> float:
    var value : float = data.base_stats.get(stat, 0)
    
    # TODO: Apply status effects
    
    return value

func take_damage (amount : int):
    var max_health : int = get_stat(BattlerData.Stat.MAX_HEALTH)
    current_health -= amount
    HealthChanged.emit(current_health, max_health)
    
    # Play hit reaction immediately; death is checked after lowering health.
    anim.play(BattlerAnimation.HIT)
    anim.flash_color(Color.RED)
    
    if current_health <= 0:
        die()

func heal (amount : int):
    var max_health : int = get_stat(BattlerData.Stat.MAX_HEALTH)
    current_health += amount
    
    # Healing cannot go above the stat-derived maximum health.
    if current_health > max_health:
        current_health = max_health
    
    HealthChanged.emit(current_health, max_health)

func die ():
    is_alive = false
    battle_manager.battler_died(self)
    # Keep the sprite visible briefly so the hit animation can be seen before hiding.
    await get_tree().create_timer(0.2).timeout
    visible = false

func spend_mana (amount : int) -> bool:
    # Refuse the action if the battler does not have enough mana.
    if current_mana < amount:
        return false
    
    var max_mana : int = get_stat(BattlerData.Stat.MAX_MANA)
    current_mana -= amount
    ManaChanged.emit(current_mana, max_mana)
    return true

func restore_mana (amount : int):
    var max_mana : int = get_stat(BattlerData.Stat.MAX_MANA)
    current_mana += amount
    
    # Mana restore cannot go above the stat-derived maximum mana.
    if current_mana > max_mana:
        current_mana = max_mana
    
    ManaChanged.emit(current_mana, max_mana)

func evade ():
    # Evasion mechanics are not implemented yet.
    pass