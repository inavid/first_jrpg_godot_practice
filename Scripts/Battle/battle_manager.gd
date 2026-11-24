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

# Signals that let other systems (UI, animations, etc.) react to battle flow.
signal StateChanged (state : State)
signal TurnBegan (battler : Battler)
signal TurnEnded (battler : Battler)

@export var party : Array[Battler]
@export var enemies : Array[Battler]

# An array constructed ONLY of party battlers who have their 'is_alive' variable set to true
var alive_party : Array[Battler]:
    get: return party.filter(func(b): return b.is_alive)

var alive_enemies : Array[Battler]:
    get: return enemies.filter(func(b): return b.is_alive)

# Core battle state: which battler is currently acting and what action they chose.
var turn_queue : Array[Battler]
var state : State
var current_actor : Battler
var current_action : BattleAction

func _ready ():
    _change_state(State.INTRO)

# Determine the order the battlers will take their turns
func _build_turn_queue ():
    var all : Array[Battler] = party + enemies
    all = all.filter(func(b): return b.is_alive)
    turn_queue = all

# Progress through the turn queue, activating the next battler
func _next_battler_turn ():
    if current_actor != null:
        TurnEnded.emit(current_actor)
    
    if turn_queue.is_empty():
        _build_turn_queue()
    
    current_actor = turn_queue.pop_front()
    
    # Skip dead battlers that may have been queued before dying.
    if not current_actor.is_alive:
        _next_battler_turn()
        return
    
    print("Current turn: %s" % current_actor.name)
    
    TurnBegan.emit(current_actor)
    _change_state(State.BATTLER_INPUT)

# Move to a new state and let external systems know via StateChanged.
func _change_state (new_state : State):
    state = new_state
    
    match state:
        State.INTRO: _enter_intro()
        State.BATTLER_INPUT: _enter_battler_input()
        State.TURN_RESOLUTION: _enter_turn_resolution()
        State.END: _enter_end()
        State.FLEE: _enter_flee()
    
    print("New state: %s" % state)
    StateChanged.emit(state)

# -> INTRO state
# Called at the start of the game - initial setup
func _enter_intro ():
    await get_tree().create_timer(1.0).timeout
    _build_turn_queue()
    _next_battler_turn()

# -> BATTLER_INPUT state
# Where the enemy will determine their action - the player's is managed by the BattleUI script
func _enter_battler_input ():
    if current_actor.data.team == BattlerData.Team.PARTY:
        pass # Do nothing as this is managed by the BattleUI script
    else:
        # Enemy AI: choose a simple basic attack against a random living party member.
        current_action = BattleAction.new()
        current_action.actor = current_actor
        current_action.targets = [alive_party.pick_random()]
        current_action.type = BattleAction.Type.BASIC_ATTACK
        current_action.useable = current_actor.data.basic_attack
        _change_state(State.TURN_RESOLUTION)

# -> TURN_RESOLUTION state
# When the enemy/player submits an action for their battler to perform
func _enter_turn_resolution ():
    # The current_action will be null if turn is skipped, so continue to the next battler
    if not current_action:
        _next_battler_turn()
        return
    
    current_actor.anim.play_action_animation(current_action)
    
    match current_action.type:
        BattleAction.Type.BASIC_ATTACK: _execute_useable()
        BattleAction.Type.SKILL: _execute_skill()
        BattleAction.Type.DEFEND: _execute_defend()
        BattleAction.Type.FLEE: _execute_flee()
    
    # Wait x seconds before moving on to next battler
    await get_tree().create_timer(1.0).timeout
    
    # If we have changed states midway, don't continue on to the next battler
    # This happens when all the enemies/players are defeated and the game is over
    if state != State.TURN_RESOLUTION:
        return
    
    _next_battler_turn()

# -> END state
# When either the enemy or party have been entirely defeated
func _enter_end ():
    if alive_enemies.is_empty():
        print("Party wins!")
    else:
        print("Enemies win!")

# -> FLEE state
# When the player wants to attempt to leave battle
func _enter_flee ():
    pass

# Called when the player has selected an action to perform for their current battler
func submit_player_input (action : BattleAction):
    current_action = action
    _change_state(State.TURN_RESOLUTION)

# Perform the current BattleAction's UseableData upon all targets
func _execute_useable ():
    for target in current_action.targets:
        var result = ActionCalculator.calculate(current_actor, target, current_action.useable)
        
        if result.is_heal:
            target.heal(result.amount)
        elif not result.is_hit:
            target.evade()
        else:
            if result.is_crit:
                # Play unique sound/effect
                pass
            
            target.take_damage(result.amount)

# Perform the current BattleAction' SkillData
func _execute_skill ():
    var skill : SkillData = current_action.useable
    
    # Skills can fail if the battler cannot afford their cost.
    if not skill.can_afford(current_actor):
        return
    
    current_actor.spend_mana(skill.mana_cost)
    _execute_useable()

# Give the battler the 'Defense' status - blocking damage for 1 turn
func _execute_defend ():
    pass

# Attempt to leave the battle
func _execute_flee ():
    pass

# Called when a battler has died -> check to see if either team has won the battle
func battler_died (battler : Battler):
    print("%s has been defeated!" % battler.data.display_name)
    
    if alive_enemies.is_empty() or alive_party.is_empty():
        _change_state(State.END)