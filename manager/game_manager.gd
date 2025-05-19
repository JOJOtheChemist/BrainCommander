# managers/game_manager.gd
extends Node

# 你需要在 main.tscn 中将对应的节点赋值给这些变量
# 或者，如果 GameManager 是一个 Autoload，则在 _ready 中通过 get_tree().get_first_node_in_group() 等方式获取
var hand_deck_node: DeckBase 
var play_area_deck_node: DeckBase
# var player_stats_node: Node # 如果你有玩家状态管理器

func _ready():
    print("GameManager initialized.")
    # 确保在 main.gd 中正确设置了这些节点的引用
    # 示例：
    # hand_deck_node = get_node("/root/MainScene/PathToHandDeck") 
    # play_area_deck_node = get_node("/root/MainScene/PathToPlayAreaDeck")
    # 这通常在 main.gd 中进行设置，然后传递给 GameManager，或者 GameManager 自己获取

func get_cards_in_play_area() -> Array[card]:
    if play_area_deck_node != null:
        return play_area_deck_node.get_cards()
    printerr("GameManager: Play area deck node not set!")
    return []

func get_hand_card_count() -> int:
    if hand_deck_node != null:
        return hand_deck_node.get_card_count()
    printerr("GameManager: Hand deck node not set!")
    return 0

func get_hand_cards() -> Array[card]:
    if hand_deck_node != null:
        return hand_deck_node.get_cards()
    printerr("GameManager: Hand deck node not set!")
    return []

# 示例：执行出牌区卡牌的“加减”操作（具体含义需要你定义）
# "加减"如果是指卡牌效果，那么这个逻辑会更复杂，可能需要每张卡牌有自己的效果脚本
func process_play_area_effects():
    var cards_in_play = get_cards_in_play_area()
    if cards_in_play.is_empty():
        print("GameManager: No cards in play area to process effects.")
        return

    print("GameManager: Processing effects for cards in play area...")
    for card_in_play in cards_in_play:
        print("  - Processing card: " + card_in_play.name)
        # 这里你需要根据卡牌信息 card_in_play.cardInfo 来决定执行什么操作
        # 例如：card_in_play.apply_effect(target_player_stats_node)
        # 这要求 card.gd 有 apply_effect 方法，或者链接到对应的效果脚本
        if card_in_play.has_method("apply_persistent_effect"): # 假设卡牌有持续效果
             card_in_play.apply_persistent_effect()


func trigger_random_discard_from_hand():
    if hand_deck_node != null:
        var discarded_card = hand_deck_node.random_discard_card()
        if discarded_card != null:
            print("GameManager: " + discarded_card.name + " was randomly discarded from hand.")
            # 之后可能需要将 discarded_card 移到弃牌堆
            discarded_card.queue_free() # 简单处理
            return true
    return false

# ... 其他游戏管理函数 ...