extends Area2D

const DAMAGE = 1

const FireParticle = preload("res://scenes/fx/FireParticle.tscn")

const FIRE_PARTICLE_SPEED = 180.0
const FIRE_PARTICLE_VARIATION = 80.0

const FIREBALL_SPEED = 380.0

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
  for i in range(24):
    var particle = FireParticle.instance()
    var vel = Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized() * \
           (FIRE_PARTICLE_SPEED + \
           rand_range(-FIRE_PARTICLE_VARIATION, FIRE_PARTICLE_VARIATION))
    particle._set_vel(vel)
    particle.position = position
    world.add_child(particle)
  queue_free()