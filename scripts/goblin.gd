extends "creature.gd"

onready var anim_player = get_node("AnimationPlayer")

func _ready():
  anim_player.play("idle_down")

func potential_drops():
  return [Drops.Drops.HEART]