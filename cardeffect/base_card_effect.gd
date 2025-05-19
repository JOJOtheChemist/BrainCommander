extends Node
class_name BaseCardEffect

# Player stats
var rv: int = 10  # Rational Value
var av: int = 10  # Amygdala Value
var dm: int = 10  # Dopamine Value
var mv: int = 10  # Memory Value

# Card state
var hand_size: int = 7
var max_hand_size: int = 7

# Signal declarations
signal stats_changed(stat_name: String, new_value: int)
signal hand_size_changed(new_size: int)
signal card_discarded(card: Node)

# Base functions for stat modifications
func modify_rv(amount: int) -> void:
    print("BaseCardEffect: modify_rv called with amount: ", amount)
    rv = max(0, rv + amount)
    print("BaseCardEffect: RV changed to: ", rv)
    emit_signal("stats_changed", "rv", rv)

func modify_av(amount: int) -> void:
    print("BaseCardEffect: modify_av called with amount: ", amount)
    av = max(0, av + amount)
    print("BaseCardEffect: AV changed to: ", av)
    emit_signal("stats_changed", "av", av)

func modify_dm(amount: int) -> void:
    print("BaseCardEffect: modify_dm called with amount: ", amount)
    dm = max(0, dm + amount)
    print("BaseCardEffect: DM changed to: ", dm)
    emit_signal("stats_changed", "dm", dm)

func modify_mv(amount: int) -> void:
    print("BaseCardEffect: modify_mv called with amount: ", amount)
    mv = max(0, mv + amount)
    print("BaseCardEffect: MV changed to: ", mv)
    emit_signal("stats_changed", "mv", mv)

func modify_hand_size(amount: int) -> void:
    print("BaseCardEffect: modify_hand_size called with amount: ", amount)
    max_hand_size = max(1, max_hand_size + amount)
    print("BaseCardEffect: max_hand_size changed to: ", max_hand_size)
    emit_signal("hand_size_changed", max_hand_size)

# Virtual function to be implemented by each card
func apply_effect(target: Node) -> void:
    print("BaseCardEffect: apply_effect called on target: ", target)
    pass

# Virtual function for special conditions
func check_special_condition(target: Node) -> bool:
    print("BaseCardEffect: check_special_condition called on target: ", target)
    return false 