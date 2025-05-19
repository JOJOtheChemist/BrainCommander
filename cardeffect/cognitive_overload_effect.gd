extends BaseCardEffect
class_name CognitiveOverloadEffect

func apply_effect(target: Node) -> void:
    print("CognitiveOverloadEffect: apply_effect called on target: ", target)
    # Main effect: RV-4, hand size -2
    target.modify_rv(-4)
    target.modify_hand_size(-2)
    print("CognitiveOverloadEffect: RV modified by -4, max_hand_size modified by -2.")
    
    # Check for special condition
    if check_special_condition(target):
        print("CognitiveOverloadEffect: Special condition met (RV <= 8). Cannot use event cards noted.")
        # Special effect: Cannot use event cards this turn
        # This would be handled by the card usage system
        pass
    else:
        print("CognitiveOverloadEffect: Special condition not met (RV > 8).")

func check_special_condition(target: Node) -> bool:
    print("CognitiveOverloadEffect: check_special_condition called on target: ", target)
    # Special condition: RV ≤ 8
    return target.rv <= 8 