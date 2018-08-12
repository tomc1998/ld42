extends Node2D

const FIREBALL_ICON = preload("res://assets/art/fireball_icon.png")
const STONE_GUN_ICON = preload("res://assets/art/stone_gun_icon.png")

const FIREBALL = 0
const STONE_GUN = 1

var available_spells = [FIREBALL, STONE_GUN]

var curr_spell = 0

onready var sprite = get_node("Sprite")

func _update_sprite():
  if available_spells[curr_spell] == FIREBALL:
    sprite.texture = FIREBALL_ICON
  elif available_spells[curr_spell] == STONE_GUN:
    sprite.texture = STONE_GUN_ICON

func _process(delta):
  self.position = get_viewport().size - Vector2(40.0, 40.0)

func _ready():
  _update_sprite()
  self.scale = Vector2(4, 4)

func _input(event):
  if event is InputEventKey && event.pressed:
    if event.scancode == KEY_E:
      curr_spell = (curr_spell + 1) % available_spells.size()
    if event.scancode == KEY_Q:
      curr_spell = (curr_spell - 1) % available_spells.size()
  _update_sprite()

func get_curr_spell():
  return available_spells[curr_spell]