extends BaseCardEffect
class_name PleasureAddictionEffect

var red_cards_used_this_turn: int = 0

func apply_effect(target: Node) -> void:
    print("PleasureAddictionEffect: apply_effect called on target: ", target)
    # Main effect: DM+3, draw 1 card for each red card used
    target.modify_dm(3)
    print("PleasureAddictionEffect: DM modified by +3. Red cards used this turn: ", red_cards_used_this_turn)
    
    # Note: Card drawing would be handled by the deck system
    # For each red card used this turn, draw one card
    
    # Special effect: Permanently reduce RV max by 1
    target.modify_hand_size(-1)  # Using hand size modification as a proxy for RV max reduction 
    print("PleasureAddictionEffect: RV max (proxied by max_hand_size) reduced by 1.") 