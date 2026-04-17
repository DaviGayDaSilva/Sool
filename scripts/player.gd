extends CharacterBody3D
class_name SoolPlayer

signal health_changed(value: int)
signal died(player_id: int)

@export var speed: float = 8.0
@export var jump_velocity: float = 6.0
@export var mouse_sens: float = 0.002
@export var max_health: int = 100

var health: int = max_health
var gravity := ProjectSettings.get_setting("physics/3d/default_gravity") as float
var is_local_player := false
var player_id := 1

var touch_move_input := Vector2.ZERO
var touch_shoot_pressed := false
var touch_jump_pressed := false

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var muzzle: Marker3D = $Head/Camera3D/Muzzle
@onready var fire_rate: Timer = $FireRate

func _ready() -> void:
    if not OS.has_feature("android") and not OS.has_feature("ios"):
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    fire_rate.wait_time = 0.2
    fire_rate.one_shot = true

func configure(id: int, local_player: bool) -> void:
    player_id = id
    is_local_player = local_player
    camera.current = local_player

func set_touch_move(value: Vector2) -> void:
    touch_move_input = value

func add_touch_look(delta: Vector2) -> void:
    if not is_local_player:
        return
    rotate_y(-delta.x)
    head.rotate_x(-delta.y)
    head.rotation.x = clamp(head.rotation.x, deg_to_rad(-85), deg_to_rad(85))

func set_touch_actions(shoot_pressed: bool, jump_pressed: bool) -> void:
    touch_shoot_pressed = shoot_pressed
    touch_jump_pressed = jump_pressed

func _unhandled_input(event: InputEvent) -> void:
    if not is_local_player:
        return

    if event is InputEventMouseMotion:
        rotate_y(-event.relative.x * mouse_sens)
        head.rotate_x(-event.relative.y * mouse_sens)
        head.rotation.x = clamp(head.rotation.x, deg_to_rad(-85), deg_to_rad(85))

    if event.is_action_pressed("ui_cancel"):
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta: float) -> void:
    if not is_local_player:
        return

    if not is_on_floor():
        velocity.y -= gravity * delta

    var keyboard_input := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
    var movement_input := keyboard_input
    if touch_move_input.length() > 0.05:
        movement_input = touch_move_input

    var direction := (transform.basis * Vector3(movement_input.x, 0, movement_input.y)).normalized()
    velocity.x = direction.x * speed
    velocity.z = direction.z * speed

    if (Input.is_action_just_pressed("jump") or touch_jump_pressed) and is_on_floor():
        velocity.y = jump_velocity

    if (Input.is_action_pressed("shoot") or touch_shoot_pressed) and fire_rate.is_stopped():
        shoot()

    move_and_slide()

func shoot() -> void:
    fire_rate.start()
    var from := camera.global_position
    var to := from + -camera.global_transform.basis.z * 120

    var ray := PhysicsRayQueryParameters3D.create(from, to)
    ray.exclude = [self]

    var hit := get_world_3d().direct_space_state.intersect_ray(ray)
    if hit.has("collider"):
        var collider = hit["collider"]
        if collider != null and collider.has_method("apply_damage"):
            collider.apply_damage.rpc_id(1, 20, player_id)

@rpc("authority", "call_local", "reliable")
func apply_damage(amount: int, from_player: int = -1) -> void:
    health = max(0, health - amount)
    health_changed.emit(health)
    if health == 0:
        died.emit(from_player)
        global_position = Vector3(0, 1.5, 0)
        health = max_health
        health_changed.emit(health)
