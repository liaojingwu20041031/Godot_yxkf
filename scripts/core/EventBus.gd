extends Node

signal player_hit(damage: int, source: Node)
signal player_died
signal player_health_changed(current: int, maximum: int)
signal player_shield_changed(current: int, maximum: int)
signal enemy_died(enemy: Node)
signal enemy_hit(enemy: Node, damage: int)
signal room_cleared
signal room_entered(room_type: String)
signal item_picked_up(item_data: Dictionary)
signal gold_changed(amount: int)
signal key_changed(amount: int)
signal potion_used
signal upgrade_selected(upgrade_id: String)
signal boss_phase_changed(phase: int)
signal boss_died
signal game_over(victory: bool)
signal pause_game
signal unpause_game
signal show_reward_panel(rewards: Array)
signal hide_reward_panel
signal show_tooltip(item_data: Dictionary)
signal hide_tooltip
signal show_room_message(text: String)
