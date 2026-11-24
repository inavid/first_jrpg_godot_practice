class_name ActionCalculator
extends Node

# When a battler performs an action, this script calculates the result,
# taking into consideration both the actor and target's stats
# The ActionResult is the packet of info that's returned to the BattleManager
class ActionResult:
    var amount : int = 0
    var is_hit : bool = false
    var is_crit : bool = false
    var is_heal : bool = false

static func calculate (actor : Battler, target : Battler, useable : UseableData) -> ActionResult:
    var result : ActionResult = ActionResult.new()
    
    # Check if target evaded - if so, return empty result
    if _evaded(actor, target, useable):
        print("%s EVADED!" % target.data.display_name)
        return result
    
    # On a hit, one of the specialized functions fully populates the result.
    # Calculate physical, magical, or heal amount
    match useable.output_type:
        UseableData.OutputType.PHYSICAL:
            result = _calculate_physical(actor, target, useable)
        UseableData.OutputType.MAGIC:
            result = _calculate_magical(actor, target, useable)
        UseableData.OutputType.HEAL:
            result = _calculate_heal(target, useable)
    
    return result

# Physical DMG = (actor ATK * power) - target DEF
static func _calculate_physical (actor : Battler, target : Battler, useable : UseableData) -> ActionResult:
    var result : ActionResult = ActionResult.new()
    var scaling = actor.get_stat(useable.scaling_stat)
    var defending = target.get_stat(useable.defending_stat)
    # power is a percentage, so 100 maps to a full stat multiplier.
    var base = scaling * (useable.power / 100.0)
    
    # Determine if attack is a CRIT
    if randf() < useable.crit_chance:
        result.is_crit = true
        base *= 2
    
    # Defense is applied after crit, and damage cannot go below zero.
    result.is_hit = true
    result.amount = max(base - defending, 0)
    return result

# Magical DMG = (actor MAG ATK + power) - target MAG DEF
static func _calculate_magical (actor : Battler, target : Battler, useable : UseableData) -> ActionResult:
    var result : ActionResult = ActionResult.new()
    var scaling = actor.get_stat(useable.scaling_stat)
    var defending = target.get_stat(useable.defending_stat)
    # Magical power is added directly to the stat rather than acting as a percentage.
    var base = scaling + useable.power
    
    # Determine if attack is a CRIT
    if randf() < useable.crit_chance:
        result.is_crit = true
        base *= 2
    
    # Defense is applied after crit, and damage cannot go below zero.
    result.is_hit = true
    result.amount = max(base - defending, 0)
    return result

# Heal amount = power
static func _calculate_heal (target : Battler, useable : UseableData) -> ActionResult:
    var result : ActionResult = ActionResult.new()
    result.is_heal = true
    result.amount = useable.power
    return result

# Return true if target successfully evaded actor's attack
static func _evaded (actor : Battler, target : Battler, useable : UseableData) -> bool:
    # Healing bypasses the miss/evade checks entirely.
    if useable.output_type == UseableData.OutputType.HEAL:
        return false
    
    # 1. RNG on useable accuracy
    if randf() > useable.accuracy:
        return true
    
    # 2. RNG on target EVASION stat
    # Evasion roll uses a 0..100 scale to match the EVASION stat.
    var evasion = target.get_stat(BattlerData.Stat.EVASION)
    return randf_range(0, 100) < evasion