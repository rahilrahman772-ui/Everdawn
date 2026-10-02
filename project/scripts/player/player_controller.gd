extends CharacterBody3D

@export var walk_speed: float = 5.0
@export var sprint_speed: float = 8.0
@export var acceleration: float = 20.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.0025

@onready var camera_pivot: Node3D = $CameraPivot
@onready var stamina_component: StaminaComponent = $Stamina
@onready var needs_component: VitalNeeds = $Needs
@onready var stamina_bar: ProgressBar = $HUD/StaminaBar
@onready var stamina_label: Label = $HUD/StaminaLabel
@onready var hunger_bar: ProgressBar = $HUD/HungerBar
@onready var hunger_label: Label = $HUD/HungerLabel
@onready var thirst_bar: ProgressBar = $HUD/ThirstBar
@onready var thirst_label: Label = $HUD/ThirstLabel

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready() -> void:
	_add_key_action(&"move_forward", KEY_W)
	_add_key_action(&"move_back", KEY_S)
	_add_key_action(&"move_left", KEY_A)
	_add_key_action(&"move_right", KEY_D)
	_add_key_action(&"jump", KEY_SPACE)
	_add_key_action(&"sprint", KEY_SHIFT)

	stamina_component.stamina_changed.connect(_on_stamina_changed)
	_on_stamina_changed(
		stamina_component.current_stamina,
		stamina_component.maximum_stamina
	)

	needs_component.needs_changed.connect(_on_needs_changed)
	_on_needs_changed(
		needs_component.current_hunger,
		needs_component.maximum_hunger,
		needs_component.current_thirst,
		needs_component.maximum_thirst
	)

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	elif Input.is_action_just_pressed(&"jump"):
		velocity.y = jump_velocity

	var input_direction := Input.get_vector(
		&"move_left",
		&"move_right",
		&"move_forward",
		&"move_back"
	)
	var direction := (transform.basis * Vector3(input_direction.x, 0.0, input_direction.y)).normalized()
	var wants_to_sprint := (
		Input.is_action_pressed(&"sprint")
		and input_direction.length_squared() > 0.001
	)
	var is_sprinting: bool = stamina_component.update_stamina(delta, wants_to_sprint)
	needs_component.advance(delta)
	var speed := sprint_speed if is_sprinting else walk_speed

	velocity.x = move_toward(velocity.x, direction.x * speed, acceleration * delta)
	velocity.z = move_toward(velocity.z, direction.z * speed, acceleration * delta)

	move_and_slide()


func _on_stamina_changed(current: float, maximum: float) -> void:
	stamina_bar.max_value = maximum
	stamina_bar.value = current
	var percentage := 0
	if maximum > 0.0:
		percentage = roundi(current / maximum * 100.0)
	stamina_label.text = "STAMINA %d%%" % percentage


func _on_needs_changed(
	hunger: float,
	max_hunger: float,
	thirst: float,
	max_thirst: float
) -> void:
	_update_needs_bar(hunger_bar, hunger_label, hunger, max_hunger, "HUNGER")
	_update_needs_bar(thirst_bar, thirst_label, thirst, max_thirst, "THIRST")


func _update_needs_bar(
	bar: ProgressBar,
	label: Label,
	value: float,
	maximum: float,
	need_name: String
) -> void:
	bar.max_value = maximum
	bar.value = value
	var percentage := 0
	if maximum > 0.0:
		percentage = roundi(value / maximum * 100.0)
	label.text = "%s %d%%" % [need_name, percentage]


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera_pivot.rotation.x = clamp(
			camera_pivot.rotation.x - event.relative.y * mouse_sensitivity,
			deg_to_rad(-75.0),
			deg_to_rad(75.0)
		)
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event is InputEventMouseButton and event.pressed and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _add_key_action(action: StringName, key: Key) -> void:
	if InputMap.has_action(action):
		return

	InputMap.add_action(action)
	var key_event := InputEventKey.new()
	key_event.physical_keycode = key
	InputMap.action_add_event(action, key_event)
