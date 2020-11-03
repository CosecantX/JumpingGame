extends Area2D

export var attraction_force = 100

var _attracted_objects = []

func change_radius(rad):
	$CollisionShape2D.shape.radius = rad

func _on_Attractor_body_entered(body):
	if body.is_in_group("Player"):
		_attracted_objects.append(body)

func _on_Attractor_body_exited(body):
	if body.is_in_group("Player"):
		_attracted_objects.remove(_attracted_objects.find(body))

func _physics_process(_delta):
	for i in _attracted_objects:
		if i.has_method("attract_to"):
			i.attract_to(global_position, attraction_force)

func _on_Player_jumped(body):
	if _attracted_objects.find(body) != -1:
		queue_free()
