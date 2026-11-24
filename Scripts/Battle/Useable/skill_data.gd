class_name SkillData
extends UseableData

@export_category("Cost")
@export var mana_cost : int

# Returns true if the battler has at least as much mana as the skill costs.
func can_afford (battler : Battler) -> bool:
    return battler.current_mana >= mana_cost