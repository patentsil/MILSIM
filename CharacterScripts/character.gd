extends CharacterBody3D
class_name Character

@onready var camera = $Camera3D
@onready var name_billboard = $Sprite3D/SubViewport/Label
@onready var sprite3d = $Sprite3D
@export var player: Player = null
@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5
var wasPeerIdSet = false
var peer_id := 0
var input_dir = null
var look_sensitivity = ProjectSettings.get_setting("player/look_sensitivity") / 1000

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _process(delta):
	input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")

func _physics_process(delta):
	if not str(peer_id) == str(multiplayer.get_unique_id()): return
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction = null
	if input_dir:
		direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		input_dir = Vector3()
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
	pass
	
@rpc("any_peer")
func set_peer_id(value):
	peer_id = value
	print("Peer id was set to " + str(peer_id))

@rpc("any_peer")
func set_camera(_peer_id):
	if str(_peer_id) == str(multiplayer.get_unique_id()):
		print("Found the correct camera for " + str(multiplayer.get_unique_id()))
		$Camera3D.current = true
		set_multiplayer_authority(_peer_id, true)
	else:
		print("Camera was for " + str(_peer_id) + " and not for " + str(multiplayer.get_unique_id()))	

@rpc("any_peer")
func get_peer_id():
	if multiplayer.is_server():
		print("Server received request from client to set the peer_id")
		set_peer_id.rpc_id(peer_id, peer_id)
		set_multiplayer_authority(peer_id, true)
		# $MultiplayerSynchronizer.set_multiplayer_authority(peer_id, true)
		set_camera.rpc_id(peer_id, peer_id)

func _ready():
	if multiplayer.is_server():
		pass
		#print("This is running on a server")
		#print("Server is calling rpc to set peer_id to " + str(peer_id))
		#set_peer_id.rpc_id(peer_id, peer_id)
	else:
		print("This is running on a client")
		# Should ask for a peer_id
		get_peer_id.rpc()
		
	#if multiplayer.is_server():
	#print("Character " + str(peer_id) + " ready")
	#print("But the actual peer_id is " + str(multiplayer.get_unique_id()))

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if name_billboard:
		name_billboard.text = name
	var makePokeStickVisibleFunc = func():
		await get_tree().create_timer(0.05).timeout
		if not str(peer_id) == str(multiplayer.get_unique_id()):
			$Camera3D/PokeStick.visible = true
	
	makePokeStickVisibleFunc.call_deferred()
	

func attachTouchedObjects():
	# This should attach the objects that are touching the PokeStick to it.
	pass

func _input(event):
	if not str(peer_id) == str(multiplayer.get_unique_id()): return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * look_sensitivity)
		camera.rotate_x(-event.relative.y * look_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
	elif event is InputEventMouseButton and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		pass
		# $Camera3D/PokeStick
