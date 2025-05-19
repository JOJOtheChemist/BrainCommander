extends "res://deck/deck.gd" # 使用 deck.gd 的文件路径

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
