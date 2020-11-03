extends Node

var player = null

func set_player(p):
	if p:
		player = p
	else:
		print("no node to set")

func get_player():
	if player:
		return player
	else:
		print("player not set")

func rand_rect(rect):
	randomize()
	var x = rand_range(rect.position.x, rect.end.x)
	var y = rand_range(rect.position.y, rect.end.y)
	return Vector2(x, y)
