extends Node2D

const HighscoreNode = preload("res://scenes/ui/Highscore.tscn")
onready var score = get_node("/root/score")

func _ready():
  set_process_input(true)
  var curr_y = 160.0;
  for h in score.highscores:
    var hn = HighscoreNode.instance()
    hn.highscore = h
    hn.position.y = curr_y
    add_child(hn)
    curr_y += 50.0

func _input(event):
  if event is InputEventKey && event.pressed:
    if event.scancode == KEY_SPACE:
      get_tree().change_scene("res://scenes/World.tscn")