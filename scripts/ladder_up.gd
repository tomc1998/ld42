extends StaticBody2D

var confirm

onready var score = get_node("/root/score")
onready var player = get_node("/root/World/Player")
onready var ui_layer = get_node("/root/World/UILayer")
onready var dungeon_generator = get_node("/root/World/DungeonGenerator")

func _ready():
  get_node("Hitbox").connect("body_entered", self, "on_body_entered")

func on_body_entered(body):
  if body == player:
    var ui_confirm = load("res://scenes/ui/LeaveLevelConfirm.tscn").instance()
    ui_confirm.connect("leave", self, "on_leave")
    ui_layer.add_child(ui_confirm)

func on_leave():
  score.level += 1
  dungeon_generator.gen_level()
