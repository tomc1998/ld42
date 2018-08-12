extends Node

signal score_changed(score)
signal multiplier_changed(multiplier)

var _score = 0
var _multiplier = 1

func reset():
  _score = 0
  _multiplier = 1

func add_score(score):
  _score += score * _multiplier
  emit_signal("score_changed", _score)
  print("Curr score: " + str(_score))

func set_multiplier(multiplier):
  _multiplier = multiplier
  emit_signal("multiplier_changed", _multiplier)