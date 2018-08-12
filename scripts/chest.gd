extends StaticBody2D

const Player = preload("player.gd")
const Drops = preload("drops.gd")

onready var help_text = get_node("HelpText")
onready var world = get_node("/root/World")

const drops = [[Drops.Drops.STONE_BULLET], \
              [Drops.Drops.AIR_WAVE]]

var player_near = false
var opened = false

func _ready():
  self.get_node("Hitbox").connect("body_entered", self, "_body_entered")
  self.get_node("Hitbox").connect("body_exited", self, "_body_exited")
  help_text.visible = false

func _body_entered(body):
  if body is Player:
    player_near = true
    if !opened: help_text.visible = true

func _body_exited(body):
  if body is Player:
    player_near = true
    help_text.visible = false

func _input(event):
  if event is InputEventKey && event.pressed && event.scancode == KEY_SPACE \
      && !opened && player_near:
    opened = true
    get_node("Sprite").frame = 1
    get_node("SampleOpenChest").play()
    help_text.visible = false
    # Spawn drops
    var drop_types = drops[floor(rand_range(0, drops.size()))]
    for drop_type in drop_types:
      var drop = Drops.create_drop(drop_type)
      drop.position = self.global_position
      drop.drop_type = drop_type
      drop.choose_random_vel()
      world.add_child(drop)