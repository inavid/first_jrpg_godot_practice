class_name BattleManager
extends Node

enum State
{
    INTRO,
    BATTLER_INPUT,
    TURN_RESOLUTION,
    END,
    FLEE
}

signal StateChanged(state: State)
signal TurnBegan(battler: Battler)
signal TurnEnded(battler: Battler)

@export var party: Array[Battler]
@export var enemies: Array[Battler]

var alive_party: Array[Battler]:
    get: return party.filter(func(b): return b.is_alive)

var alive_enemies: Array[Battler]:
    get: return enemies.filter(func(b): return b.is_alive)

var turn_queu: Array[Battler]

var state: State
var current_actor: Battler # The turn active battler
var current_action: BattleAction # The action executed by current turn

func _ready() -> void:
    _change_state(State.INTRO)

# func _process(delta: float) -> void:
#     if state == State.BATTLER_INPUT and party.has(current_actor):
#         if Input.is_action_just_pressed("ui_accept"):
#             var action : BattleAction = BattleAction.new()
#             action.actor = current_actor
#             action.targets = enemies
#             submit_player_input(action)

func _build_turn_queue():
    var all: Array[Battler] = party + enemies
    all = all.filter(func(battler): return battler.is_alive) # Dead characters should not have a turn
    turn_queu = all

func _next_battler_turn():
    if current_actor != null:
        TurnEnded.emit(current_actor)

    if turn_queu.is_empty():
        _build_turn_queue()

    current_actor = turn_queu.pop_front()

    if not current_actor.is_alive:
        _next_battler_turn()
        return

    print("Current turn: %s" % current_actor.name)

    TurnBegan.emit(current_actor)
    _change_state(State.BATTLER_INPUT)

func _change_state(new_state: State):
    state = new_state

    match state:
        State.INTRO: _enter_intro()
        State.BATTLER_INPUT: _enter_battler_input()
        State.TURN_RESOLUTION: _enter_turn_resolution()
        State.END: _enter_end()
        State.FLEE: _enter_flee()

    print("New State: %s" % state)

    StateChanged.emit(state)

func _enter_intro():
    _build_turn_queue()
    _next_battler_turn()

func _enter_battler_input():
    if current_actor.data.team == BattlerData.Team.PARTY:
        pass # Do nothing as this is managed by thge battleUI script
    else:
        pass # Decide enemy's action

func _enter_turn_resolution():
    if not current_action:
        _next_battler_turn()
        return

    current_actor.anim.play_action_animation(current_action)

    match current_action.type:
        BattleAction.Type.BASIC_ATTACK: _execute_useable()
        BattleAction.Type.SKILL: _execute_skill()
        BattleAction.Type.DEFEND: _execute_defend()
        BattleAction.Type.FLEE: _execute_flee()

    await get_tree().create_timer(1.0).timeout

    _next_battler_turn()


func _enter_end():
    pass

func _enter_flee():
    pass

func submit_player_input(action: BattleAction):
    current_action = action
    _change_state(State.TURN_RESOLUTION)

func _execute_useable():
    for target in current_action.targets:
        if current_action.useable.output_type == UseableData.OutputType.HEAL:
            target.heal(current_action.useable.power)
        else:
            var dmg: int = current_action.actor.get_stat(BattlerData.Stat.ATTACK)
            target.take_damage(dmg)

func _execute_skill():
    var skill: SkillData = current_action.useable

    if not skill.can_afford(current_actor):
        return

    current_actor.spend_mana(skill.mana_cost)
    _execute_useable()

func _execute_defend():
    pass

func _execute_flee():
    pass