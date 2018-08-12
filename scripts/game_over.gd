extends RichTextLabel

onready var score = get_node("/root/score")

const LIFETIME = 3.0
var death_timer = LIFETIME

func _process(delta):
  self.modulate.a = death_timer / LIFETIME
  self.rect_scale += Vector2(0.1, 0.1) * delta
  self.rect_position

  self.rect_position = get_viewport().size / 2 - (rect_size * rect_scale) / 2

  death_timer -= delta;
  if death_timer <= 0:
    # Check if we exceed the current highscores
    if score.is_current_score_highscore():
      get_tree().change_scene("res://scenes/ui/EnterHighscore.tscn")
    else:
      get_tree().change_scene("res://scenes/ui/Highscores.tscn")


func _ready():
  get_node("/root/Music").stop()