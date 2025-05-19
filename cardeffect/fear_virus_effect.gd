extends BaseCardEffect
class_name FearVirusEffect

func apply_effect(target: Node) -> void:
    print("FearVirusEffect: apply_effect called on target: ", target)
    # Main effect: RV-3, AV+2
    target.modify_rv(-3)
    target.modify_av(2)
    print("FearVirusEffect: RV modified by -3, AV modified by +2")
    
    # Check for special condition
    if check_special_condition(target):
        print("FearVirusEffect: Special condition met (RV <= 5)")
        # Special effect: Discard 2 cards
        for i in range(2):
            emit_signal("card_discarded", target)
            print("FearVirusEffect: card_discarded signal emitted for target: ", target)
    else:
        print("FearVirusEffect: Special condition not met (RV > 5)")

func check_special_condition(target: Node) -> bool:
    print("FearVirusEffect: check_special_condition called on target: ", target)
    # Special condition: RV ≤ 5
    return target.rv <= 5 