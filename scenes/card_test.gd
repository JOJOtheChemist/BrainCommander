extends Control

# 卡牌管理器引用
var card_view_manager = null

# 当前显示的卡牌索引
var current_card_index = 0
var card_names = []

func _ready():
    # 获取卡牌信息管理器
    var card_info_manager = get_node_or_null("/root/CardInfoManager")
    if card_info_manager:
        # 获取所有卡牌名称
        card_names = card_info_manager.infosDic.keys()
        print("已加载卡牌: ", card_names)
    
    # 获取卡牌节点
    var card_node = get_node_or_null("Card")
    if card_node:
        # 创建卡牌管理器
        card_view_manager = CardViewManager.new(card_node)
        
        # 显示第一张卡
        if not card_names.is_empty():
            display_card(current_card_index)
    
    # 连接按钮信号
    var next_btn = get_node_or_null("NextButton")
    var prev_btn = get_node_or_null("PrevButton")
    
    if next_btn:
        next_btn.pressed.connect(_on_next_pressed)
    
    if prev_btn:
        prev_btn.pressed.connect(_on_prev_pressed)

# 显示指定索引的卡牌
func display_card(index):
    if card_view_manager and index >= 0 and index < card_names.size():
        var card_name = card_names[index]
        card_view_manager.update_card_view(card_name)
        
        # 更新标题
        var title = get_node_or_null("TitleLabel")
        if title:
            title.text = "卡牌 " + str(index + 1) + " / " + str(card_names.size()) + ": " + card_name

# 下一张卡牌
func _on_next_pressed():
    current_card_index = (current_card_index + 1) % card_names.size()
    display_card(current_card_index)

# 上一张卡牌
func _on_prev_pressed():
    current_card_index = (current_card_index - 1 + card_names.size()) % card_names.size()
    display_card(current_card_index) 