extends Area2D

const DAMAGE = 1

const FIREBALL_SPEED = 380.0

const FireExplosion = preload("res://scenes/fx/FireExplosion.tscn")

onready var world = get_node("/root/World")

var _dir = Vector2(1,0)

func _physics_process(delta):
  self.position += _dir * FIREBALL_SPEED * delta

func set_dir(vec):
  _dir = vec
  self.rotation = _dir.angle()

func _on_Fireball_body_entered(body):
  if body.has_method("damage"):
    body.callv("damage", [DAMAGE, (body.position - position).normalized() * 200])
  var fire_explosion = FireExplosion.instance()
  fire_explosion.position = global_position
  world.add_child(fire_explosion)
  queue_free()