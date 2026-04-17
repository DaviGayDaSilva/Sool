extends CharacterBody3D
class_name SoolBot

@export var speed := 4.0
@export var max_health := 60

var health := max_health
var gravity := ProjectSettings.get_setting("physics/3d/default_gravity") as float
var target: Node3D
var shoot_cooldown := 0.0

func _physics_process(delta: float) -> void:
    if not is_multiplayer_authority():
        return

    if not is_on_floor():
        velocity.y -= gravity * delta

    acquire_target()
    if target != null:
        var direction := (target.global_position - global_position)
        direction.y = 0
        direction = direction.normalized()
        velocity.x = direction.x * speed
        velocity.z = direction.z * speed
        look_at(target.global_position, Vector3.UP)

        shoot_cooldown -= delta
        if shoot_cooldown <= 0.0 and global_position.distance_to(target.global_position) < 35:
            shoot_cooldown = 0.8
            if target.has_method("apply_damage"):
                target.apply_damage.rpc_id(1, 8, -1)

    move_and_slide()

func acquire_target() -> void:
    var best_distance := INF
    target = null
    for candidate in get_tree().get_nodes_in_group("players"):
        if not candidate is Node3D:
            continue
        var distance := global_position.distance_to(candidate.global_position)
        if distance < best_distance:
            best_distance = distance
            target = candidate

@rpc("authority", "call_local", "reliable")
func apply_damage(amount: int, _from_player: int = -1) -> void:
    health = max(0, health - amount)
    if health == 0:
        health = max_health
        global_position = Vector3(randf_range(-25, 25), 1.5, randf_range(-25, 25))
