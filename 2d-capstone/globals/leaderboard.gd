extends Node2D

# Structure of leaderboard data:
# {
#   "level_1": [
#     {"name": "Player", "score": 1000},
#     {"name": "Player", "score": 800},
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
func get_level_scores(level_index: String) -> Array:
	var level_key = "level_" + str(level_index)
	if not leaderboard_data.has(level_key):
		leaderboard_data[level_key] = []
	return leaderboard_data[level_key]

# Adds a new score entry and returns the entry if it made it to the leaderboard, null otherwise
func add_score(level_index: String, entry_name: String, entry_score: int) -> Dictionary:
	var level_key = "level_" + str(level_index)
	if not leaderboard_data.has(level_key):
		leaderboard_data[level_key] = []
	
	var new_entry = {
		"name": entry_name,
		"score": entry_score
	}
	
	leaderboard_data[level_key].append(new_entry)
	# Sort by score in descending order
	leaderboard_data[level_key].sort_custom(func(a, b): return a.score > b.score)
	
	# Keep only top MAX_ENTRIES
	if leaderboard_data[level_key].size() > MAX_ENTRIES:
		leaderboard_data[level_key].resize(MAX_ENTRIES)
	
	# Return the entry if it made it to the leaderboard, null otherwise
	return new_entry if new_entry in leaderboard_data[level_key] else null
