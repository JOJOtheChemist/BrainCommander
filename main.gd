extends Node2D


@export var scene_1:Node
@export var scene_2:Node
@export var scene_3:Node

@export var dashboard_node: Control

@export var maxRandomItemNum:int
@export var minRandomItemNum:int
@export var siteItems:Dictionary

func add_new_card(cardName,cardDeck,caller=scene_1)->Node:
	print("开始创建新卡牌："+str(cardName))
	var cardClass=CardInfos.infosDic[cardName]["base_cardType"]
	print("添加的卡的类型为%s:"%cardClass)
	var cardToAdd
	
	cardToAdd=preload("res://cards/card.tscn").instantiate() as card
	
	cardToAdd.initCard(cardName)

	if cardToAdd.cardInfo.has("base_price"):
		print("卡牌 '", cardName, "' 的 base_price 是: ", cardToAdd.cardInfo["base_price"])
	else:
		print("警告: 卡牌 '", cardName, "' 的 cardInfo 中没有找到 'base_price' 属性!")
		
	cardToAdd.global_position=caller.global_position
	cardToAdd.z_index=100
	cardDeck.add_card(cardToAdd)
	
	return cardToAdd

func get_some_card():
	var num_cards = randi() % (maxRandomItemNum - minRandomItemNum + 1) + minRandomItemNum
	var total_weight = get_total_weight(siteItems)
	var selected_cards = []
	
	for i in range(num_cards):
		var random_num = randi() % total_weight
		var cumulative_weight = 0
		for c in siteItems.keys():
			cumulative_weight += siteItems[c]
			if random_num < cumulative_weight:
				selected_cards.append(c)
				break

	for c in selected_cards:
		await get_tree().create_timer(0.1).timeout
		add_new_card(c, scene_3, scene_1)
	
	var current_total_price = calculate_total_card_price(scene_3)
	print("尝试更新仪表盘: dashboard_node 是否有效? ", dashboard_node != null)

	if dashboard_node != null:
		if dashboard_node.has_method("update_card_display"):
			if !selected_cards.is_empty():
				var first_card_name = selected_cards[0]
				if CardInfos.infosDic.has(first_card_name):
					var card_info_to_display = CardInfos.infosDic[first_card_name]
					print("调用 dashboard_node.update_card_display with card_info for: ", first_card_name)
					dashboard_node.update_card_display(card_info_to_display)
				else:
					print("Error (main.gd): CardInfo not found for ", first_card_name, " in CardInfos.infosDic. Clearing dashboard.")
					dashboard_node.update_card_display(null) # Clear dashboard
			else:
				print("No cards selected to display on dashboard. Clearing dashboard.")
				dashboard_node.update_card_display(null) # Clear dashboard
		else:
			print("Error (main.gd): dashboard_node does not have 'update_card_display' method.")
	elif dashboard_node == null:
		print("Error (main.gd): dashboard_node is not assigned. Cannot update display.")

func calculate_total_card_price(deck_node: Node) -> float:
	var total_price: float = 0.0
	if deck_node == null:
		print("Error (main.gd): Deck node (scene_3) is null.")
		return 0.0

	var actual_card_container_path = "cardDcek"
	var actual_card_container = deck_node.get_node_or_null(actual_card_container_path)
	
	if actual_card_container == null:
		print("Error (main.gd): Could not find '", actual_card_container_path, "' node inside '", deck_node.name, "'. Make sure the path is correct.")
		return 0.0
	
	print("Calculating total price for actual container: ", actual_card_container.name, " (path: ", actual_card_container_path, ") which has ", actual_card_container.get_child_count(), " children.") # DEBUG
	for child_node in actual_card_container.get_children():
		print("  Checking child: ", child_node.name) # DEBUG
		if child_node.has_meta("is_card_instance"): 
			print("    Child ", child_node.name, " has 'is_card_instance' meta.") # DEBUG
			var card_instance = child_node as card
			if card_instance != null:
				print("      Child ", child_node.name, " cast to card instance successfully.") # DEBUG
				if card_instance.cardInfo.has("base_price"):
					var price_value = card_instance.cardInfo["base_price"]
					print("        Found base_price for ", card_instance.cardName, ": ", price_value, " (Type: ", typeof(price_value), ")") # DEBUG
					
					var price_as_float: float = 0.0
					if price_value is String:
						if price_value.is_valid_float():
							price_as_float = float(price_value)
							print("          Converted string '", price_value, "' to float: ", price_as_float) # DEBUG
						else:
							print("          Warning (main.gd): Card '", card_instance.cardName, "' base_price string '", price_value, "' is not a valid float.")
					elif price_value is float:
						price_as_float = price_value
						print("          Used float value directly: ", price_as_float) # DEBUG
					elif price_value is int:
						price_as_float = float(price_value)
						print("          Converted int value ", price_value, " to float: ", price_as_float) # DEBUG
					else:
						print("          Warning (main.gd): Card '", card_instance.cardName, "' has base_price of unexpected type: ", typeof(price_value))
					
					total_price += price_as_float
					print("          Current total_price: ", total_price) # DEBUG
				else:
					print("      Warning (main.gd): Card '", card_instance.cardName, "' 在 cardInfo 中缺失 'base_price' 属性.") # DEBUG
			else:
				print("    Warning (main.gd): Child ", child_node.name, " could not be cast to card instance.") # DEBUG
		else:
			print("    Child ", child_node.name, " does NOT have 'is_card_instance' meta.") # DEBUG
			
	print("Finished calculating. Final total_price: ", total_price) # DEBUG
	return total_price

func get_total_weight(card_dict):
	var total_weight = 0
	for weight in card_dict.values():
		total_weight += weight
	return total_weight
