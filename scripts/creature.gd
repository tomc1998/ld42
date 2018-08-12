extends KinematicBody2D

# Additional force applied other than walking
var knockback = Vector2(0,0)

const PLAYER = 0
const ENEMY = 1

var faction = ENEMY

var normal_modulation

var max_health = 5
var health = max_health

# Call this from the subclass to apply knockback and damage tint
func _process(delta):
  move_and_slide(knockback)
  knockback *= 0.9

  if knockback.length_squared() > 100.0:
    self.modulate.r = 1
    self.modulate.g = 0.1
    self.modulate.b = 0.1
  elif normal_modulation != null:
    self.modulate = normal_modulation
  else:
    self.modulate.r = 1
    self.modulate.g = 1
    self.modulate.b = 1

# Damage this entity and push it back on the given knockback vec
func damage(amount, knockback_vec):
  self.knockback += knockback_vec
  self.health -= amount
  if self.health <= 0:
    queue_free()