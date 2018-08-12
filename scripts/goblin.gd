extends "creature.gd"

const Arrow = preload("res://scenes/Arrow.tscn")

const NOTICE_RANGE = 300
const SHOOT_RANGE = 150
const TOO_CLOSE_RANGE = 130
const TOO_FAR_RANGE = 170

const WALK_SPEED = 180.0

const STATE_IDLE = 0
# Walking to a target (see walk_dir)
const STATE_WALK = 1
# Standing still, shooting
const STATE_ATTACK = 2

var state = STATE_IDLE

var walk_dir = Vector2(0, 0)
# Will walk when > 0.0
var walk_time = 0.0

var RELOAD_TIME = 0.8
var reload_timer = 0.0

onready var anim_player = get_node("AnimationPlayer")
onready var player = get_node("/root/World/Player")
onready var world = get_node("/root/World")

func _choose_walk_space():
  var walk_target = player.global_position + \
      (global_position - player.global_position).normalized() * SHOOT_RANGE
  walk_target.x += rand_range(-30, 30)
  walk_target.y += rand_range(-30, 30)
  walk_dir = walk_target - global_position
  walk_time = (walk_dir.length())/WALK_SPEED
  walk_dir = walk_dir.normalized()
  state = STATE_WALK

func _shoot_at(target):
  var arrow = Arrow.instance()
  var dir = target - global_position;
  arrow.position = global_position + dir.normalized() * 8.0
  arrow.set_dir(dir)
  world.add_child(arrow)
  reload_timer = RELOAD_TIME

func _process(delta):
  var player_distance = (player.global_position - global_position).length()
  if state == STATE_IDLE:
    if player_distance < NOTICE_RANGE:
      _choose_walk_space()
  elif state == STATE_WALK:
    move_and_slide(walk_dir * WALK_SPEED)
    walk_time -= delta
    if walk_time <= 0:
      walk_time = 0
      state = STATE_ATTACK
  elif state == STATE_ATTACK:
    if reload_timer > 0.0:
      reload_timer -= delta
      if reload_timer <= 0:
        reload_timer = 0
    elif player_distance < TOO_CLOSE_RANGE || \
        player_distance > TOO_FAR_RANGE || \
        rand_range(0, 100) > 99.9:
      _choose_walk_space()
    else:
      _shoot_at(player.global_position)

func _ready():
  anim_player.play("idle_down")

func potential_drops():
  return [Drops.Drops.HEART]
