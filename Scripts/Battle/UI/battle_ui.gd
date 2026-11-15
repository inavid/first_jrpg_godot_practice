class_name BattleUI
extends Panel

@export var buttonContainers: Dictionary[String, ButtonContainer]

var selection_action: BattleAction.Type
var selected_skill: SkillData
var possible_targets: Array[Battler]
var current_action: BattleAction

# What is this? whats the name of this? shorthand?
var cur_battler: Battler:
	get: return battle_manager.current_actor

@onready var battle_manager: BattleManager = get_parent()

func _ready() -> void:
	battle_manager.StateChanged.connect(_on_changed_state)

func _disable_all_containers():
	for key in buttonContainers:
		buttonContainers[key].visible = false

func _display_actions():
	var bc: ButtonContainer = buttonContainers["actions"]
	var data: Array[Dictionary]

	data.append({
		"text": "Attack",
		"info": "Cast a basic Attack",
		"clicked": _on_attack_selected
	})

	data.append({
		"text": "Defend",
		"info": "Block damage for 1 turn",
		"clicked": _on_defend_selected
	})

	data.append({
		"text": "Skills",
		"info": "Perform an skill using mana",
		"clicked": _on_skills_selected
	})

	data.append({
		"text": "Flee",
		"info": "Attempt to leave the battle",
		"clicked": _on_flee_selected
	})

	data.append({
		"text": "End Turn",
		"info": "End your turn without performing an action",
		"clicked": _on_end_turn_selected
	})

	bc.initialize("Actions", data)

func _display_skills():
	var bc: ButtonContainer = buttonContainers["skills"]
	var data: Array[Dictionary]

	for skill in cur_battler.data.skills:
		data.append({
			"text": skill.display_name,
			"info": skill.description,
			"clicked": _on_skill_selected.bind(skill)
		})

	bc.initialize("Skills", data)

func _display_targets():
	var bc: ButtonContainer = buttonContainers["targets"]
	var data: Array[Dictionary]

	for target in possible_targets:
		data.append({
			"text": target.data.display_name,
			"info": "Need to implement",
			"clicked": _on_target_selected.bind(target)
		})

	bc.initialize("Targets", data)

func _on_changed_state(state: BattleManager.State):
	if state == BattleManager.State.BATTLER_INPUT and cur_battler.data.team == BattlerData.Team.PARTY:
		selected_skill = null
		possible_targets = []
		_display_actions()
	else:
		_disable_all_containers()

func _on_attack_selected():
	current_action = BattleAction.new()
	current_action.actor = cur_battler
	current_action.type = BattleAction.Type.BASIC_ATTACK
	current_action.useable = cur_battler.data.basic_attack

	possible_targets = battle_manager.alive_enemies

	_display_targets()

func _on_defend_selected():
	print("Defend Selected")

func _on_skills_selected():
	_display_skills()

func _on_flee_selected():
	print("Flee Selected")
	pass

func _on_end_turn_selected():
	print("End Turn Selected")
	pass

func _on_skill_selected(skill: SkillData):
	buttonContainers["targets"].visible = false

	current_action = BattleAction.new()
	current_action.actor = cur_battler
	current_action.type = BattleAction.Type.SKILL
	current_action.useable = skill

	var display_targets: bool = false

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

func _on_target_selected(target: Battler):
	current_action.targets = [target]
	battle_manager.submit_player_input(current_action)
