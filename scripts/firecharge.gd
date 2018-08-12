extends Sprite

const Fireball = preload("res://scenes/Fireball.tscn")

onready var world = get_node("/root/World")

const LIFETIME = 0.24
var death_timer = LIFETIME

var fireball_dir = Vector2(1,0)

func _process(delta):
  death_timer -= delta;
  if death_timer <= 0:
    var fireball = Fireball.instance()
    fireball.set_dir(fireball_dir)
    fireball.position = position
    world.add_child(fireball)
    queue_free()
    return

func _ready():
  get_node("SampleFirecharge").play()
  get_node("AnimationPlayer").play("charge")
