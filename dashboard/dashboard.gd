extends Control

# Assign your single Label node here in the editor for card textual details
@export var display_label: Label
# Assign your new Label node here in the editor for the stats summary
@export var stats_summary_label: Label

func _ready():
	print("Dashboard _ready: Initializing display label.")
	if display_label == null:
		print("Error (dashboard.gd): display_label is not assigned in the editor!")
	
	print("Dashboard _ready: Initializing stats summary label.")
	if stats_summary_label == null:
		print("Error (dashboard.gd): stats_summary_label is not assigned in the editor!")

	update_card_display({}) # Clear card display initially
	update_stats_summary_display(10, 10, 10, 10) # Clear/Initialize stats summary display with default values

# Called to update the card details display in the main display_label
func update_card_display(card_info: Dictionary):
	if display_label == null:
		print("Error (dashboard.gd): display_label is not assigned. Cannot update card display.")
		return

	if card_info.size() > 0:
		print("Dashboard: update_card_display called with card_info: ", card_info)
		var effects_text = "效果: " + card_info.get("Effects", "N/A")
		var mechanism_text = "生物机制: " + card_info.get("Biological Mechanism", "N/A")
		var conditions_text = "特殊效果: " + card_info.get("Special Conditions", "N/A")
		
		display_label.text = effects_text + "\n" + mechanism_text + "\n" + conditions_text
	else:
		print("Dashboard: update_card_display called with empty card_info. Clearing card display.")
		display_label.text = "-"

# NEW FUNCTION: Called to update the stats summary display in the stats_summary_label
func update_stats_summary_display(rv_val: int, av_val: int, dm_val: int, mv_val: int):
	if stats_summary_label == null:
		print("Error (dashboard.gd): stats_summary_label is not assigned. Cannot update stats summary.")
		return
	
	print("Dashboard: update_stats_summary_display called with RV:", rv_val, "AV:", av_val, "DM:", dm_val, "MV:", mv_val)
	var stats_text = "当前状态: RV: %d | AV: %d | DM: %d | MV: %d" % [rv_val, av_val, dm_val, mv_val]
	stats_summary_label.text = stats_text
