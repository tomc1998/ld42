extends Node2D

const FLOOR_SPRITESHEET = preload("res://assets/art/dungeon/floor.png")

const RoomWall = preload("res://scripts/room_wall.gd")

const MAX_TUNNEL_SIZE = 128.0
const TUNNEL_WIDTH = 48.0

# Vector that points from the center of the tunnel back to the room that this
# tunnel belongs in
var dir 

var floors = []

var walls = []

func _construct_walls():
  var normals = [dir.tangent(), -dir.tangent()]
  for nor in normals:
    var wall = StaticBody2D.new()
    wall.position = dir * MAX_TUNNEL_SIZE / 2 + nor * (TUNNEL_WIDTH / 2.0 + 8.0)
    print(-nor)
    print(RoomWall._get_vec_as_dir(-nor))
    var sprite = RoomWall._get_wall_sprite(RoomWall._get_vec_as_dir(-nor), false);
    sprite.scale = nor.abs() + dir.abs() * MAX_TUNNEL_SIZE / 16.0
    wall.add_child(sprite)
    walls.append(wall)
    add_child(wall)

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
      var sprite = RoomWall._get_floor_sprite()
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
  _construct_walls()

# Change the rendered scale of the walls
func set_size(size):
  var normals = [dir.tangent(), -dir.tangent()]
  for ix in walls.size():
    var nor = normals[ix]
    var w = walls[ix]
    w.position = dir * (size+32.0) / 2 + nor * (TUNNEL_WIDTH / 2.0 + 8.0)
    var sprite = w.get_children()[0]
    sprite.scale = nor.abs() + dir.abs() * (size+8) / 16.0
    