extends RichTextLabel

onready var score = get_node("/root/score")

func _ready():
  score.connect("score_changed", self, "score_changed")
  score.connect("multiplier_changed", self, "multiplier_changed")
  update_text()

func update_text():
  self.text = "Multiplier: x" + str(score._multiplier) + "\nScore: " + str(score._score)

func score_changed(score):
  update_text()

func multiplier_changed(multiplier):
  update_text()


