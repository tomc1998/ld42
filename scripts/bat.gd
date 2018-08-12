extends "creature.gd"

const Drops = preload("drops.gd")
const Creature = preload("creature.gd")

onready var player = get_node("/root/World/Player")
onready var anim_player = get_node("AnimationPlayer")

const DAMAGE = 1
const TURN_RATE = PI
const MOVE_SPEED = 120

var dir = Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized()
var steering_left = false

func _physics_process(delta):
  # Change steer?
  if rand_range(0, 1) < 0.005:
    steering_left = !steering_left

  # Steer a little
  var angle = dir.angle()
  if steering_left: angle -= TURN_RATE * delta
  else: angle += TURN_RATE * delta

  dir = Vector2(cos(angle), sin(angle))

  # Move
  move_and_slide(dir * MOVE_SPEED)

func _ready():
  anim_player.play("idle")
  get_node("Hurtbox").connect("body_entered", self, "on_body_entered")

func potential_drops():
  return [Drops.Drops.HEART]

func on_body_entered(body):
  if body is Creature:
    if body.faction != faction:
      body.damage(DAMAGE, (body.global_position - global_position).normalized() * 300)
  else:
    dir = -dir
