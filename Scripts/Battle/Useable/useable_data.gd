class_name UseableData
extends Resource

enum OutputType
{
    NONE,
    PHYSICAL,
    MAGIC,
    HEAL
}

enum TargetType
{
    SINGLE_ENEMY,
    ALL_ENEMIES,
    SINGLE_ALLY,
    ALL_ALLIES,
    SELF
}

@export var display_name: String
@export var description: String

@export_category("Targeting")
@export var target_type: TargetType

@export_category("Output")
@export var output_type : OutputType
@export var power : int = 100
@export var scaling_stat : BattlerData.Stat
@export var defending_stat : BattlerData.Stat
@export_range(0.0, 1.0) var crit_chance : float
@export_range(0.0, 1.0) var accuracy : float
