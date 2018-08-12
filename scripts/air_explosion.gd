extends Sprite

const LIFETIME = 0.2
var death_timer = LIFETIME

func _ready():
	pass

func _process(delta):
  death_timer -= delta;
  if death_timer <= 0:
    queue_free()
    return
  self.scale.x = 1 - (death_timer / LIFETIME)
  self.scale.y = 1 - (death_timer / LIFETIME)
  self.modulate.a = death_timer / LIFETIME
