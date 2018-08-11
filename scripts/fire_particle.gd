extends Sprite

const LIFETIME = 0.4
const DAMPING = 400.0

var death_timer = LIFETIME
var vel = Vector2(0, 0)

func _process(delta):
  death_timer -= delta;
  if death_timer <= 0:
    queue_free()
    return

  self.modulate.a = death_timer / LIFETIME

  # Damp
  var speed = self.vel.length();
  self.vel = (self.vel / speed) * (speed - DAMPING * delta)

  self.position += vel * delta

func _set_vel(vel):
  self.vel = vel
  self.rotation = vel.angle()
