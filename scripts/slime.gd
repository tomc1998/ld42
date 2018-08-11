extends KinematicBody2D

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

var jump_target

const CHARGE_TIME = 0.8
var charge_counter = CHARGE_TIME

func _process(delta):
  if state == STATE_IDLE:
    if (player.position - position).length() < NOTICE_RANGE:
      state = STATE_CHARGE
      charge_counter = CHARGE_TIME
      anim_player.play("charge")
  elif state == STATE_CHARGE:
    charge_counter -= delta
    if charge_counter <= 0:
      charge_counter = 0
      state = STATE_ATTACK
      anim_player.play("attack")
      jump_target = position + (player.position - position).normalized() * JUMP_DISTANCE
  elif state == STATE_ATTACK:
    var length = (jump_target - position).length()
    if ((jump_target - position).normalized() * JUMP_SPEED * delta).length() > length:
      state = STATE_IDLE
      anim_player.play("idle")
    else:
      move_and_slide((jump_target - position).normalized() * JUMP_SPEED)


func _ready():
  anim_player.play("idle")
  get_node("Hurtbox").connect("body_entered", self, "on_body_entered")

func on_body_entered(body):
  if body.has_method("damage"):
    body.callv("damage", [DAMAGE, (body.position - position).normalized() * 300])
  state = STATE_IDLE
