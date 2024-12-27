extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 6.5
var sensitivity = 0.25
var is_mouse_input_enabled = true
var sun_blocked


@onready var pivot: Node3D = $Node3D
@onready var sun_check_cast_origin: Marker3D = $Marker3D
@onready var camera: Camera3D = $Node3D/Camera3D
@onready var directional_light: DirectionalLight3D = get_tree().get_root().get_node("Node3D/DirectionalLight3D")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event):
	if event is InputEventMouseMotion and is_mouse_input_enabled:
		rotate_y(deg_to_rad(-event.relative.x * sensitivity))
		pivot.rotate_x(deg_to_rad(-event.relative.y * sensitivity))
		pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-70), deg_to_rad(60))

func _process(delta: float) -> void:
	check_for_sun_visible()



func object_is_intersecting_sun():
	var space_state = get_world_3d().direct_space_state
	
	# Calculate the direction of the sun (ensure this is correct)
	var sun_direction = directional_light.global_transform.basis.z.normalized()
	var ray_origin = camera.global_position
	var ray_end = ray_origin + (sun_direction * 1000)
	
	# Create raycast parameters
	var parameters = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	parameters.exclude = [self]  # Exclude the player itself
	parameters.collide_with_bodies = true
	parameters.collision_mask = 2  # Only detect objects on layer 2

	# Perform the raycast
	var ray_result = space_state.intersect_ray(parameters)
	
	# Debugging - print raycast hit info
	if ray_result.size() > 0:
		var collider = ray_result["collider"]
		print("Hit object: ", collider.name)
		
		# If we hit an object other than the ground, return true
		if collider.name != "StaticBody3D":
			return true
	
	return false


func check_for_sun_visible():
	sun_blocked = object_is_intersecting_sun()
	print("Sun blocked state: ", sun_blocked)  # Debug print


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var direction = Vector3.ZERO 

	if Input.is_key_pressed(KEY_W):
		direction -= transform.basis.z
	if Input.is_key_pressed(KEY_S):
		direction += transform.basis.z
	if Input.is_key_pressed(KEY_A):
		direction -= transform.basis.x
	if Input.is_key_pressed(KEY_D):
		direction += transform.basis.x

	direction.y = 0 
	direction = direction.normalized()
	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED

	if Input.is_key_pressed(KEY_SHIFT):
		velocity.x *= 2
		velocity.z *= 2

	velocity.y -= 9.8 * delta * 2  # Adjust this value based on your gravity setting

	move_and_slide()
