extends Node2D

const FLOOR_SPRITESHEET = preload("res://assets/art/dungeon/floor.png")

const MAX_TUNNEL_SIZE = 128.0
const TUNNEL_WIDTH = 48.0

# Create a random floor sprite node
func _get_floor_sprite():
  var sprite = Sprite.new()
  sprite.region_enabled = true
  sprite.set_texture(FLOOR_SPRITESHEET)
  sprite.region_rect = Rect2(0, 0, 16, 16)
  return sprite

# Vector that points from the center of the tunnel back to the room that this
# tunnel belongs in
var dir 

var floors = []

func _construct_floor():
  var rows
  var columns
  if dir.x == 0: # Verti tunnel
    rows = MAX_TUNNEL_SIZE / 16.0
    columns = TUNNEL_WIDTH / 16.0
  else:
    columns = MAX_TUNNEL_SIZE / 16.0
    rows = TUNNEL_WIDTH / 16.0

  for x in range(columns):
    for y in range(rows):
      var sprite = _get_floor_sprite()
      sprite.position.x = \
        (16.0 * x * dir.x) if dir.x != 0 \
        else (-TUNNEL_WIDTH / 2 + 16.0 * x + 8.0)
      sprite.position.y = \
        (16.0 * y * dir.y) if dir.y != 0 \
        else (-TUNNEL_WIDTH / 2 + 16.0 * y + 8.0)
      add_child(sprite)
      floors.append(sprite)


func _ready():
  _construct_floor()

