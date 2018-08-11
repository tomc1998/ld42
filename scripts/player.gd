extends KinematicBody2D

const Fireball = preload("res://scenes/Fireball.tscn")
const Room = preload("res://scenes/Room.tscn")

export var speed = 60
export var sprint_modifier = 1.8

onready var world = get_node("/root/World")

# Given a movement vector, set the current animation of the animation player.
func _set_anim(move_vec, sprinting):
  var anim_player = get_node("AnimationPlayer")
  var anim_should_play = null
  var curr_anim = anim_player.current_animation
  # left/right anims should override up/down
  if move_vec.x > 0 && curr_anim != "walk_right": anim_should_play = "walk_right"
  if move_vec.x < 0 && curr_anim != "walk_left": anim_should_play = "walk_left"
  if move_vec.x == 0:
    if move_vec.y > 0 && curr_anim != "walk_down": anim_should_play = "walk_down"
    if move_vec.y < 0 && curr_anim != "walk_up": anim_should_play = "walk_up"
  if move_vec.x == 0 && move_vec.y == 0:
    # check if we're currently playing a walking anim. If so, switch to the idle version.
    if curr_anim.substr(0, 4) == "walk":
      anim_should_play = "idle" + curr_anim.substr(4, curr_anim.length() - 4)
  # Actually play the anim
  if anim_should_play: anim_player.play(anim_should_play)
  # If we're sprinting, increase the anim speed
  if sprinting:
    anim_player.playback_speed = sprint_modifier
  else:
    anim_player.playback_speed = 1

func _physics_process(delta):
  var move_vec = Vector2(0, 0)
  var sprinting = false
  if Input.is_action_pressed("move_left"): move_vec.x = -speed
  if Input.is_action_pressed("move_right"): move_vec.x = speed
  if Input.is_action_pressed("move_up"): move_vec.y = -speed
  if Input.is_action_pressed("move_down"): move_vec.y = speed
  if Input.is_action_pressed("sprint"):
    if !(move_vec.x == 0 && move_vec.y == 0):
      sprinting = true
      move_vec *= sprint_modifier
  _set_anim(move_vec, sprinting)
  move_and_slide(move_vec)

  # Check for fireball shooting
  if Input.is_action_just_pressed("primary"):
    _shoot_fireball(get_global_mouse_position())

func _shoot_fireball(target):
  if _shrink_curr_room(20.0):
    var vec = (target - self.position).normalized()
    var fireball = Fireball.instance()
    fireball.set_dir(vec)
    fireball.position = position + vec * 8.0
    world.add_child(fireball)

# Find the room we're currently in (linear search) and shrink that one by the
# given amount.
# Returns false if the room is too small already, or if we couldn't find a room
# that we were in to shrink.
func _shrink_curr_room(amount):
  # Find the room
  for r in world.get_node("DungeonGenerator").get_children():
    if r.get_filename() == Room.get_path():
      # Check if we are inside the room
      var room_wall = r.get_node("RoomWall")
      var room_size = Vector2(room_wall.size, room_wall.size)
      var room_rect = Rect2(r.position - room_size / 2.0, room_size)
      if room_rect.has_point(position):
        print("Shrinking")
        if room_wall.target_size - amount < room_wall.MIN_SIZE: return false
        else:
          room_wall.shrink(amount)
          return true
  return false

        