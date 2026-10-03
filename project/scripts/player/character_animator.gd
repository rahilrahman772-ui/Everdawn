class_name CharacterAnimator
extends Node3D

const IDLE_SCENE := "res://assets/models/characters/Remy_Idle.fbx"
const WALK_SCENE := "res://assets/models/characters/Remy_Walk.fbx"
const RUN_SCENE := "res://assets/models/characters/Remy_Run.fbx"

var _animation_player: AnimationPlayer
var _current_state: StringName
var _ready_for_animation := false


func _ready() -> void:
	if not ResourceLoader.exists(IDLE_SCENE):
		return

	var idle_scene := load(IDLE_SCENE) as PackedScene
	if idle_scene == null:
		return

	var model := idle_scene.instantiate()
	add_child(model)
	_animation_player = _find_animation_player(model)
	if _animation_player == null:
		model.queue_free()
		return

	var library := AnimationLibrary.new()
	var idle_animation := _copy_mixamo_animation(_animation_player)
	if idle_animation == null:
		model.queue_free()
		_animation_player = null
		return

	_add_looping_animation(library, &"idle", idle_animation)
	_add_animation_from_scene(library, &"walk", WALK_SCENE)
	_add_animation_from_scene(library, &"run", RUN_SCENE)

	if not library.has_animation(&"walk") or not library.has_animation(&"run"):
		model.queue_free()
		_animation_player = null
		return

	_animation_player.add_animation_library(&"Everdawn", library)
	_animation_player.play(&"Everdawn/idle")
	_current_state = &"idle"
	_ready_for_animation = true
	(get_parent().get_node("BodyMesh") as MeshInstance3D).visible = false


func set_locomotion(is_moving: bool, is_sprinting: bool) -> void:
	if not _ready_for_animation:
		return

	var next_state: StringName = &"idle"
	if is_moving:
		next_state = &"run" if is_sprinting else &"walk"

	if next_state == _current_state:
		return

	_current_state = next_state
	_animation_player.play(StringName("Everdawn/%s" % next_state))


func _add_animation_from_scene(
	library: AnimationLibrary,
	animation_name: StringName,
	scene_path: String
) -> void:
	if not ResourceLoader.exists(scene_path):
		return

	var packed_scene := load(scene_path) as PackedScene
	if packed_scene == null:
		return

	var scene := packed_scene.instantiate()
	var source_player := _find_animation_player(scene)
	if source_player != null:
		var animation := _copy_mixamo_animation(source_player)
		if animation != null:
			_add_looping_animation(library, animation_name, animation)
	scene.free()


func _copy_mixamo_animation(source_player: AnimationPlayer) -> Animation:
	for animation_name in source_player.get_animation_list():
		if "mixamo" in String(animation_name).to_lower():
			return source_player.get_animation(animation_name).duplicate() as Animation
	return null


func _add_looping_animation(
	library: AnimationLibrary,
	animation_name: StringName,
	animation: Animation
) -> void:
	animation.loop_mode = Animation.LOOP_LINEAR
	library.add_animation(animation_name, animation)


func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer

	for child in node.get_children():
		var result := _find_animation_player(child)
		if result != null:
			return result

	return null
