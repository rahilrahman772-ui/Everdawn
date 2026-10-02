class_name ResourcePickup
extends Area3D

enum Kind { FOOD, WATER }

@export var kind: Kind = Kind.FOOD
@export var restore_amount: float = 30.0

@onready var visual: MeshInstance3D = $Visual

var display_name: String:
	get:
		return "Wild berries" if kind == Kind.FOOD else "Fresh water"


func _ready() -> void:
	collision_layer = 4
	collision_mask = 0

	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.78, 0.12, 0.16) if kind == Kind.FOOD else Color(0.12, 0.48, 0.85)
	material.roughness = 0.35 if kind == Kind.WATER else 0.8
	visual.material_override = material
	visual.scale = Vector3(0.8, 1.0, 0.8) if kind == Kind.FOOD else Vector3(0.7, 1.15, 0.7)


func interact(player: Node) -> void:
	var needs := player.get_node_or_null("Needs") as VitalNeeds
	if needs == null:
		return

	if kind == Kind.FOOD:
		needs.restore_hunger(restore_amount)
	else:
		needs.restore_thirst(restore_amount)

	queue_free()
