extends Node

class Highscore:
  var name
  var score
  func _init(name, score):
    self.name = name
    self.score = score

signal score_changed(score)
signal multiplier_changed(multiplier)

const NUM_HIGHSCORES = 5

# Ordered Highscore objects, highest first
var highscores = [
    Highscore.new("Mad Max", 300000),
    Highscore.new("Larry", 100000),
    Highscore.new("Jacob", 30000),
    Highscore.new("Tom", 10000),
    Highscore.new("John", 1000),
]

var _score = 0

var _multiplier = 1

func reset():
  _score = 0
  _multiplier = 1
  emit_signal("score_changed", _score)
  emit_signal("multiplier_changed", _multiplier)
  print("RESETTING")

func add_score(score):
  _score += score * _multiplier
  emit_signal("score_changed", _score)
  print("Curr score: " + str(_score))

func set_multiplier(multiplier):
  _multiplier = multiplier
  emit_signal("multiplier_changed", _multiplier)

func is_current_score_highscore():
  if highscores.size() < NUM_HIGHSCORES: return true
  for h in highscores:
    if h.score < _score:
      return true
  return false

# Add the current score to the highscores. Won't add anything if the score doesn't actually make it.
func add_highscore(name):
  for i in range(highscores.size()):
    if highscores[i].score < _score:
      highscores.insert(i, Highscore.new(name, _score))
      while highscores.size() > NUM_HIGHSCORES: highscores.pop_back()
      return
  if highscores.size() < NUM_HIGHSCORES:
    highscores.append(Highscore.new(name, _score))
  