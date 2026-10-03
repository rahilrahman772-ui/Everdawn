class_name ResourcePickup
extends Area3D

enum Kind { FOOD, WATER, WOOD, STONE }

@export var kind: Kind = Kind.FOOD

@onready var visual: MeshInstance3D = $Visual

var inventory_id: StringName:
	get:
		match kind:
			Kind.FOOD:
				return &"berries"
			Kind.WATER:
				return &"water"
			Kind.WOOD:
				return &"wood"
			Kind.STONE:
				return &"stone"
		return &"unknown"

var display_name: String:
	get:
		match kind:
			Kind.FOOD:
				return "Wild berries"
			Kind.WATER:
				return "Fresh water"
			Kind.WOOD:
				return "Wood"
			Kind.STONE:
				return "Stone"
		return "Resource"


func _ready() -> void:
	collision_layer = 4
	collision_mask = 0

	var material := StandardMaterial3D.new()
	match kind:
		Kind.FOOD:
			material.albedo_color = Color(0.78, 0.12, 0.16)
			visual.scale = Vector3(0.8, 1.0, 0.8)
		Kind.WATER:
			material.albedo_color = Color(0.12, 0.48, 0.85)
			visual.scale = Vector3(0.7, 1.15, 0.7)
		Kind.WOOD:
			material.albedo_color = Color(0.46, 0.27, 0.12)
			visual.scale = Vector3(1.2, 0.55, 0.55)
		Kind.STONE:
			material.albedo_color = Color(0.42, 0.45, 0.47)
			visual.scale = Vector3(0.8, 0.7, 0.8)
	material.roughness = 0.8 if kind != Kind.WATER else 0.35
	visual.material_override = material


func interact(player: Node) -> void:
	if player.has_method("collect_resource"):
		player.call("collect_resource", inventory_id)
	queue_free()
