extends Node2D

const Chest = preload("res://scenes/Chest.tscn")
const Slime = preload("res://scenes/Slime.tscn")
const GoblinArcher = preload("res://scenes/GoblinArcher.tscn")

const challenge = {
  Slime: 0,
  GoblinArcher: 2
}

onready var score = get_node("/root/score")
var does_spawn_monsters = true

# Given a type of monster (a scene to instance), spawn that number of them
# around the position in a regular shape.
func _spawn_in_shape(type, num, position=Vector2(0,0), radius=100.0):
  if num == 0: return
  var angle = 0.0;
  var step = PI * 2 / num
  for i in num:
    var monster = type.instance()
    monster.position = position + Vector2(cos(angle), sin(angle)) * radius
    add_child(monster)
    angle += step

func _spawn_monsters():
  if rand_range(0, 1) < 0.1: return # Sometimes jus tmake an empty room
  var monster_types = [Slime]
  if score.level >= challenge[GoblinArcher]:
    monster_types.append(GoblinArcher)

  var monster_type = monster_types[floor(rand_range(0, monster_types.size()))]
  var num = floor(rand_range(1, score.level - challenge[monster_type] + 2))
  _spawn_in_shape(monster_type, num)

func _spawn_treasure():
  if rand_range(0, 1) < 0.2:
    var chest = Chest.instance()
    add_child(chest)

func _ready():
  if does_spawn_monsters:
    _spawn_monsters()
    _spawn_treasure()