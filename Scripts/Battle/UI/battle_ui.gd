class_name BattleUI
extends Panel

@export var button_containers : Dictionary[String, ButtonContainer]

var selection_action : BattleAction.Type
var selected_skill : SkillData
var possible_targets : Array[Battler]
var current_action : BattleAction

@onready var battle_manager : BattleManager = get_parent()

var cur_battler : Battler:
    get: return battle_manager.current_actor

func _ready ():
    battle_manager.StateChanged.connect(_on_changed_state)

# Disable button containers when state is not BATTLER_INPUT
# and current actor is not a party member
func _disable_all_containers ():
    for key in button_containers:
        button_containers[key].visible = false

# Display the base actions for the current battler
# Called when a party member starts their turn
func _display_actions ():
    var bc : ButtonContainer = button_containers["actions"]
    var data : Array[Dictionary]
    
    # Attack Button
    data.append({
        "text": "Attack",
        "info": "Cast a basic attack.",
        "clicked": _on_attack_selected
    })
    
    # Defend Button
    data.append({
        "text": "Defend",
        "info": "Block damage for 1 turn.",
        "clicked": _on_defend_selected
    })
    
    # Skills Button
    data.append({
        "text": "Skills",
        "info": "Perform a skill using mana.",
        "clicked": _on_skills_selected
    })
    
    # Flee Button
    data.append({
        "text": "Flee",
        "info": "Attempt to leave the battle.",
        "clicked": _on_flee_selected
    })
    
    # End Turn Button
    data.append({
        "text": "End Turn",
        "info": "End your turn without performing an action.",
        "clicked": _on_end_turn_selected
    })
    
    bc.initialize("Actions", data)

# Called when the "Skills" button is pressed
# Display a button for each skill the current battler has
func _display_skills ():
    var bc : ButtonContainer = button_containers["skills"]
    var data : Array[Dictionary]
    
    for skill in cur_battler.data.skills:
        data.append({
            "text": skill.display_name,
            "info": skill.description,
            "clicked": _on_skill_selected.bind(skill)
        })
    
    bc.initialize("Skills", data)

# Display all possible targets the pre-defined action can be directed to
func _display_targets ():
    var bc : ButtonContainer = button_containers["targets"]
    var data : Array[Dictionary]
    
    for target in possible_targets:
        data.append({
            "text": target.data.display_name,
            "info": "NEED TO IMPLEMENT",
            "clicked": _on_target_selected.bind(target)
        })
    
    bc.initialize("Targets", data)

# Called when the BattleManager's state changes
# Enable the UI if it's a party member's turn
func _on_changed_state (state : BattleManager.State):
    if state == BattleManager.State.BATTLER_INPUT and cur_battler.data.team == BattlerData.Team.PARTY:
        selected_skill = null
        possible_targets = []
        _display_actions()
    else:
        _disable_all_containers()

# Called when the "Attack" button is pressed
# Display a target to direct the attack towards
func _on_attack_selected ():
    current_action = BattleAction.new()
    current_action.actor = cur_battler
    current_action.type = BattleAction.Type.BASIC_ATTACK
    current_action.useable = cur_battler.data.basic_attack
    
    possible_targets = battle_manager.alive_enemies
    
    _display_targets()

func _on_defend_selected ():
    print("Defend selected")

func _on_skills_selected ():
    _display_skills()

func _on_flee_selected ():
    print("Flee selected")

func _on_end_turn_selected ():
    battle_manager.submit_player_input(null)

# Called when a skill button is pressed
# Either perform that skill, or display all possible targets
func _on_skill_selected (skill : SkillData):
    button_containers["targets"].visible = false
    
    current_action = BattleAction.new()
    current_action.actor = cur_battler
    current_action.type = BattleAction.Type.SKILL
    current_action.useable = skill
    
    var display_targets : bool = false
    
    match skill.target_type:
        UseableData.TargetType.SINGLE_ENEMY:
            display_targets = true
            possible_targets = battle_manager.alive_enemies
        UseableData.TargetType.SINGLE_ALLY:
            display_targets = true
            possible_targets = battle_manager.alive_party
        UseableData.TargetType.SELF:
            possible_targets = [cur_battler]
        UseableData.TargetType.ALL_ALLIES:
            possible_targets = battle_manager.alive_party
        UseableData.TargetType.ALL_ENEMIES:
            possible_targets = battle_manager.alive_enemies
    
    if display_targets:
        _display_targets()
    else:
        current_action.targets = possible_targets
        battle_manager.submit_player_input(current_action)

# Called when a target button is pressed
# Perform the pre-defined action on the selected target
func _on_target_selected (target : Battler):
    current_action.targets = [target]
    battle_manager.submit_player_input(current_action)