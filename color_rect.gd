extends ColorRect

var sun_blocked: bool
var adjust_time: float = 0.15
@onready var directional_light: DirectionalLight3D = get_tree().get_root().get_node("Node3D/DirectionalLight3D")
@onready var camera: Camera3D = get_tree().get_root().get_node("Node3D/CharacterBody3D/Node3D/Camera3D")
@onready var player = get_tree().get_root().get_node("Node3D/CharacterBody3D")

func _process(delta: float) -> void:
	sun_blocked = player.sun_blocked
	
	# Get sun direction relative to camera
	var cam_forward = -camera.global_transform.basis.z
	var sun_direction = -directional_light.global_transform.basis.z
	
	# Check if sun is in front of camera (dot product < 0 means it's in front)
	var sun_in_view = cam_forward.dot(sun_direction) < 0
	
	if sun_blocked or !sun_in_view:
		fade_out_lens_flares()
	else:
		fade_in_lens_flares()
		# Calculate screen position of sun
		var sun_pos = camera.unproject_position(camera.global_position + sun_direction * 100)
		material.set_shader_parameter("sun_position", sun_pos)

func fade_in_lens_flares():
	var tween = create_tween()
	tween.tween_property(get_material(), "shader_parameter/tint", Vector3(1.4, 1.2, 1), adjust_time)

func fade_out_lens_flares():
	var tween = create_tween()
	tween.tween_property(get_material(), "shader_parameter/tint", Vector3(0, 0, 0), adjust_time)
