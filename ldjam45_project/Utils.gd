extends Node

enum Type { ROCK, PAPER, SCISSORS }  

static func dist(a:Vector2, b:Vector2) -> float:
	var x := abs(a.y-b.y)*2 +abs(a.x-b.x)
	return x
	
static func normalize_to_dist(v:Vector2, to_dist:float) -> Vector2:
	v.y *=2
	v = v.normalized() * to_dist
	v.y /= 2
	return v
	
	
static func push_from(to_push:Vector2, push_from:Vector2, min_dist:float) -> Vector2:
	var distance: = dist(to_push, push_from)
	if distance < min_dist:
		return push_from + normalize_to_dist(to_push - push_from, min_dist)
	return to_push
	
static func wins(a:int, b:int) -> bool:
	return a == (b+1)%3
	
static func rand_dir() -> Vector2:
	return Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized()
	
static func rotated_rand_deg(base_vec:Vector2, range_deg:float):
	var angle: = deg2rad(rand_range(-range_deg, range_deg))
	return base_vec.rotated(angle)

static func rand_array(arr:Array):
	return arr[randi() % arr.size()]

static func clamp_to_rect(vec:Vector2, rect:Rect2):
	return Vector2(
			clamp(vec.x, rect.position.x, rect.position.x + rect.size.x),
			clamp(vec.y, rect.position.y, rect.position.y + rect.size.y))
			
static func bernoulli(x:float):
	return randf() < x