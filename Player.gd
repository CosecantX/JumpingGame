extends KinematicBody2D

onready var line = $Line2D

signal jumped
signal started
signal attractor_entered

export var gravity = 20
export var min_swipe_dist = 20
export var max_swipe_dist = 500
export var move_speed_multiplier = 2.5
export var drag_multiplier = 0.5
export var rotation_multiplier = 0.0001
export var bounce_multiplier = 0.5
export var attractor_multiplier = 0.9
export var min_vel_for_movement = 10

var _velocity = Vector2.ZERO
var _swipe_start_pos
var _swipe_end_pos
var _swipe
var _ready_for_input = false
var _inside_attractor = false
var _started = false

func _ready():
	Global.set_player(self)

func _physics_process(delta):
	if not _inside_attractor:
		_velocity.y += gravity
	else:
		_velocity *= attractor_multiplier
	
	if global_position.x < 0:
		global_position.x = get_viewport_rect().size.x
	elif global_position.x > get_viewport_rect().size.x:
		global_position.x = 0
	
	$Sprite.rotation += _velocity.x * rotation_multiplier
	
	var collision = move_and_collide(_velocity * delta)
	if collision:
		_velocity = _velocity.bounce(collision.normal) * bounce_multiplier

	if abs(_velocity.y) < min_vel_for_movement and abs(_velocity.x) < min_vel_for_movement:
		_ready_for_input = true
	else:
		_ready_for_input = false 

func _input(event):
	if event is InputEventScreenTouch and event.pressed:
		_swipe_start_pos = get_global_mouse_position()
	if _ready_for_input:
		if event is InputEventScreenDrag:
			line.clear_points()
			line.add_point(to_local(global_position))
			var _drag = (_swipe_start_pos - event.position)
			_drag = _drag.clamped(max_swipe_dist) * drag_multiplier
			line.add_point(_drag)
		if event is InputEventScreenTouch and not event.pressed:
			line.clear_points()
			_swipe_end_pos = get_global_mouse_position()
			var dist = _swipe_start_pos.distance_to(_swipe_end_pos)
			if dist > min_swipe_dist:
				_swipe = _swipe_start_pos - _swipe_end_pos
				_swipe = _swipe.clamped(max_swipe_dist)
				var _temp = _swipe * move_speed_multiplier
				_velocity += _temp
				emit_signal("jumped", self)

func attract_to(pos, force):
	var dist = global_position.distance_to(pos)
	var v = global_position.direction_to(pos) * force
	v = v.clamped(dist)
	_velocity += v

func _on_Attractor_body_entered(body):
	if body == self:
		_inside_attractor = true
	if not _started:
		_started = true
		emit_signal("started")
	emit_signal("attractor_entered")

func _on_Attractor_body_exited(body):
	if body == self:
		_inside_attractor = false
