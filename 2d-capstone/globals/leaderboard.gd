extends Node2D

# Structure of leaderboard data:
# {
#   "level_1": [
#     {"score": 1000, "accuracy": 95.5, "max_combo": 50},
#     {"score": 800, "accuracy": 92.0, "max_combo": 40},
#     ...
#   ],
#   "level_2": [
#     ...
#   ]
# }
var leaderboard_data = {}
const MAX_ENTRIES = 5

func _ready() -> void:
	pass  # No longer needs to load from file

# Gets the top scores for a specific level
func get_level_scores(level_index: int) -> Array:
	var level_key = "level_" + str(level_index)
	if not leaderboard_data.has(level_key):
		leaderboard_data[level_key] = []
	return leaderboard_data[level_key]

# Adds a new score entry and maintains only top 5 scores
func add_score(level_index: int, score: int, accuracy: float, max_combo: int) -> void:
	var level_key = "level_" + str(level_index)
	if not leaderboard_data.has(level_key):
		leaderboard_data[level_key] = []
	
	var new_entry = {
		"score": score,
		"accuracy": accuracy,
		"max_combo": max_combo
	}
	
	leaderboard_data[level_key].append(new_entry)
	# Sort by score in descending order
	leaderboard_data[level_key].sort_custom(func(a, b): return a.score > b.score)
	
	# Keep only top MAX_ENTRIES
	if leaderboard_data[level_key].size() > MAX_ENTRIES:
		leaderboard_data[level_key].resize(MAX_ENTRIES)
