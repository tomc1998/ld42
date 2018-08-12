extends Label

onready var score = get_node("/root/score")

var unicode_text = []

func _ready():
  self.rect_position = get_viewport().size / 2 - rect_size / 2
  set_process_input(true)

func rebuild_text():
  self.text = ""
  for c in unicode_text:
    self.text += char(c)

func _input(event):
  if event is InputEventKey && event.pressed:
    if event.scancode == KEY_BACKSPACE && unicode_text.size() > 0:
      unicode_text.remove(unicode_text.size()-1)
    elif event.scancode == KEY_ENTER:
      score.add_highscore(self.text)
      get_tree().change_scene("res://scenes/ui/Highscores.tscn")
    elif event.unicode != 0:
      unicode_text.append(event.unicode)
    rebuild_text()
