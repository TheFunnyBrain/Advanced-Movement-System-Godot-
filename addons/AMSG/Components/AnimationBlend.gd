extends AnimationTree
class_name AnimBlend
@onready @export var movement_script : CharacterMovementComponent  # I use this to get variables from main movement script

func _physics_process(_delta):
	if !movement_script:
		return

	#Set Animation State
	match movement_script.movement_state:
		Global.movement_state.none:
			pass
		Global.movement_state.grounded:
			print("ground")
			set("parameters/InAir/blend_amount" , false)
		Global.movement_state.in_air:
			print("air")
			set("parameters/InAir/blend_amount" , true)
		Global.movement_state.mantling:
			pass
		Global.movement_state.ragdoll:
			pass
	#Couch/stand switch
	match movement_script.stance: 
		Global.stance.standing:
			set("parameters/VelocityDirection/crouch/current" ,0)
		Global.stance.crouching:
			set("parameters/VelocityDirection/crouch/current" ,1)

	#standing
	set("parameters/VelocityDirection/standing/conditions/idle",!movement_script.input_is_moving)
	set("parameters/VelocityDirection/standing/conditions/walking",movement_script.gait == Global.gait.walking and movement_script.input_is_moving)
	set("parameters/VelocityDirection/standing/conditions/running",movement_script.gait == Global.gait.running and movement_script.input_is_moving)
	set("parameters/VelocityDirection/standing/conditions/sprinting",movement_script.gait == Global.gait.sprinting and movement_script.input_is_moving)


	if movement_script.rotation_mode == Global.rotation_mode.looking_direction or movement_script.rotation_mode == Global.rotation_mode.aiming:
		if movement_script.animation_is_moving_backward_relative_to_camera == false:
			set("parameters/VelocityDirection/standing/Walk/FB/current",0)
			set("parameters/VelocityDirection/standing/Jog/FB/current",0)
		else:
			set("parameters/VelocityDirection/standing/Walk/FB/current",1)
			set("parameters/VelocityDirection/standing/Jog/FB/current",1)
	else:
		set("parameters/VelocityDirection/standing/Walk/FB/current",0)
		set("parameters/VelocityDirection/standing/Jog/FB/current",0)
	# Crouching
	set("parameters/VelocityDirection/crouching/conditions/idle",!movement_script.input_is_moving)
	set("parameters/VelocityDirection/crouching/conditions/walking",movement_script.gait == Global.gait.walking and movement_script.input_is_moving)

	#On Stopped
	if !(Input.is_action_pressed("forward") || Input.is_action_pressed("back") || Input.is_action_pressed("right") || Input.is_action_pressed("left")) and (Input.is_action_just_released("right") || Input.is_action_just_released("back") || Input.is_action_just_released("left") || Input.is_action_just_released("forward")):

		var seek_time = get_node(anim_player).get_animation(tree_root.get_node("VelocityDirection").get_node("standing").get_node("Stopping").get_node("StopAnim").animation).length - movement_script.pose_warping_instance.CalculateStopTime((movement_script.actual_velocity * Vector3(1.0,0.0,1.0)),movement_script.deacceleration * movement_script.direction)
		set("parameters/VelocityDirection/standing/Stopping/StopSeek/seek_position",seek_time)
	set("parameters/VelocityDirection/standing/conditions/stop",!movement_script.input_is_moving)

	#Rotate In Place
	set("parameters/Turn/blend_amount" , 1 if movement_script.is_rotating_in_place else 0)
	set("parameters/RightOrLeft/blend_amount" ,0 if movement_script.rotation_difference_camera_mesh > 0 else 1)




