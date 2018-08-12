extends Node

const ChangeSpellInstruction = preload("res://scenes/ui/ChangeSpellInstruction.tscn")

const HeartDrop = preload("res://scenes/HeartDrop.tscn")
const StoneBulletDrop = preload("res://scenes/StoneBulletDrop.tscn")
const AirWaveDrop = preload("res://scenes/AirWaveDrop.tscn")

onready var ui_layer = get_node("/root/World/UILayer")

var first_time_collecting_spell = true

enum Drops {
  HEART
  STONE_BULLET
  AIR_WAVE
}

# Create a node for dropping, based on the drops enum. Breakpoints if not found.
static func create_drop(drop):
  match drop:
    Drops.HEART: return HeartDrop.instance()
    Drops.STONE_BULLET: return StoneBulletDrop.instance()
    Drops.AIR_WAVE: return AirWaveDrop.instance()
    _: breakpoint

func _display_spell_instructions():
  if first_time_collecting_spell:
    first_time_collecting_spell = false
    ui_layer.add_child(ChangeSpellInstruction.instance())

func process_collection(drop):
  match drop:
    Drops.STONE_BULLET: 
      var spell_selector = get_node("/root/World/UILayer/SpellSelector")
      if !spell_selector.available_spells.has(spell_selector.STONE_GUN):
        _display_spell_instructions()
        spell_selector.available_spells.append(spell_selector.STONE_GUN)
    Drops.AIR_WAVE: 
      var spell_selector = get_node("/root/World/UILayer/SpellSelector")
      if !spell_selector.available_spells.has(spell_selector.AIR_WAVE):
        _display_spell_instructions()
        spell_selector.available_spells.append(spell_selector.AIR_WAVE)
    Drops.HEART: 
      var player = get_node("/root/World/Player")
      if player != null:
        player.heal(1)
