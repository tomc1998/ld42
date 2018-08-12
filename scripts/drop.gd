extends KinematicBody2D

const DAMPING = 400.0
const SPEED = 200.0
const SPEED_VAR = 10.0

const Creature = preload("creature.gd")
onready var drops = get_node("/root/drops")

onready var player = get_node("/root/World/Player")

var drop_type

var vel = Vector2(0,0)

func _ready():
  var hitbox = get_node("HitBox")
  assert(hitbox != null)
  hitbox.connect("body_entered", self, "body_entered")

func choose_random_vel():
  var angle = rand_range(0, 2*PI)
  vel = Vector2(cos(angle), sin(angle)) * rand_range(SPEED - SPEED_VAR, SPEED + SPEED_VAR)

func _physics_process(delta):
  var player_len = (player.global_position - global_position).length_squared()
  if player_len < 50.0 * 50.0:
    vel += (player.global_position - global_position).normalized() * 800.0 * delta

  # Damp
  var speed = self.vel.length();
  self.vel = (self.vel / speed) * (speed - DAMPING * delta)
  if speed <= 2: self.vel = Vector2(0,0)
  move_and_slide(vel)

func body_entered(body):
  if body is Creature:
    if body.faction == Creature.PLAYER:
      queue_free()
      drops.process_collection(drop_type)