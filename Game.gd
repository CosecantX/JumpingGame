extends Node2D

onready var _player = Global.get_player()
onready var _score = $UI/Score

var _attractor_scene = preload("res://Attractor.tscn")

export var top_margin = 400
export var side_margin = 20
export var spacing = 50
export var length = 250
export var frames_num = 6
export var speed = 0
export var speed_inc = 0.001
export var delete_pos = 1110
export var speedup_pos = 500
export var speedup_speed = 1

onready var _view = get_viewport_rect()
var _frames = []
var _attractors = []
var _started = false

func _ready():
	_frames.append(Rect2(_view.position.x + side_margin, _view.position.y + top_margin, _view.size.x - side_margin - side_margin, length))
	for i in frames_num - 1:
		add_frame()

func _physics_process(_delta):
	var objects = $Objects.get_children()
	if _started:
		for i in objects:
			i.position.y += speed
			if i.position.y > delete_pos:
				i.queue_free()
		for i in _frames.size():
			_frames[i].position.y += speed
		speed += speed_inc
	
	if !_player:
		speed_inc = 0
	
	_score.text = "Score: " + str(speed * 1000)
	update()

func spawn_attractor(pos, size = 64):
	var a = _attractor_scene.instance()
	$Objects.add_child(a)
	a.global_position = pos
	a.change_radius(size)
	_player.connect("jumped", a, "_on_Player_jumped")
	a.connect("body_entered", _player, "_on_Attractor_body_entered")
	a.connect("body_exited", _player, "_on_Attractor_body_exited")

func add_frame():
	var i = _frames.size() - 1
	_frames.append(Rect2(_frames[i].position.x, _frames[i].position.y - length - spacing, _frames[i].size.x, length))
	spawn_attractor(Global.rand_rect(_frames[i]))

func _draw():
	for i in _frames:
		draw_rect(i, Color(1,1,1), false)
#		print(i.position.y)

func _on_Player_started():
	_started = true
	speed += .1

func _on_Player_attractor_entered():
	add_frame()
	print("frame added")
