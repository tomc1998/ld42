extends Node

const Room = preload("res://scenes/Room.tscn")
const RoomWall = preload("res://scripts/room_wall.gd")
const LadderUp = preload("res://scenes/LadderUp.tscn")
const LadderDown = preload("res://scenes/LadderDown.tscn")

onready var world = get_tree().get_root().get_node("World")
onready var player = world.get_node("Player")

const SIZE = 4

const LEFT = 0
const TOP = 1
const RIGHT = 2
const BOTTOM = 3

# List of refs to ladders which shold be freed when we delete a level
var curr_ladders = []

# Convert a direction to a unit vector.
func _dir_to_vec(dir):
  var ret
  if dir == LEFT:   ret = Vector2(-1, 0)
  if dir == TOP:    ret = Vector2(0, -1)
  if dir == RIGHT:  ret = Vector2(1, 0)
  if dir == BOTTOM: ret = Vector2(0, 1)
  return ret

func _dir_opposite(dir):
  if dir == LEFT:   return RIGHT
  elif dir == TOP:    return BOTTOM
  elif dir == RIGHT:  return LEFT
  elif dir == BOTTOM: return TOP
  else: breakpoint


# A room in the grid
class GridRoom:
  var connections = [false, false, false, false]
  var is_start = false
  var is_end = false

  # converts this gridroom to a Room scene.
  func to_room(world, curr_ladders, position):
    var room = Room.instance()
    var room_wall = room.get_node("RoomWall")
    room.position = position
    if self.connections[LEFT]: room_wall.has_doors |= room_wall.LEFT
    if self.connections[TOP]: room_wall.has_doors |= room_wall.TOP
    if self.connections[RIGHT]: room_wall.has_doors |= room_wall.RIGHT
    if self.connections[BOTTOM]: room_wall.has_doors |= room_wall.BOTTOM
    var angle = rand_range(0, 2 * PI)
    var ladder_offset = Vector2(cos(angle), sin(angle)) * 30.0
    if is_end: # Add the ladder up if this is the end
      var ladder = LadderUp.instance()
      ladder.position = room.position + ladder_offset
      curr_ladders.append(ladder)
      world.call_deferred("add_child", ladder)
    elif is_start: # Add the ladder down if this is the end
      room.does_spawn_monsters = false
      var ladder = LadderDown.instance()
      ladder.position = room.position + ladder_offset
      curr_ladders.append(ladder)
      world.call_deferred("add_child", ladder)
    return room

# # Given a size, returns a matrix of GridRoom objects (or null) containing rooms.
# # Rooms will always be hori / verti adjacent. Matrix is a list of lists.
# func _generate_rooms(size):
#   # Get the number of rooms to generate
#   var num_rooms = floor(rand_range(0, size*size / 2))
#   var curr_available_spaces = [Vector2(floor(size/2), floor(size/2))]
#   var data = []
#   for y in size:
#     var row = []
#     for x in size:
#       row.push(null)
#     data.push(row)
#   for ii in range(num_rooms):
#     # Randomly choose a space
#     var ix = floor(rand_range(0, curr_available_spaces.size()))
#     var space = curr_available_spaces[ix]
#     curr_available_spaces.remove(ix)
#     data[space.y][space.x] = true
#     # Add adjacent
#     if space.x > 0:
#       if !data[space.y][space.x-1]:
#         curr_available_spaces.push(Vector2(space.x-1, space.y))
#     if space.x < size-1:
#       if !data[space.y][space.x+1]:
#         curr_available_spaces.push(Vector2(space.x+1, space.y))
#     if space.y > 0:
#       if !data[space.y-1][space.x]:
#         curr_available_spaces.push(Vector2(space.x, space.y-1))
#     if space.y < size-1:
#       if !data[space.y+1][space.x]:
#         curr_available_spaces.push(Vector2(space.x, space.y+1))
#   return data

# Given a start and an end point, generate a grid of the given size containing a
# single path which can be completed.
# start and end are just vector2s with whole number parts.
func _gen_winning_path(size, start, end):
  # Assert start / end OOB
  assert(start.x >= 0 && start.x < size && end.x >= 0 && end.x < size &&
         start.y >= 0 && start.y < size && end.y >= 0 && end.y < size)
  # Just random walk over and over until we hit the end
  while true:
    var curr_pos = start
    var data = []
    for y in size:
      var row = []
      for x in size:
        row.append(null)
      data.append(row)

    data[start.y][start.x] = GridRoom.new()
    data[start.y][start.x].is_start = true
    data[end.y][end.x] = GridRoom.new()
    data[end.y][end.x].is_end = true

    for i in range(size*size):
      var dir = floor(floor(rand_range(0, 4)))
      # Gen next pos & clamp
      var next_pos = curr_pos + _dir_to_vec(dir)
      next_pos.x = max(0, min(size-1, next_pos.x))
      next_pos.y = max(0, min(size-1, next_pos.y))
      # Try again if we generated the same location, or doubled up rooms
      var room = GridRoom.new()
      if data[next_pos.y][next_pos.x] != null:
        if data[next_pos.y][next_pos.x].is_end:
          room = data[next_pos.y][next_pos.x]
        else: continue
      # Connect with the previous position
      room.connections[_dir_opposite(dir)] = true
      data[curr_pos.y][curr_pos.x].connections[dir] = true
      data[next_pos.y][next_pos.x] = room
      curr_pos = next_pos;
      if next_pos.x == end.x && next_pos.y == end.y: return data

# gen start / end positions. Size must be >= 4
func _gen_positions(size):
  assert(size >= 4)
  var start = Vector2(floor(rand_range(0, size)), floor(rand_range(0, size)))
  var end = Vector2(floor(rand_range(0, size)), floor(rand_range(0, size)))  
  while end == start || start.distance_to(end) < 3:
    start = Vector2(floor(rand_range(0, 1)), floor(rand_range(0, size)))
    end = Vector2(floor(rand_range(0, size)), floor(rand_range(0, size)))  
  return [start, end]

func gen_level():
  randomize()
  # Clear all children and ladders
  for i in range(0, get_child_count()):
      get_child(i).queue_free()
  for l in curr_ladders:
    l.queue_free()
  curr_ladders = []
  var positions = _gen_positions(SIZE)
  var grid = _gen_winning_path(SIZE, positions[0], positions[1])
  for y in grid.size():
    var row = grid[y]
    for x in row.size(): 
      var cell = row[x]
      if cell != null:
        var room = cell.to_room(world, curr_ladders,
          Vector2(x * (RoomWall.WALL_SIZE + 32.0),
                  y * (RoomWall.WALL_SIZE + 32.0)))
        add_child(room)
        # Set the player's starting position
        if cell.is_start:
          player.position = room.position

func _ready():
  gen_level()
