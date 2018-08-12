extends RichTextLabel

const LIFETIME = 0.8
var death_timer = LIFETIME

func _process(delta):
  death_timer -= delta;
  if death_timer <= 0:
    queue_free()
    return

  self.rect_position.y -= 50.0 * delta

  self.modulate.a = death_timer / LIFETIME
