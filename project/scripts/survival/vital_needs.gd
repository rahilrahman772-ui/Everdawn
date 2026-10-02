class_name VitalNeeds
extends Node

signal needs_changed(hunger: float, max_hunger: float, thirst: float, max_thirst: float)

@export var maximum_hunger: float = 100.0
@export var maximum_thirst: float = 100.0
@export var hunger_loss_per_second: float = 0.12
@export var thirst_loss_per_second: float = 0.2

var current_hunger: float
var current_thirst: float


func _ready() -> void:
	current_hunger = maximum_hunger
	current_thirst = maximum_thirst


func advance(delta: float) -> void:
	var previous_hunger := current_hunger
	var previous_thirst := current_thirst

	current_hunger = maxf(0.0, current_hunger - hunger_loss_per_second * delta)
	current_thirst = maxf(0.0, current_thirst - thirst_loss_per_second * delta)

	if (
		not is_equal_approx(previous_hunger, current_hunger)
		or not is_equal_approx(previous_thirst, current_thirst)
	):
		_emit_needs_changed()


func restore_hunger(amount: float) -> void:
	current_hunger = minf(maximum_hunger, current_hunger + amount)
	_emit_needs_changed()


func restore_thirst(amount: float) -> void:
	current_thirst = minf(maximum_thirst, current_thirst + amount)
	_emit_needs_changed()


func _emit_needs_changed() -> void:
	needs_changed.emit(
		current_hunger,
		maximum_hunger,
		current_thirst,
		maximum_thirst
	)
