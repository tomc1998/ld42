extends Node2D

const Slime = preload("res://scenes/Slime.tscn")
const GoblinArcher = preload("res://scenes/GoblinArcher.tscn")

var does_spawn_monsters = true

# Given a type of monster (a scene to instance), spawn that number of them
# around the position in a regular shape.
func _spawn_in_shape(type, num, position=Vector2(0,0), radius=100.0):
  var angle = 0.0;
  var step = PI * 2 / num
  for i in num:
    var monster = type.instance()
    monster.position = position + Vector2(cos(angle), sin(angle)) * radius
    add_child(monster)
    angle += step

func _spawn_monsters():
  var val = rand_range(0, 2)
  if val < 1:
    _spawn_in_shape(Slime, floor(rand_range(2, 7)))
  elif val < 2:
    _spawn_in_shape(GoblinArcher, floor(rand_range(1, 3)))

func _ready():
  if does_spawn_monsters: _spawn_monsters()