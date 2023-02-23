extends CharacterBody3D
class_name Character

@onready var camera = $Camera3D
@onready var name_billboard = $Sprite3D/SubViewport/Label
@onready var sprite3d = $Sprite3D
@export var player: Player = null
@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5
var look_sensitivity = ProjectSettings.get_setting("player/look_sensitivity") / 1000

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _enter_tree():
	set_multiplayer_authority(str(multiplayer.get_unique_id()).to_int())

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	if Input.is_action_just_pressed("interact_menu"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
func _init():
	print("Character " + name + " initializing")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _ready():
	if name_billboard:
		name_billboard.text = name
	if not sprite3d:
		print("Sprite3d is not yet set up")

func _input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * look_sensitivity)
		camera.rotate_x(-event.relative.y * look_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
