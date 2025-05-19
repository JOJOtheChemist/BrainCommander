extends Control
class_name card

var velocity = Vector2.ZERO
var damping = 0.35
var stiffness = 500

var preDeck

@export var cardClass:String
@export var cardName:String
@export var maxStackNum:int
@export var cardWeight:float
@export var cardInfo:Dictionary

var pickButton

enum cardState{following,dragging, in_play_area}
@export var cardCurrentState=cardState.following

@export var follow_target:Node
var whichDeckMouseIn

var is_in_play_area: bool = false

func _process(delta: float) -> void:
	if is_in_play_area:
		return

	match  cardCurrentState:
		cardState.dragging:
			var target_position=get_global_mouse_position()-size/2
			global_position=global_position.lerp(target_position, 0.4)
			
			var mouse_position = get_global_mouse_position()
			var nodes = get_tree().get_nodes_in_group("cardDropable")
			for node in nodes:
				if node.get_global_rect().has_point(mouse_position)&&node.visible==true:
					whichDeckMouseIn=node
			
		cardState.following:
			if follow_target!=null:
				var target_position=follow_target.global_position
				var displacement = target_position - global_position
				var force = displacement * stiffness
				velocity += force * delta
				velocity *= (1.0 - damping)
				global_position += velocity * delta




func _on_button_button_down() -> void:
	if is_in_play_area:
		print(cardName + " is in play area, cannot be dragged.")
		return

	cardCurrentState = cardState.dragging
	if follow_target!=null:
		follow_target.queue_free()
		follow_target = null
	print(cardName + " started dragging.")


func _on_button_button_up() -> void:
	if is_in_play_area:
		return

	cardCurrentState = cardState.following

	if whichDeckMouseIn!=null:
		print(cardName + " dropped on " + whichDeckMouseIn.name)
		whichDeckMouseIn.add_card(self)
	else:
		print(cardName + " returned to preDeck " + preDeck.name)
		preDeck.add_card(self)

	whichDeckMouseIn = null

func initCard(Nm) -> void:
	cardInfo=CardInfos.infosDic[Nm]
	cardWeight=float(cardInfo["base_cardWeight"])
	cardClass=cardInfo["base_cardClass"]
	cardName=cardInfo["base_cardName"]
	is_in_play_area = false
	cardCurrentState=cardState.following
	drawCard()
	self.set_meta("is_card_instance", true)


func drawCard():
	pickButton = $Button
	var imgPath = "res://cardImg/" + str(cardName) + ".png"
	var texture: Texture2D = null
	if ResourceLoader.exists(imgPath):
		texture = load(imgPath)
	else:
		print("警告: 找不到图片资源: ", imgPath, "，使用默认图片。")
		# texture = load("res://icon.svg") # Ensure you have a default image

	var original_size = texture.get_size() if texture else Vector2(100, 100)
	var target_size = original_size * 0.3

	var item_img_node = $Control/ColorRect/itemImg if $Control and $Control.has_node("ColorRect/itemImg") else null
	if item_img_node:
		item_img_node.texture = texture
		item_img_node.anchor_left = 0
		item_img_node.anchor_top = 0
		item_img_node.anchor_right = 1
		item_img_node.anchor_bottom = 1
		item_img_node.custom_minimum_size = target_size
		item_img_node.expand = true
		item_img_node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	# 父容器和背景同理
	if $Control:
		$Control.anchor_left = 0
		$Control.anchor_top = 0
		$Control.anchor_right = 1
		$Control.anchor_bottom = 1
		$Control.custom_minimum_size = target_size
		if $Control/ColorRect:
			var color_rect = $Control/ColorRect
			color_rect.anchor_left = 0
			color_rect.anchor_top = 0
			color_rect.anchor_right = 1
			color_rect.anchor_bottom = 1
			color_rect.custom_minimum_size = target_size

	if pickButton:
		pickButton.anchor_left = 0
		pickButton.anchor_top = 0
		pickButton.anchor_right = 1
		pickButton.anchor_bottom = 1
		pickButton.custom_minimum_size = target_size

	var name_label_node = $Control/ColorRect/name if $Control and $Control.has_node("ColorRect/name") else null
	if name_label_node:
		name_label_node.text = cardInfo.get("base_displayName", cardName)
		name_label_node.anchor_left = 0
		name_label_node.anchor_right = 1

func set_in_play_area(status: bool):
	is_in_play_area = status
	if is_in_play_area:
		cardCurrentState = cardState.in_play_area
		velocity = Vector2.ZERO
		print(cardName + " set to in_play_area: ", status)
	else:
		cardCurrentState = cardState.following
