extends Area2D

const DAMAGE = 1

const SPEED = 500.0

const Explosion = preload("res://scenes/fx/StoneExplosion.tscn")

onready var world = get_node("/root/World")

var _dir = Vector2(1,0)

func _physics_process(delta):
  self.position += _dir * SPEED * delta

func set_dir(vec):
  _dir = vec
  self.rotation = _dir.angle()

func _on_Fireball_body_entered(body):
  if body.has_method("damage"):
    body.callv("damage", [DAMAGE, (body.position - position).normalized() * 200])
  var explosion = Explosion.instance()
  explosion.position = global_position
  world.add_child(explosion)
  queue_free()