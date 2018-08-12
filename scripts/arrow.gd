extends Area2D

const ARROW_SPEED = 400.0
const Creature = preload("creature.gd")
const DAMAGE = 1

var _dir = Vector2(1,0)

func _physics_process(delta):
  self.position += _dir * ARROW_SPEED * delta

func set_dir(vec):
  _dir = vec.normalized()
  self.rotation = _dir.angle()

func _ready():
  self.connect("body_entered", self, "_body_entered")

func _body_entered(body):
  if body is Creature:
    if body.faction == Creature.PLAYER:
      body.damage(DAMAGE, (body.global_position - global_position).normalized() * 300)
      queue_free()
  else: queue_free()