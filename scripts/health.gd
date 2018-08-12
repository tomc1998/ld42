extends Node2D

const HEART_TEXTURE = preload("res://assets/art/heart.png")

onready var player = get_node("/root/World/Player")

var hearts = []

func _process(delta):
  position.x = 4
  position.y = get_viewport().size.y - 20

func _ready():
  position.x = 4
  position.y = get_viewport().size.y - 20
  player.connect("health_changed", self, "health_changed")
  player.connect("max_health_changed", self, "max_health_changed")

  for i in range(player.max_health):
    var heart = Sprite.new()
    heart.texture = HEART_TEXTURE
    heart.hframes = 2
    heart.frame = 0
    heart.centered = false
    heart.position.x = i * 20
    heart.scale = Vector2(2, 2)
    hearts.append(heart)
    add_child(heart)

  print(player.max_health)
  health_changed(player.health)


func max_health_changed(max_health):
  for i in get_children():
    get_child(i).queue_free()
  hearts = []

  for i in range(player.max_health):
    var heart = Sprite.new()
    heart.texture = HEART_TEXTURE
    heart.hframes = 2
    heart.frame = 0
    if i >= player.health: heart.frame = 1
    heart.centered = false
    heart.position.x = i * 20
    heart.scale = Vector2(2, 2)
    hearts.append(heart)
    add_child(heart)

func health_changed(health):
  for i in range(hearts.size()):
    if i >= health: hearts[i].frame = 1
    else: hearts[i].frame = 0



