extends "creature.gd"

const Drops = preload("drops.gd")
const Creature = preload("creature.gd")

onready var player = get_node("/root/World/Player")
onready var anim_player = get_node("AnimationPlayer")

const DAMAGE = 1

const NOTICE_RANGE = 180
const JUMP_SPEED = 180
const JUMP_DISTANCE = 100

const STATE_IDLE = 0
const STATE_CHARGE = 1
const STATE_ATTACK = 2

var state = STATE_IDLE

var jump_dir

const JUMP_TIME = 0.5
const JUMP_TIME_VAR = 0.1 # Variance
var jump_time = 0.5

const CHARGE_TIME = 0.8
var charge_counter = CHARGE_TIME

func _init():
  self.normal_modulation = Color(0.0, 0.5, 1.0, 1.0);

func _process(delta):
  if state == STATE_IDLE:
    if (player.global_position - global_position).length() < NOTICE_RANGE:
      state = STATE_CHARGE
      charge_counter = CHARGE_TIME
      anim_player.play("charge")
  elif state == STATE_CHARGE:
    charge_counter -= delta
    if charge_counter <= 0:
      charge_counter = 0
      state = STATE_ATTACK
      anim_player.play("attack")
      jump_dir = (player.global_position - global_position).normalized()
      jump_time = JUMP_TIME + rand_range(-JUMP_TIME_VAR, JUMP_TIME_VAR)
  elif state == STATE_ATTACK:
    jump_time -= delta
    if jump_time <= 0.0:
      state = STATE_IDLE
      anim_player.play("idle")
    else:
      move_and_slide(jump_dir * JUMP_SPEED)

  ._process(delta)

func _ready():
  anim_player.play("idle")
  get_node("Hurtbox").connect("body_entered", self, "on_body_entered")

func potential_drops():
  return [Drops.Drops.HEART]

func on_body_entered(body):
  if body is Creature:
    if body.faction != faction:
      body.damage(DAMAGE, (body.global_position - global_position).normalized() * 300)