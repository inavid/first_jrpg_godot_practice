# Data container that is constructed when a battler performs an action
# The BattleManager reads this and executes what is defined within

class_name BattleAction
extends RefCounted

# All possible action categories a battler can perform in battle.
enum Type
{
    BASIC_ATTACK,
    SKILL,
    DEFEND,
    FLEE
}

# The battler performing the action.
var actor : Battler
# Battlers that the action is directed toward. May be empty for actions like FLEE.
var targets : Array[Battler]
# Which kind of action this is; controls how the battle system interprets it.
var type : Type
# Optional data for skills/items; null or unused for BASIC_ATTACK, DEFEND, and FLEE.
var useable : UseableData