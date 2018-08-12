extends Node2D

export(PackedScene) var Particle = load("res://scenes/fx/FireParticle.tscn")
export(int) var num_particles = 24

const PARTICLE_SPEED = 180.0
const PARTICLE_VARIATION = 80.0

const LIFETIME = 0.4
const DAMPING = 400.0
var death_timer = LIFETIME

func _process(delta):
  death_timer -= delta;
  if death_timer <= 0:
    queue_free()
    return


func _ready():
  for i in range(num_particles):
    var particle = Particle.instance()
    var vel = Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized() * \
           (PARTICLE_SPEED + \
           rand_range(-PARTICLE_VARIATION, PARTICLE_VARIATION))
    particle._set_vel(vel)
    add_child(particle)
