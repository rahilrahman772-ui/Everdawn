extends Node3D

const WORLD_SIZE := 1000.0
const TERRAIN_SEGMENTS := 160
const TREE_COUNT := 1400
const SPAWN_CLEAR_RADIUS := 24.0
const RESOURCE_CLEAR_RADIUS := 7.0
const RIVER_CLEAR_RADIUS := 20.0
const RIVER_WIDTH := 9.0

var _broad_noise := FastNoiseLite.new()
var _detail_noise := FastNoiseLite.new()
var _mountain_noise := FastNoiseLite.new()
var _resource_locations := [
	Vector2(-1.0, -1.0),
	Vector2(2.5, -7.0),
	Vector2(-1.5, -2.0),
	Vector2(4.0, -4.0),
]


func _ready() -> void:
	_configure_noise()
	_create_terrain()
	_create_river()
	_create_forest()
	_place_player_and_resources()


func _configure_noise() -> void:
	_broad_noise.seed = 641
	_broad_noise.frequency = 0.003
	_broad_noise.fractal_octaves = 4

	_detail_noise.seed = 1927
	_detail_noise.frequency = 0.018
	_detail_noise.fractal_octaves = 2

	_mountain_noise.seed = 8341
	_mountain_noise.frequency = 0.005
	_mountain_noise.fractal_octaves = 3


func _terrain_height(x: float, z: float) -> float:
	var broad := _broad_noise.get_noise_2d(x, z) * 11.0
	var detail := _detail_noise.get_noise_2d(x, z) * 1.8
	var distance_from_start := Vector2(x, z).length()
	var mountain_mask := _smoothstep(100.0, 430.0, distance_from_start)
	var ridges: float = pow(absf(_mountain_noise.get_noise_2d(x, z)), 1.7) * 105.0 * mountain_mask
	var surrounding_land := broad + detail + ridges

	var river_distance: float = absf(x - _river_center_x(z))
	var bank_blend := _smoothstep(0.0, 34.0, river_distance)
	var riverbed := -1.7 + broad * 0.05
	return lerpf(riverbed, surrounding_land, bank_blend)


func _river_center_x(z: float) -> float:
	return 72.0 * sin(z * 0.004) + 24.0 * sin(z * 0.013)


func _smoothstep(start: float, finish: float, value: float) -> float:
	var amount := clampf((value - start) / (finish - start), 0.0, 1.0)
	return amount * amount * (3.0 - 2.0 * amount)


func _create_terrain() -> void:
	var side_count := TERRAIN_SEGMENTS + 1
	var step_size := WORLD_SIZE / TERRAIN_SEGMENTS
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var colors := PackedColorArray()
	var indices := PackedInt32Array()
	indices.resize(TERRAIN_SEGMENTS * TERRAIN_SEGMENTS * 6)
	var index_cursor := 0
	vertices.resize(side_count * side_count)
	normals.resize(side_count * side_count)
	colors.resize(side_count * side_count)

	for z_index in side_count:
		for x_index in side_count:
			var x := -WORLD_SIZE * 0.5 + x_index * step_size
			var z := -WORLD_SIZE * 0.5 + z_index * step_size
			var height := _terrain_height(x, z)
			var vertex_index := z_index * side_count + x_index
			vertices[vertex_index] = Vector3(x, height, z)
			normals[vertex_index] = Vector3(
				_terrain_height(x - 1.0, z) - _terrain_height(x + 1.0, z),
				2.0,
				_terrain_height(x, z - 1.0) - _terrain_height(x, z + 1.0)
			).normalized()
			colors[vertex_index] = _terrain_color(height)

	for z_index in TERRAIN_SEGMENTS:
		for x_index in TERRAIN_SEGMENTS:
			var top_left := z_index * side_count + x_index
			var top_right := top_left + 1
			var bottom_left := top_left + side_count
			var bottom_right := bottom_left + 1
			indices[index_cursor] = top_left
			indices[index_cursor + 1] = bottom_left
			indices[index_cursor + 2] = top_right
			indices[index_cursor + 3] = top_right
			indices[index_cursor + 4] = bottom_left
			indices[index_cursor + 5] = bottom_right
			index_cursor += 6

	var surface_arrays := []
	surface_arrays.resize(Mesh.ARRAY_MAX)
	surface_arrays[Mesh.ARRAY_VERTEX] = vertices
	surface_arrays[Mesh.ARRAY_NORMAL] = normals
	surface_arrays[Mesh.ARRAY_COLOR] = colors
	surface_arrays[Mesh.ARRAY_INDEX] = indices

	var terrain_mesh := ArrayMesh.new()
	terrain_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_arrays)

	var terrain_material := StandardMaterial3D.new()
	terrain_material.vertex_color_use_as_albedo = true
	terrain_material.roughness = 1.0

	var terrain_visual := MeshInstance3D.new()
	terrain_visual.name = "ProceduralTerrain"
	terrain_visual.mesh = terrain_mesh
	terrain_visual.material_override = terrain_material
	add_child(terrain_visual)

	var terrain_body := StaticBody3D.new()
	terrain_body.name = "TerrainCollision"
	var terrain_shape := CollisionShape3D.new()
	terrain_shape.shape = terrain_mesh.create_trimesh_shape()
	terrain_body.add_child(terrain_shape)
	add_child(terrain_body)


func _terrain_color(height: float) -> Color:
	if height > 62.0:
		return Color(0.42, 0.45, 0.42)
	if height > 35.0:
		return Color(0.36, 0.41, 0.31)
	if height < 1.0:
		return Color(0.23, 0.34, 0.22)
	return Color(0.28, 0.39, 0.23)


func _create_river() -> void:
	var segments := 240
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var indices := PackedInt32Array()
	indices.resize(segments * 6)

	for segment in range(segments + 1):
		var z := -WORLD_SIZE * 0.5 + WORLD_SIZE * float(segment) / segments
		var center_x := _river_center_x(z)
		var slope := (_river_center_x(z + 1.0) - _river_center_x(z - 1.0)) * 0.5
		var side := Vector2(1.0, -slope).normalized()
		var water_y := -0.55 + _broad_noise.get_noise_2d(center_x, z) * 0.12
		vertices.append(Vector3(center_x + side.x * RIVER_WIDTH * 0.5, water_y, z + side.y * RIVER_WIDTH * 0.5))
		vertices.append(Vector3(center_x - side.x * RIVER_WIDTH * 0.5, water_y, z - side.y * RIVER_WIDTH * 0.5))
		normals.append(Vector3.UP)
		normals.append(Vector3.UP)

	for segment in segments:
		var first := segment * 2
		var next := first + 2
		var index_cursor := segment * 6
		indices[index_cursor] = first
		indices[index_cursor + 1] = first + 1
		indices[index_cursor + 2] = next
		indices[index_cursor + 3] = first + 1
		indices[index_cursor + 4] = next + 1
		indices[index_cursor + 5] = next

	var surface_arrays := []
	surface_arrays.resize(Mesh.ARRAY_MAX)
	surface_arrays[Mesh.ARRAY_VERTEX] = vertices
	surface_arrays[Mesh.ARRAY_NORMAL] = normals
	surface_arrays[Mesh.ARRAY_INDEX] = indices

	var river_mesh := ArrayMesh.new()
	river_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_arrays)

	var river_material := StandardMaterial3D.new()
	river_material.albedo_color = Color(0.1, 0.38, 0.37)
	river_material.roughness = 0.22
	river_material.metallic = 0.12

	var river := MeshInstance3D.new()
	river.name = "River"
	river.mesh = river_mesh
	river.material_override = river_material
	river.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(river)


func _create_forest() -> void:
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
	canopy_material.albedo_color = Color(0.13, 0.29, 0.15)
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
		var ground_height := _terrain_height(location.x, location.y)
		var scale_factor := rng.randf_range(0.8, 1.35)
		var yaw := rng.randf_range(0.0, TAU)

		trunks.multimesh.set_instance_transform(
			index,
			Transform3D(
				Basis(Vector3.UP, yaw).scaled(Vector3.ONE * scale_factor),
				Vector3(location.x, ground_height + 1.2 * scale_factor, location.y)
			)
		)
		canopies.multimesh.set_instance_transform(
			index,
			Transform3D(
				Basis(Vector3.UP, yaw).scaled(Vector3(1.4, 1.5, 1.4) * scale_factor),
				Vector3(location.x, ground_height + 3.0 * scale_factor, location.y)
			)
		)
		_add_tree_collision(index, location, ground_height, scale_factor, tree_collision)


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
	ground_height: float,
	scale_factor: float,
	shape: Shape3D
) -> void:
	var tree := StaticBody3D.new()
	tree.name = "TreeCollision_%04d" % index
	tree.position = Vector3(location.x, ground_height, location.y)

	var collision := CollisionShape3D.new()
	collision.position.y = 1.2 * scale_factor
	collision.scale = Vector3.ONE * scale_factor
	collision.shape = shape
	tree.add_child(collision)
	add_child(tree)


func _random_tree_location(rng: RandomNumberGenerator) -> Vector2:
	var half_size := WORLD_SIZE * 0.5 - 5.0

	for attempt in range(TREE_COUNT * 20):
		var location := Vector2(
			rng.randf_range(-half_size, half_size),
			rng.randf_range(-half_size, half_size)
		)
		if location.length_squared() < SPAWN_CLEAR_RADIUS * SPAWN_CLEAR_RADIUS:
			continue
		if abs(location.x - _river_center_x(location.y)) < RIVER_CLEAR_RADIUS:
			continue

		var near_resource := false
		for resource_location: Vector2 in _resource_locations:
			if location.distance_squared_to(resource_location) < RESOURCE_CLEAR_RADIUS * RESOURCE_CLEAR_RADIUS:
				near_resource = true
				break
		if not near_resource:
			return location

	return Vector2(half_size, half_size)


func _place_player_and_resources() -> void:
	var player := get_node_or_null("Player") as Node3D
	if player != null:
		player.position.y = _terrain_height(player.position.x, player.position.z)

	for child in get_children():
		if child is ResourcePickup:
			var pickup := child as ResourcePickup
			pickup.position.y = _terrain_height(pickup.position.x, pickup.position.z)
