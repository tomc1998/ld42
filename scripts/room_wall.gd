## This is a script for a 'RoomWall', which is used to construct a room. It has
## a parameter to control which sides of the room have doors.

extends Node2D

const Tunnel = preload("res://scenes/Tunnel.tscn")

const WALL_SPRITESHEET = preload("res://assets/art/dungeon/walls.png")
const FLOOR_SPRITESHEET = preload("res://assets/art/dungeon/floor.png")
const MIN_SIZE = 64.0

const DOOR_SIZE = 32.0
const WALL_SIZE = 256.0
const WALL_SIZE_2 = 128.0

const LEFT   = 1
const TOP    = 2
const RIGHT  = 4
const BOTTOM = 8

var size = WALL_SIZE - 2.0
var target_size = size
const SHRINK_SPEED = 24.0

# Meta-data for walls, for when we're shrinking rooms
class WallMeta:
  var dir
  # The normal of the direction. This is used for door walls, where one wall is
  # on one side and is effectively mirrored. This means we can loopover the
  # walls and just use the wall normals, rather than a shit load of
  # if-statements with the dir.
  # This should either be the _get_dir_normal(dir) or _get_dir_normal_cc(dir).
  # The choice effects how the wall corner tile scales - one is correct, one
  # isn't.
  var nor
  var wall
  func _init(wall, dir, nor):
    self.wall = wall
    self.dir = dir
    self.nor = nor

# Floor tiles
var floors = []
# All walls. Walls with a door count as 2 separate walls.
var walls = []
# TOP LEFT, TOP RIGHT, BOTTOM RIGHT, BOTTOM LEFT corners
var corners = []
#  A list of the tunnels connected to the doors of this room. There are always 2
#  distinct tunnel objects per tunnel - they're shared by the rooms.
var tunnels = []

# Enum for which walls have doors
export(int, FLAGS, "Left", "Top", "Right", "Bottom") var has_doors

# Create a sprite node, given the direction this wall faces. If dir == RIGHT,
# this will return the wall where the face of the wall is to the right (i.e. the
# 5th sprite in the spritesheet reading like a book).
# If dir is a combination of 2 directions, this returns a corner.
# Errors if no tex exists for the given dir.
# If `invert` is true, the tile is inverted to join walls. For example, there's
# 2 corner tiles, one which has the corner 'pointing inwards', and one which has
# 2 wall faces 'pointing outwards'. The first would be inverted, the second is
# just normal.
static func _get_wall_sprite(dir, invert=false):
  var sprite = Sprite.new()
  sprite.region_enabled = true
  sprite.set_texture(WALL_SPRITESHEET)

  if   dir == LEFT:           sprite.region_rect = Rect2(0, 0, 16, 16)
  elif dir == TOP:            sprite.region_rect = Rect2(16, 0, 16, 16)
  elif dir == RIGHT:          sprite.region_rect = Rect2(0, 16, 16, 16)
  elif dir == BOTTOM:         sprite.region_rect = Rect2(16, 16, 16, 16)
  elif invert && dir == BOTTOM | RIGHT: sprite.region_rect = Rect2(32, 0,  16, 16)
  elif invert && dir == BOTTOM | LEFT:  sprite.region_rect = Rect2(48, 0,  16, 16)
  elif invert && dir == TOP    | RIGHT: sprite.region_rect = Rect2(32, 16, 16, 16)
  elif invert && dir == TOP    | LEFT:  sprite.region_rect = Rect2(48, 16, 16, 16)
  elif dir == BOTTOM | RIGHT: sprite.region_rect = Rect2(16, 48, 16, 16)
  elif dir == BOTTOM | LEFT:  sprite.region_rect = Rect2(0,  48, 16, 16)
  elif dir == TOP    | RIGHT: sprite.region_rect = Rect2(16, 32, 16, 16)
  elif dir == TOP    | LEFT:  sprite.region_rect = Rect2(0,  32, 16, 16)
  else: breakpoint

  return sprite

# Create a random floor sprite node
static func _get_floor_sprite():
  var sprite = Sprite.new()
  sprite.region_enabled = true
  sprite.set_texture(FLOOR_SPRITESHEET)
  sprite.region_rect = Rect2(0, 0, 16, 16)
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
static func _get_dir_as_vec(dir):
  match dir:
    LEFT:   return Vector2(-1,  0)
    TOP:    return Vector2( 0, -1)
    RIGHT:  return Vector2( 1,  0)
    BOTTOM: return Vector2( 0,  1)

static func _get_vec_as_dir(dir):
  if dir == Vector2(1, 0): return RIGHT
  elif dir == Vector2(-1, 0): return LEFT
  elif dir == Vector2(0, 1): return BOTTOM
  elif dir == Vector2(0, -1): return TOP
  else: breakpoint


# Construct a wall from the given start pos, in the given direction.
# `pos` should be the center of the wall to create.
# Dir should be the direction that the wall FACES (i.e. LEFT || TOP || RIGHT ||
# BOTTOM).
func _construct_wall(pos, dir, is_door):
  # If this isn't a door, this is easy to construct
  var wall_nor = _get_dir_as_vec(_get_dir_normal(dir))
  var wall_nor_cc = _get_dir_as_vec(_get_dir_normal_cc(dir))
  if !is_door:
    var wall = StaticBody2D.new()
    wall.set_collision_layer_bit(0, false)
    wall.set_collision_layer_bit(19, true)
    # Add wall sprite
    var sprite = _get_wall_sprite(dir);
    wall.add_child(sprite)
    # Offset wall & add collision
    wall.position = pos;
    var shape_owner = wall.create_shape_owner(wall)
    var shape = RectangleShape2D.new()
    wall.shape_owner_add_shape(shape_owner, shape)
    walls.append(WallMeta.new(wall, dir, wall_nor))
    add_child(wall)
  else:
    # Construct 2 walls, of size (WALL_SIZE - DOOR_SIZE)/2

    var wall = StaticBody2D.new()
    wall.set_collision_layer_bit(0, false)
    wall.set_collision_layer_bit(19, true)
    # Add wall sprite
    var sprite = _get_wall_sprite(dir);
    wall.add_child(sprite)
    # Add corner for door
    sprite = _get_wall_sprite(dir | _get_dir_normal(dir));
    wall.add_child(sprite)
    # add collision
    var shape_owner = wall.create_shape_owner(wall)
    var shape = RectangleShape2D.new()
    wall.shape_owner_add_shape(shape_owner, shape)
    walls.append(WallMeta.new(wall, dir, wall_nor))
    add_child(wall)

    wall = StaticBody2D.new()
    wall.set_collision_layer_bit(0, false)
    wall.set_collision_layer_bit(19, true)
    # Add wall sprite
    sprite = _get_wall_sprite(dir);
    wall.add_child(sprite)
    # Add corner for door
    sprite = _get_wall_sprite(dir | _get_dir_normal_cc(dir));
    wall.add_child(sprite)
    # Offset wall & add collision
    shape_owner = wall.create_shape_owner(wall)
    shape = RectangleShape2D.new()
    wall.shape_owner_add_shape(shape_owner, shape)
    walls.append(WallMeta.new(wall, dir, wall_nor_cc))
    add_child(wall)


func _construct_wall_corner(pos, dir):
  var sprite = _get_wall_sprite(dir, true);
  var wall = StaticBody2D.new()
  wall.position = pos;
  wall.add_child(sprite)
  add_child(wall)
  var shape_owner = wall.create_shape_owner(wall)
  var shape = RectangleShape2D.new()
  shape.set_extents(Vector2(8, 8))
  wall.shape_owner_add_shape(shape_owner, shape)
  corners.append(wall)

# Fill the floor with sprite tiles
func _construct_floor():
  var rows = WALL_SIZE / 16.0 + 2.0
  for x in range(rows):
    for y in range(rows):
      # Don't create tiles on corners
      if (x == 0 || x == rows - 1) && (y == 0 || y == rows - 1): continue
      var sprite = _get_floor_sprite()
      sprite.position.x = x * 16.0 - WALL_SIZE_2 - 8.0
      sprite.position.y = y * 16.0 - WALL_SIZE_2 - 8.0
      add_child(sprite)
      floors.append(sprite)

func _construct_tunnels():
  var dirs = [LEFT, TOP, RIGHT, BOTTOM]
  for dir in dirs:
    if has_doors & dir > 0:
      var tunnel = Tunnel.instance()
      tunnel.position = _get_dir_as_vec(dir) * (WALL_SIZE_2 + 32.0)
      tunnel.dir = -_get_dir_as_vec(dir)
      add_child(tunnel)
      tunnels.append(tunnel)

func _ready():
  _construct_floor()
  _construct_tunnels()
  _construct_wall(Vector2(-WALL_SIZE_2 - 8.0, 0), RIGHT, has_doors & LEFT > 0)
  _construct_wall(Vector2(0, -WALL_SIZE_2 - 8.0), BOTTOM, has_doors & TOP > 0)
  _construct_wall(Vector2(WALL_SIZE_2 + 8.0, 0),  LEFT, has_doors & RIGHT > 0)
  _construct_wall(Vector2(0, WALL_SIZE_2 + 8.0),  TOP, has_doors & BOTTOM > 0)
  _construct_wall_corner(Vector2(-WALL_SIZE_2 - 8.0, -WALL_SIZE_2 - 8.0), RIGHT | BOTTOM)
  _construct_wall_corner(Vector2( WALL_SIZE_2 + 8.0, -WALL_SIZE_2 - 8.0), LEFT | BOTTOM)
  _construct_wall_corner(Vector2( WALL_SIZE_2 + 8.0,  WALL_SIZE_2 + 8.0), LEFT | TOP)
  _construct_wall_corner(Vector2(-WALL_SIZE_2 - 8.0,  WALL_SIZE_2 + 8.0), RIGHT | TOP)

  _set_size(size)

# Remove floor tiles which exceed the size bounds
func _cull_floor_tiles():
  var size_rect = Rect2(position - Vector2(size, size)/2.0, Vector2(size, size))
  for f in floors:
    var floor_rect = Rect2(f.position - Vector2(8.0, 8.0), Vector2(16.0, 16.0))
    if !floor_rect.intersects(size_rect):
      f.visible = false

func _shrink_wall(wall):
  # Change position first
  var pos_vec = -_get_dir_as_vec(wall.dir)
  wall.wall.position = position + pos_vec * size / 2.0 + pos_vec * 8.0
  
  if wall.wall.get_children().size() == 1:
    var sprite = wall.wall.get_children()[0]
    # Easy, just scale down
    sprite.scale = pos_vec.abs() + wall.nor.abs() * size / 16
    # # Scale collisions
    var shape_owner = wall.wall.get_shape_owners()[0]
    var rect = wall.wall.shape_owner_get_shape(shape_owner, 0)
    rect.extents = (pos_vec * 16.0 + wall.nor * size).abs() / 2.0
  if wall.wall.get_children().size() == 2:
    # Add offset to the right / left along wall normal
    wall.wall.position -= wall.nor * (size / 4 + DOOR_SIZE/2)
    var sprite = wall.wall.get_children()[0]
    # More complex, as this is a door wall. Consists of 2 sprites - first sprite is a
    # wall, 2nd is a corner sprite which is next to the door.
    # First, scale the wall down
    sprite.scale = pos_vec.abs() + wall.nor.abs() * (size / 2 - DOOR_SIZE) / 16
    # Then, do the corner sprite.
    var corner = wall.wall.get_children()[1]
    corner.position = wall.nor * (size / 4.0 - 16.0)
    # # Scale collisions
    var shape_owner = wall.wall.get_shape_owners()[0]
    var rect = wall.wall.shape_owner_get_shape(shape_owner, 0)
    rect.extents = (pos_vec * 16.0 + wall.nor * (size / 2 - DOOR_SIZE / 2)).abs() / 2.0

# Shrink walls down to size
func _shrink_walls():
  var size_vec = Vector2(size, size)
  # Shrink corners
  corners[0].position = position + Vector2(-size, -size) / 2.0 + Vector2(-8.0, -8.0)
  corners[1].position = position + Vector2(size,  -size) / 2.0 + Vector2( 8.0, -8.0)
  corners[2].position = position + Vector2(size,   size) / 2.0 + Vector2( 8.0,  8.0)
  corners[3].position = position + Vector2(-size,  size) / 2.0 + Vector2(-8.0,  8.0)

  for w in walls: _shrink_wall(w)

# Change the size of the floor.
func _set_size(size):
  # Enlargment unsupported!
  assert(self.size >= size)
  self.size = size;
  _cull_floor_tiles()
  _shrink_walls()
  for t in self.tunnels:
    t.set_size((WALL_SIZE - size)/2)

func shrink(amount):
  self.target_size -= amount

func _process(delta):
  if target_size < size:
    var size = self.size - delta * SHRINK_SPEED
    if size < target_size:
      size = target_size
    _set_size(size)
  elif target_size > size:
    var size = self.size + delta * SHRINK_SPEED
    if size < target_size:
      size = target_size
    _set_size(size)
    