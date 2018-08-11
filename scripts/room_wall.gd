## This is a script for a 'RoomWall', which is used to construct a room. It has
## a parameter to control which sides of the room have doors.

extends StaticBody2D

const WALL_SPRITESHEET = preload("res://assets/art/dungeon/walls.png")

const DOOR_SIZE = 32.0
const WALL_SIZE = 256.0
const WALL_SIZE_2 = 128.0

const LEFT   = 1
const TOP    = 2
const RIGHT  = 4
const BOTTOM = 8

# Enum for which walls have doors
export(int, FLAGS, "Left", "Top", "Right", "Bottom") var has_doors

# Create a sprite node, given the direction this wall faces. If dir == RIGHT,
# this will return the wall where the face of the wall is to the right (i.e. the
# 5th sprite in the spritesheet reading like a book).
# If dir is a combination of 2 directions, this returns a corner.
# Errors if no tex exists for the given dir.
func _get_wall_sprite(dir):
  var sprite = Sprite.new()
  sprite.region_enabled = true
  sprite.set_texture(WALL_SPRITESHEET)

  if   dir == LEFT:           sprite.region_rect = Rect2(0, 0, 16, 16)
  elif dir == TOP:            sprite.region_rect = Rect2(16, 0, 16, 16)
  elif dir == RIGHT:          sprite.region_rect = Rect2(0, 16, 16, 16)
  elif dir == BOTTOM:         sprite.region_rect = Rect2(16, 16, 16, 16)
  elif dir == BOTTOM | RIGHT: sprite.region_rect = Rect2(32, 0,  16, 16)
  elif dir == BOTTOM | LEFT:  sprite.region_rect = Rect2(48, 0,  16, 16)
  elif dir == TOP    | RIGHT: sprite.region_rect = Rect2(32, 16, 16, 16)
  elif dir == TOP    | LEFT:  sprite.region_rect = Rect2(48, 16, 16, 16)

  return sprite

# Return the direction at 90 degrees (anti-clockwise) to the given one - i.e. LEFT will
# return BOTTOM.
func _get_dir_normal_cc(dir):
  match dir:
    LEFT: return BOTTOM
    TOP: return LEFT
    RIGHT: return TOP
    BOTTOM: return RIGHT

# Return the direction at 90 degrees (clockwise) to the given one - i.e. LEFT will
# return BOTTOM.
func _get_dir_normal(dir):
  match dir:
    LEFT: return TOP
    TOP: return RIGHT
    RIGHT: return BOTTOM
    BOTTOM: return LEFT

# Given a dir, get a unit vector for that directoin
func _get_dir_as_vec(dir):
  match dir:
    LEFT:   return Vector2(-1,  0)
    TOP:    return Vector2( 0, -1)
    RIGHT:  return Vector2( 1,  0)
    BOTTOM: return Vector2( 0,  1)

# Construct a wall from the given start pos, in the given direction.
# `pos` should be the center of the wall to create.
# Dir should be the direction that the wall FACES (i.e. LEFT || TOP || RIGHT ||
# BOTTOM).
func _construct_wall(pos, dir, is_door):
  # If this isn't a door, this is easy to construct
  var wall_nor = _get_dir_as_vec(_get_dir_normal(dir))
  var wall_nor_cc = _get_dir_as_vec(_get_dir_normal_cc(dir))
  if !is_door:
    var sprite = _get_wall_sprite(dir);
    sprite.apply_scale((wall_nor_cc * WALL_SIZE / 16.0 + _get_dir_as_vec(dir)).abs())
    sprite.position = pos;
    add_child(sprite)
  else:
    # Construct 2 walls, of size (WALL_SIZE - DOOR_SIZE)/2
    var wall_size = (WALL_SIZE - DOOR_SIZE)/2.0

    var sprite = _get_wall_sprite(dir);
    sprite.apply_scale((wall_nor_cc * wall_size / 16.0 + _get_dir_as_vec(dir)).abs())
    sprite.position = pos + wall_nor_cc * (DOOR_SIZE / 2.0 + wall_size / 2.0);
    add_child(sprite)

    sprite = _get_wall_sprite(dir);
    sprite.apply_scale((wall_nor_cc * wall_size / 16.0 + _get_dir_as_vec(dir)).abs())
    sprite.position = pos + wall_nor * (DOOR_SIZE / 2.0 + wall_size / 2.0);
    add_child(sprite)

func _ready():
  _construct_wall(Vector2(WALL_SIZE_2 + 8.0, 0),  LEFT, true)
  _construct_wall(Vector2(0, WALL_SIZE_2 + 8.0),  TOP, true)
  _construct_wall(Vector2(-WALL_SIZE_2 - 8.0, 0), RIGHT, true)
  _construct_wall(Vector2(0, -WALL_SIZE_2 - 8.0), BOTTOM, true)

