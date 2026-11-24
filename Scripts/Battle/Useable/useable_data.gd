# Base resource class for all things a battler can use (attacks, skills, spells, weapons, items, etc)

class_name UseableData
extends Resource

# Each useable can target differently
# e.g. a heal might target self or allies, an attack will target a single or all enemies
enum TargetType
{
    SINGLE_ENEMY,
    ALL_ENEMIES,
    SINGLE_ALLY,
    ALL_ALLIES,
    SELF
}

# What this useable is desiring to do
# e.g. an attack will be PHYSICAL, a spell will be MAGIC, a heal will be HEAL
enum OutputType
{
    NONE,
    PHYSICAL,
    MAGIC,
    HEAL
}

# Basic identification for menus, logs, and tooltips
@export var display_name : String
@export var description : String

@export_category("Targeting")
# Which group of battlers this useable can affect
@export var target_type : TargetType

@export_category("Output")
# How the useable is classified for damage/healing calculations
@export var output_type : OutputType
# Base effectiveness value; see the note at the bottom for how it is used
@export var power : int = 100
# The attacker's stat that scales the output (e.g. ATTACK or MAGIC ATTACK)
@export var scaling_stat : BattlerData.Stat
# The defender's stat that reduces the output (e.g. DEFENSE)
@export var defending_stat : BattlerData.Stat
# Chance for a critical hit, from 0.0 to 1.0
@export_range(0.0, 1.0) var crit_chance : float
# Chance to successfully land the effect, from 0.0 to 1.0
@export_range(0.0, 1.0) var accuracy : float

# 'power' is the generic value used to determine the effectiveness of a useable.
# PHYSICAL damage = actor's ATTACK stat * (power as a percentage)
# MAGIC damage = actor's MAGIC ATTACK stat + (power as a flat value)
# HEAL amount = power