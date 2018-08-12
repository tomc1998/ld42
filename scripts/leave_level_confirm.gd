extends ColorRect

signal leave
signal stay

func _ready():
  get_tree().paused = true
  self.rect_position = get_viewport().size / 2 - rect_size / 2
  set_process_input(true)
  
func _input(event):
  if event is InputEventKey:
    if event.scancode == KEY_SPACE:
      get_tree().paused = false
      queue_free()
      emit_signal("leave")
    elif event.scancode == KEY_ESCAPE:
      get_tree().paused = false
      queue_free()
      emit_signal("stay")