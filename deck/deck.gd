extends Panel
class_name DeckBase # 方便类型提示和实例化

@onready var cardDeck: Control = $cardDcek # 实际存放卡牌节点的容器
@onready var cardPoiDeck: HBoxContainer = $ScrollContainer/cardPoiDeck # 卡牌背景/占位符的容器

# 添加一个字典来存储卡牌序号
var card_indices: Dictionary = {}

func _process(delta: float) -> void:
	if cardDeck.get_child_count()!=0:
		var children = cardDeck.get_children()
		sort_nodes_by_position(children)
		
func sort_nodes_by_position(children):
	children.sort_custom(sort_by_position)
	for i in range(children.size()):
		if children[i].cardCurrentState:
			children[i].z_index = i
			cardDeck.move_child(children[i],i)
			# 更新卡牌序号
			card_indices[children[i].get_instance_id()] = i

func sort_by_position(a, b):
	return a.position.x < b.position.x

# 获取卡牌在牌堆中的序号
func get_card_index(card_instance: card) -> int:
	return card_indices.get(card_instance.get_instance_id(), -1)

# 打印当前牌堆状态
func print_deck_status() -> void:
	var cards = cardDeck.get_children()
	print("\n=== " + self.name + " Status ===")
	print("Total cards: " + str(cards.size()))
	
	for i in range(cards.size()):
		var card = cards[i]
		var index = get_card_index(card)
		print("Index " + str(index) + ": " + card.cardName + 
			" (Instance ID: " + str(card.get_instance_id()) + ")")
	print("========================\n")
	
func add_card(cardToAdd: card) -> void: # 明确 cardToAdd 的类型
	var cardBackground = preload("res://card_background.tscn").instantiate()
	# Add new background to the end of cardPoiDeck; sort_and_update_ui will position it correctly.
	cardPoiDeck.add_child(cardBackground)

	var global_poi = cardToAdd.global_position

	if cardToAdd.get_parent() != null: # 从旧父节点移除
		cardToAdd.get_parent().remove_child(cardToAdd)
	
	cardDeck.add_child(cardToAdd) # 添加到新的牌堆容器
	cardToAdd.global_position = global_poi # 尝试保持全局位置，或根据牌堆布局调整

	cardToAdd.follow_target = cardBackground # 设置卡牌的跟随目标
	cardToAdd.preDeck = self # 记录卡牌之前的牌堆是当前牌堆

	# 卡牌的 cardCurrentState 应由具体牌堆（手牌区、出牌区）的 add_card 逻辑来决定
	# 此处不再统一设置 cardToAdd.cardCurrentState = cardToAdd.cardState.following
	
	print(cardToAdd.name + " added to deck: " + self.name)
	# 添加后可能需要重新排序或更新UI
	call_deferred("sort_and_update_ui")
	# 打印更新后的牌堆状态
	call_deferred("print_deck_status")

func remove_card(cardToRemove: card) -> void:
	if cardToRemove != null and cardToRemove.get_parent() == cardDeck:
		print("Attempting to remove " + cardToRemove.name + " from " + self.name)
		
		# 移除对应的 cardBackground
		if cardToRemove.follow_target != null and cardToRemove.follow_target.get_parent() == cardPoiDeck:
			var bg_to_remove = cardToRemove.follow_target
			cardPoiDeck.remove_child(bg_to_remove)
			bg_to_remove.queue_free() # 释放背景图资源
			cardToRemove.follow_target = null # 清除引用
		
		# 从序号字典中移除
		card_indices.erase(cardToRemove.get_instance_id())
		
		cardDeck.remove_child(cardToRemove)
		# cardToRemove.queue_free() # 卡牌本身的销毁由调用者或游戏逻辑决定
		print(cardToRemove.name + " removed from deck: " + self.name)
		
		# 移除后可能需要重新排序或更新UI
		call_deferred("sort_and_update_ui")
		# 打印更新后的牌堆状态
		call_deferred("print_deck_status")
	else:
		printerr("Failed to remove card. It's null or not in this deck: ", cardToRemove)

# 获取指定序号的卡牌
func get_card_by_index(index: int) -> card:
	var cards = cardDeck.get_children()
	if index >= 0 and index < cards.size():
		return cards[index]
	return null

# 获取随机卡牌
func get_random_card() -> card:
	var cards = cardDeck.get_children()
	if cards.size() > 0:
		return cards[randi() % cards.size()]
	return null

# 获取牌堆中的卡牌数量
func get_card_count() -> int:
	return cardDeck.get_child_count()

# 获取所有卡牌
func get_all_cards() -> Array:
	return cardDeck.get_children()

func sort_and_update_ui():
	if cardDeck != null and cardDeck.get_child_count() > 0:
		var cards_in_deck = cardDeck.get_children()
		sort_nodes_by_position(cards_in_deck) # This sorts cardDeck children and the 'cards_in_deck' array.

		# After sort_nodes_by_position, cardDeck's children are in their new order (based on its logic).
		# Sync cardPoiDeck to this new order.
		var final_card_order_in_deck = cardDeck.get_children() 

		if cardPoiDeck != null:
			# Ensure counts match before trying to reorder.
			# remove_card should have removed the corresponding background.
			# add_card should have added one.
			if cardPoiDeck.get_child_count() == final_card_order_in_deck.size():
				for i in range(final_card_order_in_deck.size()):
					var card_node = final_card_order_in_deck[i]
					var bg_node = card_node.follow_target # This is its background
					
					if bg_node != null and bg_node.get_parent() == cardPoiDeck:
						# Move this bg_node to the i-th position in cardPoiDeck if not already there
						if cardPoiDeck.get_child(i) != bg_node:
							cardPoiDeck.move_child(bg_node, i)
					else:
						printerr("Card %s's follow_target is problematic in sort_and_update_ui for cardPoiDeck sync." % card_node.name)
			elif cardPoiDeck.get_child_count() != 0 : # Mismatch, but not if cards_in_deck is empty
				printerr("Card count (%d) and background count in cardPoiDeck (%d) mismatch. cardPoiDeck not fully synced." % [final_card_order_in_deck.size(), cardPoiDeck.get_child_count()])
		
		# For cards that don't actively follow (e.g., in play area),
		# explicitly set their position to match their follow_target after sorting.
		for card_node in final_card_order_in_deck:
			if card_node is card and card_node.cardCurrentState == card.cardState.in_play_area:
				if card_node.follow_target != null and card_node.follow_target.is_inside_tree():
					card_node.global_position = card_node.follow_target.global_position
	
	# If cardDeck is empty, ensure cardPoiDeck is also cleared.
	elif cardDeck != null and cardDeck.get_child_count() == 0 and cardPoiDeck != null:
		while cardPoiDeck.get_child_count() > 0:
			var bg = cardPoiDeck.get_child(0)
			cardPoiDeck.remove_child(bg)
			bg.queue_free() # Clean up unused backgrounds
		# 清空序号字典
		card_indices.clear()
