extends Node2D

const FireParticle = preload("res://scenes/fx/FireParticle.tscn")

const FIRE_PARTICLE_SPEED = 180.0
const FIRE_PARTICLE_VARIATION = 80.0

const LIFETIME = 0.4
const DAMPING = 400.0
var death_timer = LIFETIME

func _process(delta):
  death_timer -= delta;
  if death_timer <= 0:
    queue_free()
    return


func _ready():
  for i in range(24):
    var particle = FireParticle.instance()
    var vel = Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized() * \
           (FIRE_PARTICLE_SPEED + \
           rand_range(-FIRE_PARTICLE_VARIATION, FIRE_PARTICLE_VARIATION))
    particle._set_vel(vel)
    add_child(particle)
