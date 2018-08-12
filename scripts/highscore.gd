extends Node2D

const Highscore = preload("score.gd").Highscore

onready var label_name = get_node("Name")
onready var label_score = get_node("Score")

var highscore

func _process(delta):
  self.position.x = get_viewport().size.x / 2

func _ready():
  self.position.x = get_viewport().size.x / 2
  if highscore == null:
    highscore = Highscore.new("Test", 100000)
  label_name.text = highscore.name
  label_score.text = str(highscore.score)
  label_name.rect_position.x = -label_name.rect_size.x - 10.0
  label_score.rect_position.x = 10.0