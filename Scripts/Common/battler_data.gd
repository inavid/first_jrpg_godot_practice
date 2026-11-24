# Data resource for all battlers
# There is only 1 scene for the battlers, so their individual data is defined as a resource
# This allows us to easily add/remove them from battle without needing to manage separate scenes

class_name BattlerData
extends Resource

enum Team
{
    PARTY,  # Player controlled battlers
    ENEMY   # Computer controlled battlers
}

# Stat identifiers used as keys in base_stats.
enum Stat
{
    MAX_HEALTH,
    MAX_MANA,
    MANA_REGEN,
    ATTACK,
    DEFENCE,
    MAGIC_ATTACK,
    MAGIC_DEFENCE,
    ACCURACY,
    EVASION
}

@export var display_name : String
@export var team : Team
# Default values for a battler's statistics; override as needed in individual resources.
@export var base_stats : Dictionary[Stat, Variant] = {
    Stat.MAX_HEALTH: 100,
    Stat.MAX_MANA: 100,
    Stat.MANA_REGEN: 5,
    Stat.ATTACK: 10,
    Stat.DEFENCE: 4,
    Stat.MAGIC_ATTACK: 6,
    Stat.MAGIC_DEFENCE: 3,
    Stat.ACCURACY: 90,
    Stat.EVASION: 10
}

# SkillData resources this battler can use.
@export var skills : Array[SkillData]
# The battler's standard non-skill action.
@export var basic_attack : UseableData

# SpriteFrames used by the shared battler scene during combat.
@export var battle_sprite_frames : SpriteFrames


# Status immunities
# Defending status