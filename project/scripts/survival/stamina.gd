extends Node

signal stamina_changed(current: float, maximum: float)

@export var maximum_stamina: float = 100.0
@export var sprint_drain_per_second: float = 25.0
@export var recovery_per_second: float = 18.0

var current_stamina: float
var exhausted := false


func _ready() -> void:
	current_stamina = maximum_stamina


func update_stamina(delta: float, wants_to_sprint: bool) -> bool:
	if wants_to_sprint:
		if not exhausted and current_stamina > 0.0:
			current_stamina = maxf(
				0.0,
				current_stamina - sprint_drain_per_second * delta
			)
			if current_stamina <= 0.0:
				exhausted = true
	else:
		exhausted = false
		current_stamina = minf(
			maximum_stamina,
			current_stamina + recovery_per_second * delta
		)

	stamina_changed.emit(current_stamina, maximum_stamina)
	return wants_to_sprint and not exhausted
