extends Node
class_name CardInfoManagerClass

var file_path = "res://assets/phyco-card-short.csv"
var infosDic: Dictionary

func _ready() -> void:
	infosDic = read_csv_as_nested_dict(file_path)
	print("已加载 " + str(infosDic.size()) + " 张卡牌信息")

# 函数读取CSV文件并将其转换为嵌套字典
func read_csv_as_nested_dict(path: String) -> Dictionary:
	var data = {}
	var file = FileAccess.open(path, FileAccess.READ)
	var headers = []
	var first_line = true
	
	while not file.eof_reached():
		var values = file.get_csv_line()
		if first_line:
			headers = values
			first_line = false
		elif values.size() >= 2:
			var key = values[0]  # 使用base_cardName作为键
			var row_dict = {}
			for i in range(0, headers.size()):
				if i < values.size():
					row_dict[headers[i]] = values[i]
				else:
					row_dict[headers[i]] = ""
			data[key] = row_dict
	
	file.close()
	return data

# 获取卡牌信息
func get_card_info(card_name: String) -> Dictionary:
	if infosDic.has(card_name):
		return infosDic[card_name]
	return {} 
