extends "res://deck/deck.gd" # 使用 deck.gd 的文件路径

@export var effect_label: RichTextLabel = null # 在编辑器里绑定
@export var value_label: RichTextLabel = null # 你自己绑定
var base_rv := 10
var base_av := 10
var base_mv := 10
var base_dm := 10

func add_card(cardToAdd) -> void:
	super(cardToAdd)  # 调用父类的 add_card 方法

	# 标记这张牌现在在出牌区，并且让它不可拖动
	if cardToAdd.has_method("set_in_play_area"):
		cardToAdd.set_in_play_area(true)
	else:
		# Fallback if set_in_play_area is not available for some reason
		if cardToAdd.has_property("cardCurrentState") and cardToAdd.has_property("cardState"):
			# Assuming cardState.following effectively makes it non-interactive for dragging
			# or you might have a specific state like cardState.in_play_area
			cardToAdd.cardCurrentState = cardToAdd.cardState.following 

	print(cardToAdd.name + " added to deck-chupai and set to non-draggable/in_play_area.")
	update_effect_label_for_latest_card()
	update_value_label_for_all_cards()

func remove_card(cardToRemove) -> void:
	super(cardToRemove)
	update_effect_label_for_latest_card()
	update_value_label_for_all_cards()

func sort_and_update_ui():
	super()
	update_effect_label_for_latest_card()
	update_value_label_for_all_cards()

func update_effect_label(card):
	if effect_label:
		var effects = card.cardInfo.get("Effects", "N/A")
		var special = card.cardInfo.get("Special Conditions", "N/A")
		effect_label.text = "[b]效果:[/b] %s\n[b]特殊条件:[/b] %s" % [effects, special]

func update_effect_label_for_latest_card():
	var cards = cardDeck.get_children()
	if cards.size() > 0:
		var last_card = cards[cards.size() - 1]
		update_effect_label(last_card)
	else:
		if effect_label:
			effect_label.text = "无卡牌"

func parse_effects_for_values(effects_text: String) -> Dictionary:
	var result = {"RV": 0, "AV": 0, "MV": 0, "DM": 0}
	var regexes = {
		"RV": RegEx.new(),
		"AV": RegEx.new(),
		"MV": RegEx.new(),
		"DM": RegEx.new()
	}
	regexes["RV"].compile("RV[（(理性值）]*([+-]\\d+)")
	regexes["AV"].compile("AV[（(警觉值|杏仁核值）]*([+-]\\d+)")
	regexes["MV"].compile("MV[（(记忆值）]*([+-]\\d+)")
	regexes["DM"].compile("DM[（(多巴胺值）]*([+-]\\d+)")
	for key in regexes.keys():
		var match = regexes[key].search(effects_text)
		if match:
			result[key] = int(match.get_string(1))
	return result

func update_value_label_for_all_cards():
	var rv = base_rv
	var av = base_av
	var mv = base_mv
	var dm = base_dm
	var cards = cardDeck.get_children()
	for card in cards:
		var effects = card.cardInfo.get("Effects", "")
		var changes = parse_effects_for_values(effects)
		rv += changes["RV"]
		av += changes["AV"]
		mv += changes["MV"]
		dm += changes["DM"]
	if value_label:
		value_label.text = "理性(RV): %d\n警觉(AV): %d\n记忆(MV): %d\n多巴胺(DM): %d" % [rv, av, mv, dm]
