extends Node

onready var score = get_node("/root/score")

func _ready():
  score.reset()

func _enter_tree():
  if score != null: score.reset()

