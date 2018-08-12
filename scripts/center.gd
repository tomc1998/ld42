extends Control

func _process(delta):
  self.rect_position.x = get_viewport().size.x / 2 - rect_size.x / 2

func _ready():
  self.rect_position.x = get_viewport().size.x / 2 - rect_size.x / 2
  
