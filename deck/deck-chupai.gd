extends "res://deck/deck.gd" # 使用 deck.gd 的文件路径

@export var effect_label: RichTextLabel = null # 在编辑器里绑定

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

func remove_card(cardToRemove) -> void:
	super(cardToRemove)
	update_effect_label_for_latest_card()

func sort_and_update_ui():
	super()
	update_effect_label_for_latest_card()

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
