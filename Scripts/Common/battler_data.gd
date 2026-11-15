class_name BattlerData
extends Resource

enum Team
{
    PARTY,
    ENEMY
}

enum Stat
{
    MAX_HEALT,
    MAX_MANA,
    MANA_REGEN,
    ATTACK,
    DEFENSE,
    MAGIC_ATTACK,
    MAGIC_DEFENSE,
    ACCURACY,
    EVASION
}

@export var display_name: String
@export var team: Team
@export var base_stats: Dictionary[Stat, Variant] = {
    Stat.MAX_HEALT: 100,
    Stat.MAX_MANA: 100,
    Stat.MANA_REGEN: 5, # Value between 0 and 10
    Stat.ATTACK: 10, # Value between 0 and 100
    Stat.DEFENSE: 10, # Value between 0 and 100
    Stat.MAGIC_ATTACK: 10, # Value between 0 and 100
    Stat.MAGIC_DEFENSE: 10, # Value between 0 and 100
    Stat.ACCURACY: 5, # Value between 0 and 100
    Stat.EVASION: 5 # Value between 0 and 100
}

@export var skills: Array[SkillData]
@export var basic_attack: UseableData

@export var battle_sprite_frames: SpriteFrames

# Skills
# Basic Attack
# Status Inmunities
# Defending Status
