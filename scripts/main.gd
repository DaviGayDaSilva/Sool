extends Node3D

const PLAYER_SCENE := preload("res://scripts/player_scene.tscn")
const BOT_SCENE := preload("res://scripts/bot_scene.tscn")

const TOUCH_MOVE_RADIUS := 110.0
const TOUCH_LOOK_SENS := 0.004

var players: Dictionary = {}
var world_root: Node3D
var hud: CanvasLayer
var status_label: Label
var health_label: Label

var touch_enabled := false
var touch_move := Vector2.ZERO
var touch_shoot := false
var touch_jump := false
var touch_left_id := -1
var touch_right_id := -1
var touch_left_origin := Vector2.ZERO

func _ready() -> void:
    randomize()
    setup_ui()
    setup_world()
    setup_touch_controls()
    show_menu()

func _process(_delta: float) -> void:
    var local_player := get_local_player()
    if local_player != null:
        local_player.set_touch_move(touch_move)
        local_player.set_touch_actions(touch_shoot, touch_jump)

func _input(event: InputEvent) -> void:
    if not touch_enabled:
        return

    if event is InputEventScreenTouch:
        handle_screen_touch(event)

    if event is InputEventScreenDrag:
        handle_screen_drag(event)

func handle_screen_touch(event: InputEventScreenTouch) -> void:
    if event.pressed:
        if event.position.x < get_viewport().get_visible_rect().size.x * 0.5 and touch_left_id == -1:
            touch_left_id = event.index
            touch_left_origin = event.position
        elif event.position.x >= get_viewport().get_visible_rect().size.x * 0.5 and touch_right_id == -1:
            touch_right_id = event.index
    else:
        if event.index == touch_left_id:
            touch_left_id = -1
            touch_move = Vector2.ZERO
        if event.index == touch_right_id:
            touch_right_id = -1

func handle_screen_drag(event: InputEventScreenDrag) -> void:
    if event.index == touch_left_id:
        var delta := event.position - touch_left_origin
        touch_move = delta.limit_length(TOUCH_MOVE_RADIUS) / TOUCH_MOVE_RADIUS
    elif event.index == touch_right_id:
        var local_player := get_local_player()
        if local_player != null:
            local_player.add_touch_look(event.relative * TOUCH_LOOK_SENS)

func setup_touch_controls() -> void:
    touch_enabled = OS.has_feature("android") or OS.has_feature("ios") or DisplayServer.is_touchscreen_available()
    if not touch_enabled:
        return

    var shoot_button := Button.new()
    shoot_button.text = "ATIRAR"
    shoot_button.size = Vector2(150, 84)
    shoot_button.position = Vector2(get_viewport().get_visible_rect().size.x - 170, get_viewport().get_visible_rect().size.y - 110)
    shoot_button.modulate = Color(1, 0.2, 0.2, 0.75)
    shoot_button.button_down.connect(func(): touch_shoot = true)
    shoot_button.button_up.connect(func(): touch_shoot = false)
    hud.add_child(shoot_button)

    var jump_button := Button.new()
    jump_button.text = "PULAR"
    jump_button.size = Vector2(150, 84)
    jump_button.position = Vector2(get_viewport().get_visible_rect().size.x - 340, get_viewport().get_visible_rect().size.y - 110)
    jump_button.modulate = Color(0.2, 0.45, 1, 0.75)
    jump_button.button_down.connect(func(): touch_jump = true)
    jump_button.button_up.connect(func(): touch_jump = false)
    hud.add_child(jump_button)

    var left_hint := Label.new()
    left_hint.text = "Arraste aqui para mover"
    left_hint.position = Vector2(24, get_viewport().get_visible_rect().size.y - 44)
    hud.add_child(left_hint)

    var right_hint := Label.new()
    right_hint.text = "Arraste aqui para mirar"
    right_hint.position = Vector2(get_viewport().get_visible_rect().size.x - 260, get_viewport().get_visible_rect().size.y - 44)
    hud.add_child(right_hint)

func setup_ui() -> void:
    hud = CanvasLayer.new()
    add_child(hud)

    var panel := PanelContainer.new()
    panel.size = Vector2(380, 220)
    panel.position = Vector2(24, 24)
    hud.add_child(panel)

    var vbox := VBoxContainer.new()
    panel.add_child(vbox)

    status_label = Label.new()
    status_label.text = "Sool - FPS inspirado em Doom"
    vbox.add_child(status_label)

    var btn_single := Button.new()
    btn_single.text = "Single-player com bots"
    btn_single.pressed.connect(start_single_player)
    vbox.add_child(btn_single)

    var btn_host := Button.new()
    btn_host.text = "Host Multiplayer (LAN)"
    btn_host.pressed.connect(host_multiplayer)
    vbox.add_child(btn_host)

    var btn_join := Button.new()
    btn_join.text = "Entrar em 127.0.0.1"
    btn_join.pressed.connect(join_multiplayer)
    vbox.add_child(btn_join)

    health_label = Label.new()
    health_label.text = "HP: 100"
    health_label.position = Vector2(20, 260)
    hud.add_child(health_label)

func setup_world() -> void:
    world_root = Node3D.new()
    add_child(world_root)

    var sun := DirectionalLight3D.new()
    sun.rotation = Vector3(-0.9, 0.6, 0)
    world_root.add_child(sun)

    var env := WorldEnvironment.new()
    env.environment = Environment.new()
    env.environment.background_mode = Environment.BG_COLOR
    env.environment.background_color = Color(0.08, 0.05, 0.05)
    world_root.add_child(env)

    var floor := StaticBody3D.new()
    world_root.add_child(floor)

    var floor_mesh := MeshInstance3D.new()
    floor_mesh.mesh = BoxMesh.new()
    floor_mesh.mesh.size = Vector3(90, 1, 90)
    floor_mesh.position.y = -0.5
    floor_mesh.material_override = make_material(Color(0.12, 0.12, 0.12))
    floor.add_child(floor_mesh)

    var floor_col := CollisionShape3D.new()
    floor_col.shape = BoxShape3D.new()
    floor_col.shape.size = Vector3(90, 1, 90)
    floor_col.position.y = -0.5
    floor.add_child(floor_col)

    for i in range(18):
        spawn_pillar(Vector3(randf_range(-35, 35), 2.5, randf_range(-35, 35)))

func spawn_pillar(pos: Vector3) -> void:
    var pillar := StaticBody3D.new()
    world_root.add_child(pillar)

    var mesh := MeshInstance3D.new()
    mesh.mesh = CylinderMesh.new()
    mesh.mesh.height = 5
    mesh.mesh.top_radius = 1.1
    mesh.mesh.bottom_radius = 1.1
    mesh.material_override = make_material(Color(0.35, 0.1, 0.1))
    pillar.add_child(mesh)

    var col := CollisionShape3D.new()
    col.shape = CylinderShape3D.new()
    col.shape.height = 5
    col.shape.radius = 1.1
    pillar.add_child(col)

    pillar.position = pos

func make_material(color: Color) -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 0.8
    return mat

func show_menu() -> void:
    status_label.text = "Sool pronto: escolha um modo"

func start_single_player() -> void:
    cleanup_match()
    status_label.text = "Single-player iniciado (8 bots)"
    var local_id := 1
    spawn_player(local_id, true)
    for i in range(8):
        spawn_bot(i)

func host_multiplayer() -> void:
    cleanup_match()
    var peer := ENetMultiplayerPeer.new()
    var err := peer.create_server(7777, 8)
    if err != OK:
        status_label.text = "Falha ao criar host"
        return

    multiplayer.multiplayer_peer = peer
    multiplayer.peer_connected.connect(_on_peer_connected)
    multiplayer.peer_disconnected.connect(_on_peer_disconnected)
    status_label.text = "Host online em 0.0.0.0:7777"

    spawn_player(multiplayer.get_unique_id(), true)
    for i in range(6):
        spawn_bot(i)

func join_multiplayer() -> void:
    cleanup_match()
    var peer := ENetMultiplayerPeer.new()
    var err := peer.create_client("127.0.0.1", 7777)
    if err != OK:
        status_label.text = "Falha ao conectar"
        return

    multiplayer.multiplayer_peer = peer
    status_label.text = "Conectando no host..."
    await multiplayer.connected_to_server
    spawn_player(multiplayer.get_unique_id(), true)

func _on_peer_connected(id: int) -> void:
    spawn_player(id, false)

func _on_peer_disconnected(id: int) -> void:
    if players.has(id):
        players[id].queue_free()
        players.erase(id)

func spawn_player(id: int, is_local: bool) -> void:
    if players.has(id):
        return

    var player: SoolPlayer = PLAYER_SCENE.instantiate()
    player.name = "Player_%s" % id
    player.global_position = Vector3(randf_range(-8, 8), 1.6, randf_range(-8, 8))
    player.configure(id, is_local)
    player.health_changed.connect(_on_health_changed)
    player.died.connect(_on_player_died)
    player.add_to_group("players")
    world_root.add_child(player)
    players[id] = player

func spawn_bot(index: int) -> void:
    var bot: SoolBot = BOT_SCENE.instantiate()
    bot.name = "Bot_%s" % index
    bot.global_position = Vector3(randf_range(-25, 25), 1.6, randf_range(-25, 25))
    world_root.add_child(bot)

func _on_health_changed(value: int) -> void:
    health_label.text = "HP: %s" % value

func _on_player_died(from_player: int) -> void:
    if from_player == -1:
        status_label.text = "Você morreu para um bot!"
    else:
        status_label.text = "Você morreu para o Player %s" % from_player

func get_local_player() -> SoolPlayer:
    for value in players.values():
        var player := value as SoolPlayer
        if player != null and player.is_local_player:
            return player
    return null

func cleanup_match() -> void:
    touch_move = Vector2.ZERO
    touch_shoot = false
    touch_jump = false
    touch_left_id = -1
    touch_right_id = -1

    for child in world_root.get_children():
        if child is StaticBody3D or child is DirectionalLight3D or child is WorldEnvironment:
            continue
        child.queue_free()

    players.clear()
    if multiplayer.multiplayer_peer != null:
        multiplayer.multiplayer_peer.close()
        multiplayer.multiplayer_peer = null
