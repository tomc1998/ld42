extends RichTextLabel

const LIFETIME = 4.0
var death_timer = LIFETIME

func _process(delta):
  self.modulate.a = death_timer / LIFETIME
  self.rect_scale += Vector2(0.1, 0.1) * delta
  self.rect_position

  self.rect_position = get_viewport().size / 2 - (rect_size * rect_scale) / 2

  death_timer -= delta;
  if death_timer <= 0:
    queue_free()
    return

