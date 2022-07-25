extends KinematicBody

# mouse
var mouse_sensitivity = 0.5

# movment
var speed_base = 3
var movment_speed = speed_base

var acceleration_air = 3
var acceleration_ground = 24
var acceleration = acceleration_ground

var jump_strength = 10
var gravity = -40

var snap = Vector3.ZERO
var velocity_vertical = Vector3.ZERO
var velocity_horizontal = Vector3.ZERO
var direction_horizontal = Vector3.ZERO

# references
onready var head = $Head
onready var camera = $Head/Camera
var menu = preload("res://Interface/PauseMenu.tscn").instance()

func _ready():
	# lock mouse at start
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera.set_as_toplevel(true)
	add_child(menu)
	menu.visible = false

func _unhandled_input(event):
	# mouse input
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(deg2rad(-event.relative.x) * mouse_sensitivity)
		head.rotate_x(deg2rad(-event.relative.y) * mouse_sensitivity)
		head.rotation.x = clamp(head.rotation.x, deg2rad(-90), deg2rad(90))
		
	if Input.is_action_pressed("click_left"):
		var dir = Directory.new()
		dir.open(OS.get_executable_path().get_base_dir())
		dir.make_dir("screenshots")
		var image = get_tree().get_root().get_texture().get_data()
		image.flip_y()
		var screenshot_path = OS.get_executable_path().get_base_dir()+"/screenshots/"+String(OS.get_unix_time())+".png"
		image.save_png(screenshot_path)
		
	if Input.is_action_just_pressed("ui_cancel") and Input.get_mouse_mode()==Input.MOUSE_MODE_CAPTURED:
		menu.visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif Input.is_action_just_pressed("ui_cancel"):
		menu.visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	# handle movment inputs
	if is_on_floor():
		acceleration = acceleration_ground
		if Input.is_action_just_pressed("move_jump"):
			snap = Vector3.ZERO
			velocity_vertical.y += jump_strength
		else:
			snap = -get_floor_normal()
			velocity_vertical.y = 0
		
		if Input.is_action_just_pressed("move_sprint"):
			movment_speed *= 2
		
	else:
		acceleration = acceleration_air
		snap = Vector3.DOWN
		velocity_vertical.y += gravity * delta
	
	if Input.is_action_just_released("move_sprint"):
		movment_speed = speed_base
	
	if global_transform.origin.y < 0.5:
		snap = Vector3.ZERO
		velocity_vertical.y += 2
	
	direction_horizontal.z = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	direction_horizontal.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	direction_horizontal = transform.basis.xform(direction_horizontal) * movment_speed
	
	velocity_horizontal = velocity_horizontal.linear_interpolate(direction_horizontal, acceleration * delta)
	move_and_slide_with_snap(velocity_horizontal + velocity_vertical, snap, Vector3.UP)

func _process(delta):
	# camera smoothing
	camera.global_transform.origin = camera.global_transform.origin.linear_interpolate(head.global_transform.origin, Engine.iterations_per_second/2 * delta)
	camera.rotation.x = head.rotation.x
	camera.rotation.y = rotation.y
