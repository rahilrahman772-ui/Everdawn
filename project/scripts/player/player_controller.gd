extends CharacterBody3D

const BERRY_RESTORE := 30.0
const WATER_RESTORE := 35.0

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
@onready var inventory_counts: Label = $HUD/InventoryCounts
@onready var inventory_panel: PanelContainer = $HUD/InventoryPanel
@onready var berries_count: Label = $HUD/InventoryPanel/InventoryLayout/ResourceGrid/BerriesCount
@onready var water_count: Label = $HUD/InventoryPanel/InventoryLayout/ResourceGrid/WaterCount
@onready var wood_count: Label = $HUD/InventoryPanel/InventoryLayout/ResourceGrid/WoodCount
@onready var stone_count: Label = $HUD/InventoryPanel/InventoryLayout/ResourceGrid/StoneCount
@onready var eat_berries_button: Button = $HUD/InventoryPanel/InventoryLayout/ItemActions/EatBerriesButton
@onready var drink_water_button: Button = $HUD/InventoryPanel/InventoryLayout/ItemActions/DrinkWaterButton
@onready var close_inventory_button: Button = $HUD/InventoryPanel/InventoryLayout/TitleRow/CloseButton
@onready var interaction_area: Area3D = $InteractionArea
@onready var interaction_prompt: Label = $HUD/InteractionPrompt
@onready var character_animator: CharacterAnimator = $CharacterAnimator

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var nearby_pickups: Array[ResourcePickup] = []
var inventory: Dictionary = {
	&"berries": 0,
	&"water": 0,
	&"wood": 0,
	&"stone": 0,
}


func _ready() -> void:
	_add_key_action(&"move_forward", KEY_W)
	_add_key_action(&"move_back", KEY_S)
	_add_key_action(&"move_left", KEY_A)
	_add_key_action(&"move_right", KEY_D)
	_add_key_action(&"jump", KEY_SPACE)
	_add_key_action(&"sprint", KEY_SHIFT)
	_add_key_action(&"interact", KEY_E)

	interaction_area.area_entered.connect(_on_pickup_entered)
	interaction_area.area_exited.connect(_on_pickup_exited)
	eat_berries_button.pressed.connect(_eat_berries)
	drink_water_button.pressed.connect(_drink_water)
	close_inventory_button.pressed.connect(_close_inventory)

	stamina_component.stamina_changed.connect(_on_stamina_changed)
	_on_stamina_changed(stamina_component.current_stamina, stamina_component.maximum_stamina)

	needs_component.needs_changed.connect(_on_needs_changed)
	_on_needs_changed(
		needs_component.current_hunger,
		needs_component.maximum_hunger,
		needs_component.current_thirst,
		needs_component.maximum_thirst
	)
	_update_inventory_display()

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	elif not inventory_panel.visible and Input.is_action_just_pressed(&"jump"):
		velocity.y = jump_velocity

	var input_direction := Vector2.ZERO
	if not inventory_panel.visible:
		input_direction = Input.get_vector(
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

	if inventory_panel.visible:
		velocity.x = 0.0
		velocity.z = 0.0
	else:
		velocity.x = move_toward(velocity.x, direction.x * speed, acceleration * delta)
		velocity.z = move_toward(velocity.z, direction.z * speed, acceleration * delta)

	move_and_slide()
	character_animator.set_locomotion(input_direction, is_sprinting, delta)


func collect_resource(item_id: StringName) -> void:
	inventory[item_id] = int(inventory.get(item_id, 0)) + 1
	_update_inventory_display()


func _update_inventory_display() -> void:
	var berries := int(inventory.get(&"berries", 0))
	var water := int(inventory.get(&"water", 0))
	var wood := int(inventory.get(&"wood", 0))
	var stone := int(inventory.get(&"stone", 0))
	inventory_counts.text = "I  |  Berries %d  ·  Water %d  ·  Wood %d  ·  Stone %d" % [
		berries, water, wood, stone,
	]
	berries_count.text = "Berries       %d" % berries
	water_count.text = "Water         %d" % water
	wood_count.text = "Wood          %d" % wood
	stone_count.text = "Stone         %d" % stone
	eat_berries_button.disabled = berries == 0
	drink_water_button.disabled = water == 0


func _eat_berries() -> void:
	if int(inventory.get(&"berries", 0)) <= 0:
		return
	inventory[&"berries"] -= 1
	needs_component.restore_hunger(BERRY_RESTORE)
	_update_inventory_display()


func _drink_water() -> void:
	if int(inventory.get(&"water", 0)) <= 0:
		return
	inventory[&"water"] -= 1
	needs_component.restore_thirst(WATER_RESTORE)
	_update_inventory_display()


func _toggle_inventory() -> void:
	inventory_panel.visible = not inventory_panel.visible
	Input.mouse_mode = (
		Input.MOUSE_MODE_VISIBLE if inventory_panel.visible else Input.MOUSE_MODE_CAPTURED
	)


func _close_inventory() -> void:
	inventory_panel.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


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
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_I:
		_toggle_inventory()
		get_viewport().set_input_as_handled()
		return

	if inventory_panel.visible:
		if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
			_close_inventory()
			get_viewport().set_input_as_handled()
		return

	if event is InputEventKey and event.pressed and event.keycode == KEY_E:
		_interact_with_nearest_pickup()
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
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


func _on_pickup_entered(area: Area3D) -> void:
	if area is ResourcePickup and not nearby_pickups.has(area):
		nearby_pickups.append(area)
		_update_interaction_prompt()


func _on_pickup_exited(area: Area3D) -> void:
	if area is ResourcePickup:
		nearby_pickups.erase(area)
		_update_interaction_prompt()


func _update_interaction_prompt() -> void:
	var pickup := _nearest_pickup()
	interaction_prompt.visible = pickup != null
	if pickup != null:
		interaction_prompt.text = "E  -  Pick up %s" % pickup.display_name


func _interact_with_nearest_pickup() -> void:
	var pickup := _nearest_pickup()
	if pickup != null:
		pickup.interact(self)
		nearby_pickups.erase(pickup)
		_update_interaction_prompt()


func _nearest_pickup() -> ResourcePickup:
	var closest: ResourcePickup = null
	var closest_distance := INF
	for pickup: ResourcePickup in nearby_pickups:
		if not is_instance_valid(pickup):
			continue
		var distance := global_position.distance_squared_to(pickup.global_position)
		if distance < closest_distance:
			closest = pickup
			closest_distance = distance
	return closest


func _add_key_action(action: StringName, key: Key) -> void:
	if InputMap.has_action(action):
		return

	InputMap.add_action(action)
	var key_event := InputEventKey.new()
	key_event.physical_keycode = key
	InputMap.action_add_event(action, key_event)
