# deck/deck-self.gd
extends "res://deck/deck.gd" # 或者 extends DeckBase 如果 deck.gd 使用了 class_name

@export var max_hand_size: int = 7 # 手牌上限

func _ready():
    print(self.name + " (Hand Deck) initialized. Max hand size: " + str(max_hand_size))

# 重写 add_card 以加入手牌上限逻辑
func add_card(cardToAdd: card) -> void:
    if get_card_count() >= max_hand_size:
        print("Hand is full! Cannot add " + cardToAdd.name + ". Discarding or returning card.")
        # 此处可以实现弃牌逻辑，或将牌退回来源等
        cardToAdd.queue_free() # 简单处理：直接销毁多余的牌
        return

    super(cardToAdd) # 调用父类的 add_card
    
    # 手牌区的牌应该是可以拖动的（初始状态）
    if cardToAdd.has_method("set_in_play_area"): # 使用你在 card.gd 中添加的方法
        cardToAdd.set_in_play_area(false)
    cardToAdd.cardCurrentState = cardToAdd.cardState.following # 或 dragging，取决于你的默认交互

    print(cardToAdd.name + " added to hand (" + self.name + "). Current hand size: " + str(get_card_count()))

func is_full() -> bool:
    return get_card_count() >= max_hand_size

func random_discard_card() -> card:
    var cards_in_hand = get_cards()
    if cards_in_hand.is_empty():
        print("Hand is empty, cannot discard.")
        return null
    
    var card_to_discard = cards_in_hand.pick_random()
    if card_to_discard != null:
        print("Randomly discarding: " + card_to_discard.name)
        remove_card(card_to_discard) # 从手牌中移除
        # card_to_discard.queue_free() # 决定是否销毁或移到弃牌堆
        return card_to_discard
    return null

# 替换卡牌的逻辑可能比较复杂，涉及到创建新卡牌，暂时先不实现
# func replace_card(old_card: card, new_card_info: Dictionary) -> card:
    # ...

func print_hand_cards() -> void:
	if cardDeck == null:
		print(self.name + ": Card deck container (cardDeck) is not initialized.")
		return

	var cards_in_hand = cardDeck.get_children()
	if cards_in_hand.is_empty():
		print(self.name + " (Hand) is empty.")
		return

	print("Cards in " + self.name + " (Hand) - Count: " + str(cards_in_hand.size()) + "/")
	for i in range(cards_in_hand.size()):
		var card_node = cards_in_hand[i]
		# Attempt to get the card's actual script/class if it's a 'card'
		# This assumes your 'card' script has a class_name Card or similar
		# and that card_node is indeed an instance of it.
		if card_node.has_meta("script") and "card.gd" in card_node.get_meta("script").get_path().to_lower() or card_node.get_script().get_path().ends_with("card.gd") :
			print("  Index " + str(i) + ": '" + card_node.name + "' (Type: Card)")
		else:
			print("  Index " + str(i) + ": '" + card_node.name + "' (Type: " + str(card_node.get_class()) + ")")