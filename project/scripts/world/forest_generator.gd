extends Node3D

const FOREST_SIZE := 1000.0
const TREE_COUNT := 1400
const SPAWN_CLEAR_RADIUS := 24.0
const RESOURCE_CLEAR_RADIUS := 5.0


func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 20261003

	var trunk_mesh := CylinderMesh.new()
	trunk_mesh.top_radius = 0.18
	trunk_mesh.bottom_radius = 0.32
	trunk_mesh.height = 2.4

	var canopy_mesh := SphereMesh.new()
	canopy_mesh.radius = 1.0
	canopy_mesh.height = 2.0

	var trunk_material := StandardMaterial3D.new()
	trunk_material.albedo_color = Color(0.25, 0.16, 0.09)
	trunk_material.roughness = 1.0

	var canopy_material := StandardMaterial3D.new()
	canopy_material.albedo_color = Color(0.16, 0.32, 0.17)
	canopy_material.roughness = 1.0

	var tree_collision := CapsuleShape3D.new()
	tree_collision.radius = 0.28
	tree_collision.height = 2.4

	var trunks := _create_multimesh(trunk_mesh, trunk_material)
	var canopies := _create_multimesh(canopy_mesh, canopy_material)
	trunks.multimesh.instance_count = TREE_COUNT
	canopies.multimesh.instance_count = TREE_COUNT

	for index in TREE_COUNT:
		var location := _random_tree_location(rng)
		var scale_factor := rng.randf_range(0.8, 1.35)
		var yaw := rng.randf_range(0.0, TAU)

		trunks.multimesh.set_instance_transform(
			index,
			Transform3D(
				Basis(Vector3.UP, yaw).scaled(Vector3.ONE * scale_factor),
				Vector3(location.x, 1.2 * scale_factor, location.y)
			)
		)
		canopies.multimesh.set_instance_transform(
			index,
			Transform3D(
				Basis(Vector3.UP, yaw).scaled(Vector3(1.4, 1.5, 1.4) * scale_factor),
				Vector3(location.x, 3.0 * scale_factor, location.y)
			)
		)
		_add_tree_collision(index, location, scale_factor, tree_collision)


func _create_multimesh(mesh: Mesh, material: Material) -> MultiMeshInstance3D:
	var multimesh := MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = mesh

	var visual := MultiMeshInstance3D.new()
	visual.multimesh = multimesh
	visual.material_override = material
	add_child(visual)
	return visual


func _add_tree_collision(
	index: int,
	location: Vector2,
	scale_factor: float,
	shape: Shape3D
) -> void:
	var tree := StaticBody3D.new()
	tree.name = "TreeCollision_%04d" % index
	tree.position = Vector3(location.x, 0.0, location.y)

	var collision := CollisionShape3D.new()
	collision.position.y = 1.2 * scale_factor
	collision.scale = Vector3.ONE * scale_factor
	collision.shape = shape
	tree.add_child(collision)
	add_child(tree)


func _random_tree_location(rng: RandomNumberGenerator) -> Vector2:
	var resource_locations := [
		Vector2(-1.0, -1.0),
		Vector2(2.5, -7.0),
		Vector2(-1.5, -2.0),
		Vector2(4.0, -4.0),
	]
	var half_size := FOREST_SIZE * 0.5 - 5.0

	while true:
		var location := Vector2(
			rng.randf_range(-half_size, half_size),
			rng.randf_range(-half_size, half_size)
		)
		if location.length_squared() < SPAWN_CLEAR_RADIUS * SPAWN_CLEAR_RADIUS:
			continue
		var near_resource := false
		for resource_location: Vector2 in resource_locations:
			if location.distance_squared_to(resource_location) < RESOURCE_CLEAR_RADIUS * RESOURCE_CLEAR_RADIUS:
				near_resource = true
				break
		if not near_resource:
			return location
