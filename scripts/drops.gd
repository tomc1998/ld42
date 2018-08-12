extends Node

const HeartDrop = preload("res://scenes/HeartDrop.tscn")

enum Drops {
  HEART
}

# Create a node for dropping, based on the drops enum. Breakpoints if not found.
func create_drop(drop):
  match drop:
    Drops.HEART: return HeartDrop.instance()
    _: breakpoint

func process_collection(drop):
  match drop:
    Drops.HEART: 
      var player = get_node("/root/World/Player")
      if player != null:
        player.heal(1)
