extends Node

enum PowerType {
	POWER_TARGETTING_ANY_COIN, POWER_TARGETTING_MONSTER_COIN, POWER_TARGETTING_PLAYER_COIN, 
	POWER_NON_TARGETTING,
	
	PASSIVE,
	
	CHARON,
	
	# monsters
	PAYOFF_GAIN_SOULS, PAYOFF_LOSE_SOULS,
	PAYOFF_LOSE_LIFE, PAYOFF_GAIN_LIFE, 
	PAYOFF_SOMETHING_POSITIVE,
	PAYOFF_STOKE_FLAME,
	PAYOFF_MONSTER
}

class PowerFamily:
	enum Tag {
		REFLIP, FREEZE, LUCKY, GAIN, DESTROY, UPGRADE, HEAL, POSITIONING, CURSE, BLESS, TURN, TRADE, IGNITE, ANTIMONSTER, STONE, BLANK, CONSECRATE, DOOM, BURY, CHARGE
	}
	
	var description: String:
		get:
			return Global.replace_placeholders(description)
	var uses_for_denom: Array[int]
	var power_type: PowerType
	var icon_path: String
	var prefer_icon_only: bool
	var tags: Array
	
	func _init(desc: String, uses_per_denom: Array[int], pwrType: PowerType, icon: String, pref_icn_only: bool, tgs: Array = []) -> void:
		self.description = desc
		self.uses_for_denom = uses_per_denom
		self.power_type = pwrType
		self.icon_path = icon
		self.prefer_icon_only = pref_icn_only
		assert(FileAccess.file_exists(self.icon_path))
		self.tags = tgs
	
	func get_power_type_placeholder() -> String:
		if is_power():
			return "(POWER)"
		if is_passive():
			return "(PASSIVE)"
		if is_payoff():
			if power_type == PowerType.PAYOFF_GAIN_SOULS or power_type == PowerType.PAYOFF_LOSE_SOULS:
				return "(PAYOFF_SOULS)"
			elif power_type == PowerType.PAYOFF_LOSE_LIFE:
				return "(PAYOFF_LIFE)"
			elif power_type == PowerType.PAYOFF_STOKE_FLAME:
				return "(PAYOFF_FLAME)"
			elif power_type == PowerType.PAYOFF_SOMETHING_POSITIVE or power_type == PowerType.PAYOFF_GAIN_LIFE:
				return "(PAYOFF_OTHER)"
			else:
				return "(PAYOFF_PURPLE)"
		assert(is_charon())
		return ""
	
	func is_payoff() -> bool:
		return power_type != PowerType.POWER_TARGETTING_ANY_COIN and\
			power_type != PowerType.POWER_TARGETTING_MONSTER_COIN and\
			power_type != PowerType.POWER_TARGETTING_PLAYER_COIN and\
			power_type != PowerType.POWER_NON_TARGETTING and\
			power_type != PowerType.PASSIVE and\
			power_type != PowerType.CHARON
	
	func is_charon() -> bool:
		return power_type == PowerType.CHARON
	
	func is_power() -> bool:
		return power_type == PowerType.POWER_TARGETTING_ANY_COIN or\
			power_type == PowerType.POWER_TARGETTING_MONSTER_COIN or\
			power_type == PowerType.POWER_TARGETTING_PLAYER_COIN or\
			power_type == PowerType.POWER_NON_TARGETTING
	
	func is_passive() -> bool:
		return power_type == PowerType.PASSIVE
	
	func has_tag(tag: Tag) -> bool:
		return tags.has(tag)
	
	func can_target_monster_coins() -> bool:
		return power_type == PowerType.POWER_TARGETTING_ANY_COIN or power_type == PowerType.POWER_TARGETTING_MONSTER_COIN
		
	func can_target_player_coins() -> bool:
		return power_type == PowerType.POWER_TARGETTING_ANY_COIN or power_type == PowerType.POWER_TARGETTING_PLAYER_COIN
	
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		assert(false, "shouldn't have called this...")
	
	class CanUseResult:
		var can_use: bool = false
		var error_message: String = ""
		
		func _init(usable: bool, error_msg: String = "") -> void:
			can_use = usable
			error_message = error_msg
			assert(can_use or error_msg != "") # make sure we provide a message if not usable
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(false, "Can't activate that...")


# Subclasses for each power
class Reflip extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		game.safe_flip(target, false)
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if not target.can_flip():
			return CanUseResult.new(false, "Can't flip stoned coin...")
		return CanUseResult.new(true)

class Freeze extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		target.freeze()
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if target.is_frozen():
			return CanUseResult.new(false, "It's already (FROZEN)...")
		return CanUseResult.new(true)

class ReflipAndNeighbors extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		game.safe_flip(target, false)
		if left:
			left.play_power_used_effect(Global.active_coin_power_family)
			left.safe_flip(left, false)
		if right:
			right.play_power_used_effect(Global.active_coin_power_family)
			right.safe_flip(left, false)
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if (not target.can_flip()) and (not left or (left and not left.can_flip())) and (not right or (right and not right.can_flip())):
			return CanUseResult.new(false, "Can't flip stoned coin...")
		return CanUseResult.new(true)

class TurnAndBlurse extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		target.turn()
		target.curse() if target.is_heads() else target.bless()
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class ReducePenalty extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		target.change_life_penalty_for_round(-2)
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if not target.can_reduce_life_penalty():
			return CanUseResult.new(false, "No need...")
		return CanUseResult.new(true)

class PrimeAndIgnite extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		target.prime()
		target.ignite()
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if target.is_primed() and target.is_ignited():
			return CanUseResult.new(false, "No need...")
		return CanUseResult.new(true)

class CopyPowerForToss extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		Global.active_coin_power_coin.overwrite_active_face_power_for_toss(target.get_copied_power_family())
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if not target.can_copy_power() or target.get_copied_power_family() == Global.active_coin_power_family:
			return CanUseResult.new(false, "Can't copy that...")
		return CanUseResult.new(true)

class ClonePermanently extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		Global.active_coin_power_coin.init_coin(target.get_coin_family(), target.get_denomination(), Coin.Owner.PLAYER)
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if target.get_copied_power_family() == Global.active_coin_power_family:
			return CanUseResult.new(false, "Can't copy that...")
		if Global.active_coin_power_coin.get_denomination() != target.get_denomination():
			return CanUseResult.new(false, "Can't copy a different denomination...")
		return CanUseResult.new(true)

class CopyPowerPermanently extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		Global.active_coin_power_coin.overwrite_active_face_power(target.get_copied_power_family())
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if not target.can_copy_power() or target.get_copied_power_family() == Global.active_coin_power_family:
			return CanUseResult.new(false, "Can't copy that...")
		return CanUseResult.new(true)

class Exchange extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		var new_coin = game._make_and_gain_coin(Global.random_coin_family_excluding([target.get_coin_family()]), target.get_denomination(), game._CHARON_NEW_COIN_POSITION, true)
		new_coin.get_parent().move_child(new_coin, target.get_index())
		new_coin.play_power_used_effect(Global.active_coin_power_family)
		game.remove_coin_from_row_move_then_destroy(target, game._CHARON_NEW_COIN_POSITION)
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class MakeLucky extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		target.make_lucky()
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if not target.can_make_lucky():
			return CanUseResult.new(false, "No need...")
		return CanUseResult.new(true)

class DowngradeForLife extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		game.downgrade_coin(target)
		if target.is_monster_coin():
			Global.lives -= Global.HADES_MONSTER_COST[Global.active_coin_power_coin.get_value() - 1]
		elif target.is_owned_by_player():
			Global.heal_life(Global.HADES_SELF_GAIN[Global.active_coin_power_coin.get_value() - 1])
		else:
			assert(false, "Hades shouldn't get here...")
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if target.is_owned_by_player() and player_row.get_child_count() == 1 and target.get_denomination() == Global.Denomination.OBOL:
			return CanUseResult.new(false, "Can't destroy last coin...")
		return CanUseResult.new(true)

class Stone extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		if target.is_stone():
			target.clear_material()
		else:
			target.stone()
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if not target.is_stone() and not target.can_stone():
			return CanUseResult.new(false, "Can't (STONE) that...")
		return CanUseResult.new(true)

class BlankTails extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		target.blank()
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if not target.is_tails():
			return CanUseResult.new(false, "Can't use on (HEADS) coins...")
		if not target.can_blank():
			return CanUseResult.new(false, "Can't (BLANK) that...")
		if target.get_coin_family().has_tag(Global.CoinFamily.Tag.NEMESIS):
			return CanUseResult.new(false, "This can't (BLANK) the Nemesis...") 
		return CanUseResult.new(true)

class TurnTailsFreezeReducePenalty extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		target.freeze()
		if target.is_owned_by_player():
			target.change_life_penalty_for_round(-500000)
		if target.is_heads():
			target.turn()
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if not target.can_reduce_life_penalty() and not target.can_freeze() and target.is_tails():
			return CanUseResult.new(true, "No need...")
		return CanUseResult.new(true)

class IgniteChargeLucky extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		target.ignite()
		target.charge()
		target.make_lucky()
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if not target.can_ignite() and not target.can_charge() and not target.can_make_lucky():
			return CanUseResult.new(false, "No need...")
		return CanUseResult.new(true)

class ConsecrateDoom extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		target.consecrate()
		target.doom()
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if target.is_doomed() and target.is_consecrated():
			return CanUseResult.new(false, "No need...")
		return CanUseResult.new(true)

class BuryHarvest extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		target.bury(3)
		target.set_coin_metadata(Coin.METADATA_TRIPTOLEMUS, Global.TRIPTOLEMUS_HARVEST[Global.active_coin_power_coin.get_denomination()])
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class BuryTurnOtherTails extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		target.bury(1)
		for c in Global.choose_one(target_row.get_multi_filtered_randomized([CoinRow.FILTER_CAN_TARGET, CoinRow.FILTER_TAILS])):
			c.turn()
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class InfiniteTurnHunger extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		var current_cost = Global.active_coin_power_coin.get_active_face_metadata(Coin.METADATA_ERYSICHTHON, 0)
		Global.lives -= current_cost
		Global.active_coin_power_coin.set_active_face_metadata(Coin.METADATA_ERYSICHTHON, current_cost + 1)
		target.turn()
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if not target.can_turn():
			return CanUseResult.new(false, "Can't turn that...")
		return CanUseResult.new(true)

class FlipAndTag extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		target.set_coin_metadata(Coin.METADATA_ERIS, true)
		for c in player_row.get_children() + enemy_row.get_children():
			if c.get_coin_metadata(Coin.METADATA_ERIS, false):
				if c.can_flip():
					c.play_power_used_effect(Global.active_coin_power_family)
					game.safe_flip(c, false)
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if not target.can_flip():
			return CanUseResult.new(false, "Can't flip stoned coin...")
		return CanUseResult.new(true)

class SwapReflipNeighbors extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		pass
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if not target.can_flip():
			return CanUseResult.new(false, "Can't flip stoned coin...")
		return CanUseResult.new(true)

class IgniteThenBlessThenSacrifice extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		target_row.swap_positions(Global.active_coin_power_coin, target)
		if left:
			left.play_power_used_effect(Global.active_coin_power_family)
			game.safe_flip(left, false)
		if right:
			right.play_power_used_effect(Global.active_coin_power_family)
			game.safe_flip(right, false)
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if not target.is_ignited() and not target.can_ignite():
			return CanUseResult.new(false, "Can't ignite that...")
		if target.is_ignited() and not target.is_blessed() and not target.can_bless():
			return CanUseResult.new(false, "Can't bless that...")
		if target.is_ignited() and target.is_blessed() and\
			target.is_owned_by_player() and player_row.get_child_count() == 1 and target.get_denomination() == Global.Denomination.OBOL:
			return CanUseResult.new(false, "Can't destroy that...")
		return CanUseResult.new(true)

class GainLife extends PowerFamily:
	func use_power(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		Global.heal_life(Global.DEMETER_GAIN[activated.get_denomination()])
	
	func can_use(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class GainArrow extends PowerFamily:
	func use_power(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		Global.arrows = min(Global.arrows + (activated.get_denomination()+1), Global.ARROWS_LIMIT)
	
	func can_use(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if Global.arrows == Global.ARROWS_LIMIT:
			return CanUseResult.new(false, "Too many arrows...")
		return CanUseResult.new(true)

class ReflipAll extends PowerFamily:
	func use_power(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		for c in player_row.get_children() + enemy_row.get_children():
			c.play_power_used_effect(Global.POWER_FAMILY_REFLIP_ALL)
			game.safe_flip(c, false)
	
	func can_use(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		var can_flip_something = false
		for c in player_row.get_children() + enemy_row.get_children():
			if c.can_flip():
				can_flip_something = true
				break
		if not can_flip_something:
			return CanUseResult.new(false, "Can't flip anything...")
		return CanUseResult.new(true)

class GainCoin extends PowerFamily:
	func use_power(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		var new_coin = game.make_and_gain_coin(Global.random_coin_family(), Global.Denomination.OBOL, activated.global_position, true)
		new_coin.play_power_used_effect(activated.get_active_power_family())
	
	func can_use(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if player_row.get_child_count() == Global.COIN_LIMIT:
			return CanUseResult.new(false, "Too many coins...")
		return CanUseResult.new(true)

class DestroySelfForReward extends PowerFamily:
	func use_power(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		Global.earn_souls(Global.PHAETHON_REWARD_SOULS[activated.get_denomination()])
		Global.heal_life(Global.PHAETHON_REWARD_LIFE[activated.get_denomination()])
		Global.arrows = min(Global.arrows + Global.PHAETHON_REWARD_ARROWS[activated.get_denomination()], Global.ARROWS_LIMIT)
		Global.patron_uses = Global.patron.get_uses_per_round()
		game.destroy_coin(activated)
	
	func can_use(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class TurnSelf extends PowerFamily:
	func use_power(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		activated.turn()
	
	func can_use(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class ReflipLeftAlternating extends PowerFamily:
	func use_power(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		var all_left = target_row.get_all_left_of(activated)
		for c in all_left:
			if c.can_flip():
				game.safe_flip(c, false)
				c.play_power_used_effect(activated.get_active_power_family())
		var chrgs = activated.get_active_power_charges() - 1
		activated.overwrite_active_face_power(Global.POWER_FAMILY_REFLIP_RIGHT_ALTERNATING)
		activated.set_active_power_charges(chrgs)
	
	func can_use(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class ReflipRightAlternating extends PowerFamily:
	func use_power(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		var all_right = target_row.get_all_right_of(activated)
		for c in all_right:
			if c.can_flip():
				game.safe_flip(c, false)
				c.play_power_used_effect(activated.get_active_power_family())
		var chrgs = activated.get_active_power_charges() - 1
		activated.overwrite_active_face_power(Global.POWER_FAMILY_REFLIP_LEFT_ALTERNATING)
		activated.set_active_power_charges(chrgs)
	
	func can_use(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class GainPlutusCoin extends PowerFamily:
	func use_power(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		var new_coin = game.make_and_gain_coin(Global.GENERATED_PLUTUS_FAMILY, Global.Denomination.OBOL, activated.global_position, true)
		new_coin.play_power_used_effect(activated.get_active_power_family())
		new_coin.make_fleeting()
		if new_coin.can_flip():
			game.safe_flip(new_coin, true)
	
	func can_use(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if player_row.get_child_count() == Global.COIN_LIMIT:
			return CanUseResult.new(false, "Too many coins...")
		return CanUseResult.new(true)

class GainGoldenCoin extends PowerFamily:
	func use_power(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		var new_coin = game.make_and_gain_coin(Global.GENERATED_GOLDEN_FAMILY, activated.get_denomination(), activated.global_position, true)
		new_coin.play_power_used_effect(activated.get_active_power_family())
	
	func can_use(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if player_row.get_child_count() == Global.COIN_LIMIT:
			return CanUseResult.new(false, "Too many coins...")
		return CanUseResult.new(true)

class TurnAll extends PowerFamily:
	func use_power(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		for c in player_row.get_children() + enemy_row.get_children():
			c.turn()
			c.play_power_used_effect(Global.POWER_FAMILY_TURN_ALL) # pass in power family direclty here since it might turn itself
	
	func can_use(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)





# PATRON POWERS
class PatronCharon extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		target.turn()
		target.make_lucky()
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		assert(target != null)
		return CanUseResult.new(true)

class PatronAthena extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		target.change_life_penalty_permanently(-2)
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		assert(target != null)
		if not target.can_reduce_life_penalty():
			return CanUseResult.new(false, "No need...")
		return CanUseResult.new(true)

class PatronApollo extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		target.clear_statuses()
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		assert(target != null)
		if not target.has_status():
			return CanUseResult.new(false, "No need...")
		return CanUseResult.new(true)

class PatronHephaestus extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		target.upgrade()
		target.reset_power_uses(true)
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		assert(target != null)
		if not target.can_upgrade():
			return CanUseResult.new(false, "Can't upgrade further...")
		return CanUseResult.new(true)

class PatronHades extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		Global.heal_life(Global.HADES_PATRON_MULTIPLIER * target.get_value())
		Global.earn_souls(Global.HADES_PATRON_MULTIPLIER * target.get_value())
		game.destroy_coin(target)
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		assert(target != null)
		if player_row.get_child_count() == 1:
			return CanUseResult.new(false, "Can't destroy last coin...")
		return CanUseResult.new(true)

class PatronDemeter extends PowerFamily:
	func use_power(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		for coin in player_row.get_children():
			var as_coin: Coin = coin
			if as_coin.is_tails() and as_coin.get_active_power_family().power_type == PF.PowerType.PAYOFF_LOSE_LIFE:
				Global.heal_life(as_coin.get_active_power_charges())
				as_coin.play_power_used_effect(Global.patron.power_family)
	
	func can_use(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		var can_heal = false
		for coin in player_row.get_children():
			var as_coin: Coin = coin
			if as_coin.is_tails() and as_coin.get_active_power_family().power_type == PF.PowerType.PAYOFF_LOSE_LIFE:
				can_heal = true
				break
		if not can_heal:
			return CanUseResult.new(false, "No point...")
		return CanUseResult.new(true)

class PatronArtemis extends PowerFamily:
	func use_power(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		for coin in player_row.get_children() + enemy_row.get_children():
			coin.turn()
			coin.play_power_used_effect(Global.patron.power_family)
	
	func can_use(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PatronAphrodite extends PowerFamily:
	func use_power(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		for coin in player_row.get_children():
			var as_coin: Coin = coin
			if as_coin.is_active_face_power():
				as_coin.recharge_power_uses_by(2)
				as_coin.play_power_used_effect(Global.patron.power_family)
	
	func can_use(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		var can_recharge = false
		for coin in player_row.get_children():
			var as_coin: Coin = coin
			if as_coin.is_active_face_power():
				can_recharge = true
				break
		if not can_recharge:
			return CanUseResult.new(false, "No point...")
		return CanUseResult.new(true)

class PatronDionysus extends PowerFamily:
	func use_power(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		var tails = player_row.get_multi_filtered_randomized([CoinRow.FILTER_TAILS, CoinRow.FILTER_CAN_TARGET])
		var tails_powers =  tails.filter(CoinRow.FILTER_POWER)
		var heads = player_row.get_multi_filtered_randomized([CoinRow.FILTER_HEADS, CoinRow.FILTER_CAN_TARGET])
		var _heads_powers = heads.filter(CoinRow.FILTER_POWER)
		var n_coins = player_row.get_child_count()
		
		# savior check - if a lot of coins are tails, assist with that directly
		if heads.size() == 0 or (n_coins >= floor(Global.COIN_LIMIT / 2.0) and heads.size() <= 1) or (n_coins >= Global.COIN_LIMIT and heads.size() <= 2):
			var roll = Global.RNG.randi_range(1, 3)
			if heads.size() <= 3:
				roll = 1
			match(roll):
				1: # turn 2 powers to heads
					for coin in Global.choose_x(tails_powers, 2):
						coin.turn()
						coin.play_power_used_effect(Global.patron.power_family)
				2: # reflip 4 tails coins
					for coin in Global.choose_x(tails, 4):
						game.safe_flip(coin, false)
						coin.play_power_used_effect(Global.patron.power_family)
				3: # reflip all coins
					for coin in player_row.get_children():
						game.safe_flip(coin, false)
						coin.play_power_used_effect(Global.patron.power_family)
		else:  # otherwise, choose 2-3 helpful actions
			var boons = 0
			while boons < Global.RNG.randi_range(2, 3):
				match(Global.RNG.randi_range(1, 12)):
					1: # gain a coin
						if player_row.get_child_count() != Global.COIN_LIMIT and player_row.get_child_count() != Global.COIN_LIMIT - 1:
							var new_coin = game.make_and_gain_coin(Global.random_coin_family(), Global.Denomination.OBOL, game.PATRON_TOKEN_POSITION)
							if Global.RNG.randi_range(1, 3) == 1:
								new_coin.make_lucky()
							if Global.RNG.randi_range(1, 2) == 1:
								new_coin.bless()
							new_coin.play_power_used_effect(Global.patron.power_family)
							boons += 1
					2: # make coins lucky
						var not_lucky = player_row.get_multi_filtered_randomized([CoinRow.FILTER_NOT_LUCKY, CoinRow.FILTER_CAN_TARGET])
						if not_lucky.size() != 0:
							for coin in Global.choose_x(not_lucky, Global.RNG.randi_range(1, 3)):
								coin.make_lucky()
								coin.play_power_used_effect(Global.patron.power_family)
							boons += 1
					3: # make coins blessed
						var not_blessed = player_row.get_multi_filtered_randomized([CoinRow.FILTER_NOT_BLESSED, CoinRow.FILTER_CAN_TARGET])
						if not_blessed.size() != 0:
							for coin in Global.choose_x(not_blessed, Global.RNG.randi_range(1, 3)):
								coin.bless()
								coin.play_power_used_effect(Global.patron.power_family)
							boons += 1
					4: # freeze heads coins
						var not_frozen_heads = heads.filter(CoinRow.FILTER_NOT_FROZEN)
						if not_frozen_heads.size() != 0:
							for coin in Global.choose_x(not_frozen_heads, Global.RNG.randi_range(1, 3)):
								coin.freeze()
								coin.play_power_used_effect(Global.patron.power_family)
							boons += 1
					5: # clear ignite or frozen on tails
						var ignited = player_row.get_multi_filtered([CoinRow.FILTER_IGNITED, CoinRow.FILTER_CAN_TARGET])
						var frozen_tails = player_row.get_multi_filtered([CoinRow.FILTER_FROZEN, CoinRow.FILTER_TAILS, CoinRow.FILTER_CAN_TARGET])
						if ignited.size() + frozen_tails.size() >= floor(player_row.get_child_count() / 2.0):
							for coin in Global.choose_x(ignited, Global.RNG.randi_range(2, 3)):
								coin.clear_freeze_ignite()
								coin.play_power_used_effect(Global.patron.power_family)
							for coin in Global.choose_x(frozen_tails, Global.RNG.randi_range(2, 3)):
								coin.clear_freeze_ignite()
								coin.play_power_used_effect(Global.patron.power_family)
							boons += 1
					6: # clear unlucky, cursed, or blank
						var unlucky = player_row.get_multi_filtered([CoinRow.FILTER_UNLUCKY, CoinRow.FILTER_CAN_TARGET])
						var cursed = player_row.get_multi_filtered([CoinRow.FILTER_CURSED, CoinRow.FILTER_CAN_TARGET])
						var blank = player_row.get_multi_filtered([CoinRow.FILTER_BLANK, CoinRow.FILTER_CAN_TARGET])
						if unlucky.size() + cursed.size() + blank.size() >= floor(player_row.get_child_count() / 2.0):
							for coin in Global.choose_x(unlucky, Global.RNG.randi_range(2, 3)):
								coin.clear_lucky_unlucky()
								coin.play_power_used_effect(Global.patron.power_family)
							for coin in Global.choose_x(cursed, Global.RNG.randi_range(2, 3)):
								coin.clear_blessed_cursed()
								coin.play_power_used_effect(Global.patron.power_family)
							for coin in Global.choose_x(blank, Global.RNG.randi_range(2, 3)):
								coin.unblank()
								coin.play_power_used_effect(Global.patron.power_family)
							boons += 1
					7: # gain arrows
						if Global.arrows <= Global.ARROWS_LIMIT - floor(Global.ARROWS_LIMIT / 2.0):
							var bonus_arrows = Global.RNG.randi_range(1, 3)
							Global.arrows = min(Global.ARROWS_LIMIT, Global.arrows + bonus_arrows)
							boons += 1
					8: # blank a monster
						if not Global.is_current_round_trial() and enemy_row.get_child_count() != 0:
							for coin in Global.choose_x(enemy_row.get_children(), Global.RNG.randi_range(1, 2)):
								coin.blank()
								coin.play_power_used_effect(Global.patron.power_family)
							boons += 1
					9: # downgrade a monster
						if enemy_row.get_child_count() != 0:
							for coin in Global.choose_x(enemy_row.get_children(), Global.RNG.randi_range(2, 3)):
								game.downgrade_coin(coin)
								coin.play_power_used_effect(Global.patron.power_family)
							boons += 1
					10: # gain souls/life, just a generic bonus
						match(Global.RNG.randi_range(1, 2)):
							1:
								Global.earn_souls(max(4, Global.RNG.randi_range(Global.round_count, 2 * Global.round_count)))
							2:
								Global.heal_life(max(6, Global.RNG.randi_range(Global.round_count * 2, 3 * Global.round_count)))
						boons += 1
					11: # recharge coins
						var rechargable = player_row.get_multi_filtered([CoinRow.FILTER_RECHARGABLE, CoinRow.FILTER_CAN_TARGET])
						if rechargable.size() >= 3:
							for i in Global.RNG.randi_range(2, 4):
								var coin = Global.choose_one(rechargable)
								coin.recharge_power_uses_by(1)
								coin.play_power_used_effect(Global.patron.power_family)
					12: # charge coins
						var chargeable = player_row.get_multi_filtered([CoinRow.FILTER_NOT_CHARGED, CoinRow.FILTER_CAN_TARGET])
						if chargeable.size() >= 3:
							for coin in Global.choose_x(chargeable, Global.RNG.randi_range(2, 3)):
								coin.charge()
								coin.play_power_used_effect(Global.patron.power_family)
	
	func can_use(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffLoseLife extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		var charges = payoff_coin.get_active_power_charges()
		var payoff_power_family: PF.PowerFamily = payoff_coin.get_active_power_family()
		
		payoff_coin.FX.flash(Color.RED)
		if Global.is_passive_active(Global.TRIAL_POWER_FAMILY_PAIN): # trial pain - 3x loss from tails penalties
			Global.emit_signal("passive_triggered", Global.TRIAL_POWER_FAMILY_PAIN)
			Global.lives -= charges * 3
		else:
			Global.lives -= charges
		
		# handle special payoff actions
		if payoff_power_family == Global.POWER_FAMILY_LOSE_LIFE_ACHILLES_HEEL:
			game.destroy_coin(payoff_coin)
		elif payoff_power_family == Global.NEMESIS_POWER_FAMILY_SCYLLA_DAMAGE:
			payoff_coin.change_life_penalty_for_round(Global.SCYLLA_INCREASE[payoff_coin.get_denomination()])
		elif payoff_power_family == Global.NEMESIS_POWER_FAMILY_MINOTAUR_SCALING_DAMAGE:
			payoff_coin.change_life_penalty_for_round(charges)
		elif payoff_power_family == Global.MONSTER_POWER_FAMILY_GADFLY_LOSE_LIFE_SCALING:
			payoff_coin.change_life_penalty_for_round(Global.GADFLY_INCREASE[payoff_coin.get_denomination()])
	
	func can_use(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffHalveLife extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		payoff_coin.FX.flash(Color.RED)
		Global.lives -= int(Global.lives /2.0)
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffGainLife extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		payoff_coin.FX.flash(Color.GREEN_YELLOW)
		Global.lives += payoff_coin.get_active_power_charges()
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffGainSouls extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		var payoff_power_family = payoff_coin.get_active_power_family()
		
		var payoff = payoff_coin.get_active_souls_payoff()
		if Global.is_passive_active(Global.TRIAL_POWER_FAMILY_LIMITATION): # limitation trial - payoffs < 10 become 0
			Global.emit_signal("passive_triggered", Global.TRIAL_POWER_FAMILY_LIMITATION)
			payoff = 0 if payoff < 10 else payoff
		if Global.is_passive_active(Global.TRIAL_POWER_FAMILY_GATING): # gating trial - payoffs > 10 become 1
			Global.emit_signal("passive_triggered", Global.TRIAL_POWER_FAMILY_GATING)
			payoff = 1 if payoff > 10 else payoff
		if payoff > 0:
			payoff_coin.FX.flash(Color.AQUA)
			Global.earn_souls(payoff)
			Global.malice += Global.MALICE_INCREASE_ON_HEADS_PAYOFF * Global.current_round_malice_multiplier()
		
		# handle special payoff actions
		# helios - bless coin to the left and move to the left, if possible
		if payoff_power_family == Global.POWER_FAMILY_GAIN_SOULS_HELIOS and left:
			left.bless()
			target_row.swap_positions(payoff_coin, left)
		# icarus - if every coin is heads, destroy
		elif payoff_power_family == Global.POWER_FAMILY_GAIN_SOULS_ICARUS:
			if target_row.get_filtered(CoinRow.FILTER_HEADS).size() == target_row.get_child_count():
				payoff_coin.FX.flash(Color.YELLOW)
				game.destroy_coin(payoff_coin)
		# telemachus - after X tosses, transform
		elif payoff_power_family == Global.POWER_FAMILY_GAIN_SOULS_TELEMACHUS:
			payoff_coin.set_active_face_metadata(Coin.METADATA_TELEMACHUS, payoff_coin.get_active_face_metadata(Coin.METADATA_TELEMACHUS, 0) + 1)
			if payoff_coin.get_active_face_metadata(Coin.METADATA_TELEMACHUS) >= Global.TELEMACHUS_TOSSES_TO_TRANSFORM:
				payoff_coin.init_coin(Global.random_power_coin_family(), Global.Denomination.DRACHMA, payoff_coin.get_current_owner())
				payoff_coin.permanently_consecrate()
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffStokeFlame extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		Global.flame_boost = min(Global.FLAME_BOOST_LIMIT, Global.flame_boost + Global.PROMETHEUS_MULTIPLIER[payoff_coin.get_denomination()])
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffLoseSouls extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		var payoff = payoff_coin.get_active_souls_payoff()
		payoff_coin.FX.flash(Color.DARK_BLUE)
		Global.lose_souls(payoff)
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffGainArrows extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		payoff_coin.FX.flash(Color.GHOST_WHITE)
		Global.arrows = min(Global.arrows + payoff_coin.get_active_power_charges(), Global.ARROWS_LIMIT)
		game._disable_interaction_coins_and_patron() # stupid bad hack to make the arrow not light up
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffDoNothing extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		pass
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffLucky extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		payoff_coin.FX.flash(Color.GHOST_WHITE)
		for target in Global.choose_x(player_row.get_multi_filtered_randomized([CoinRow.FILTER_NOT_LUCKY, CoinRow.FILTER_CAN_TARGET]), payoff_coin.get_active_power_charges()):
			target.make_lucky()
			target.play_power_used_effect(payoff_coin.get_active_power_family())
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffUnlucky extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		for target in Global.choose_x(player_row.get_multi_filtered_randomized([CoinRow.FILTER_NOT_UNLUCKY, CoinRow.FILTER_CAN_TARGET]), payoff_coin.get_active_power_charges()):
			target.make_unlucky()
			target.play_power_used_effect(payoff_coin.get_active_power_family())
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffCurse extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		for target in Global.choose_x(player_row.get_multi_filtered_randomized([CoinRow.FILTER_NOT_CURSED, CoinRow.FILTER_CAN_TARGET]), payoff_coin.get_active_power_charges()):
			target.curse()
			target.play_power_used_effect(payoff_coin.get_active_power_family())
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffBlank extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		for target in Global.choose_x(player_row.get_multi_filtered_randomized([CoinRow.FILTER_NOT_BLANK, CoinRow.FILTER_CAN_TARGET]), payoff_coin.get_active_power_charges()):
			target.blank()
			target.play_power_used_effect(payoff_coin.get_active_power_family())
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffFreezeTails extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		for coin in player_row.get_multi_filtered([CoinRow.FILTER_TAILS, CoinRow.FILTER_CAN_TARGET]):
			if coin.can_target():
				coin.freeze()
				coin.play_power_used_effect(payoff_coin.get_active_power_family())
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffStone extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		for target in Global.choose_x(target_row.get_multi_filtered_randomized([CoinRow.FILTER_NOT_STONE, CoinRow.FILTER_CAN_TARGET]), payoff_coin.get_active_power_charges()):
			target.stone()
			target.play_power_used_effect(payoff_coin.get_active_power_family())
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffIgnite extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		for target in Global.choose_x(player_row.get_multi_filtered_randomized([CoinRow.FILTER_NOT_STONE, CoinRow.FILTER_CAN_TARGET]), payoff_coin.get_active_power_charges()):
			target.ignite()
			target.play_power_used_effect(payoff_coin.get_active_power_family())
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffIgniteSelf extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		payoff_coin.ignite() #ignite itself
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffDowngradeMostValuable extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		for i in range(0, payoff_coin.get_active_power_charges()):
			var highest = player_row.get_highest_valued_that_can_be_targetted()
			highest.shuffle()
			# don't downgrade if it's the last coin
			if highest[0].get_denomination() != Global.Denomination.OBOL or player_row.get_child_count() != 1:
				highest[0].play_power_used_effect(payoff_coin.get_active_power_family())
				game.downgrade_coin(highest[0])
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffSpawnStrong extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		game.spawn_enemy(Global.get_standard_monster(), Global.ECHIDNA_SPAWN_DENOM[payoff_coin.get_denomination()], 0)
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffSpawnFleeting extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		for i in range(0, payoff_coin.get_active_power_charges()):
			var enemy = game.spawn_enemy(Global.get_standard_monster(), Global.Denomination.OBOL, 0)
			if enemy != null: #may have not had space to spawn the monster, if so, returned null
				enemy.make_fleeting()
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffUpgradeMonsters extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		for enemy in enemy_row.get_children():
			if enemy.get_coin_family() in [Global.ECHIDNA_FAMILY, Global.TYPHON_FAMILY]:
				continue
			if enemy.can_upgrade():
				enemy.upgrade()
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffBlessMonsters extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		for enemy in enemy_row.get_children():
			enemy.bless()
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffPermanentlyIgniteMonster extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		for target in Global.choose_x(enemy_row.get_multi_filtered_erandomized([CoinRow.FILTER_NOT_IGNITED, CoinRow.FILTER_CAN_TARGET]), payoff_coin.get_active_power_charges()):
			target.permanently_ignite()
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffAmplifyIgnite extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		Global.ignite_damage += payoff_coin.get_active_power_charges()
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffIncreaseAllPenalty extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		for coin in player_row.get_children() + enemy_row.get_children():
			if coin.can_change_life_penalty():
				coin.change_life_penalty_for_round(Global.KERES_INCREASE[payoff_coin.get_denomination()])
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffDesecrate extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		for target in Global.choose_x(player_row.get_multi_filtered_randomized([CoinRow.FILTER_NOT_DESECRATED, CoinRow.FILTER_CAN_TARGET]), payoff_coin.get_active_power_charges()):
			target.desecrate()
			target.play_power_used_effect(payoff_coin.get_active_power_family())
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffShuffle extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		player_row.shuffle()
		payoff_coin.clear_round_life_penalty()
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffBlankLeftHalf extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		var left_to_right = player_row.get_leftmost_to_rightmost()
		var n_affected = floor(player_row.get_child_count() / 2.0)
		for i in n_affected:
			left_to_right[i].blank()
			left_to_right[i].play_power_used_effect(payoff_coin.get_active_power_family())
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffBlankRightHalf extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		var right_to_left = player_row.get_rightmost_to_leftmost()
		var n_affected = floor(player_row.get_child_count() / 2.0)
		for i in n_affected:
			right_to_left[i].blank()
			right_to_left[i].play_power_used_effect(payoff_coin.get_active_power_family())
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffCurseUnluckyScaling extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		for i in payoff_coin.get_active_power_charges():
			if Global.RNG.randi_range(0, 1) == 0:
				var target = Global.choose_one(player_row.get_multi_filtered_randomized([CoinRow.FILTER_NOT_UNLUCKY, CoinRow.FILTER_CAN_TARGET]))
				target.make_unlucky()
				target.play_power_used_effect(payoff_coin.get_active_power_family())
			else:
				var target = Global.choose_one(player_row.get_multi_filtered_randomized([CoinRow.FILTER_NOT_CURSED, CoinRow.FILTER_CAN_TARGET]))
				target.curse()
				target.play_power_used_effect(payoff_coin.get_active_power_family())
		# double the charges
		payoff_coin.change_charge_modifier_for_round(payoff_coin.get_active_power_charges())
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffAWayOut extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		payoff_coin.FX.flash(Color.WHITE)
		game.destroy_coin(payoff_coin)
		payoff_coin.play_power_used_effect(payoff_coin.get_active_power_family())
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffUnluckySelf extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		payoff_coin.make_unlucky()
		payoff_coin.play_power_used_effect(payoff_coin.get_active_power_family())
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffFreezeSelf extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		payoff_coin.freeze()
		payoff_coin.play_power_used_effect(payoff_coin.get_active_power_family())
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffBurySelfLabyrinth extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		payoff_coin.bury(1)
		payoff_coin.play_power_used_effect(payoff_coin.get_active_power_family())
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffTrojanHorse extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		var index = payoff_coin.get_index()
		game.destroy_coin(payoff_coin)
		for i in payoff_coin.get_active_power_charges():
			var coin = game.spawn_enemy(Global.get_standard_monster_excluding([Global.MONSTER_TROJAN_HORSE_FAMILY]), payoff_coin.get_denomination(), index)
			if coin: # may return null if didn't spawn
				coin.play_power_used_effect(payoff_coin.get_active_power_family())
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffAllMonsterUnlucky extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		for mon in enemy_row.get_children():
			mon.make_unlucky()
			mon.play_power_used_effect(payoff_coin.get_active_power_family())
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffFreeze extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		for target in Global.choose_x(player_row.get_multi_filtered_randomized([CoinRow.FILTER_NOT_FROZEN, CoinRow.FILTER_CAN_TARGET]), payoff_coin.get_active_power_charges()):
			target.freeze()
			target.play_power_used_effect(payoff_coin.get_active_power_family())
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffBless extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		payoff_coin.FX.flash(Color.GHOST_WHITE)
		for target in Global.choose_x(player_row.get_multi_filtered_randomized([CoinRow.FILTER_NOT_BLESSED, CoinRow.FILTER_CAN_TARGET]), payoff_coin.get_active_power_charges()):
			target.bless()
			target.play_power_used_effect(payoff_coin.get_active_power_family())
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffGainThornsGadfly extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		var thorns_denom = Global.GADFLY_THORNS_DENOM[payoff_coin.get_denomination()]
		if player_row.get_child_count() != Global.COIN_LIMIT:
			var coin = game.make_and_gain_coin(Global.THORNS_FAMILY, thorns_denom, game.CHARON_NEW_COIN_POSITION)
			coin.play_power_used_effect(payoff_coin.get_active_power_family())
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffGainThornsSphinx extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		var thorns_denom = Global.SPHINX_THORNS_DENOM[payoff_coin.get_denomination()]
		if player_row.get_child_count() != Global.COIN_LIMIT:
			var coin = game.make_and_gain_coin(Global.THORNS_FAMILY, thorns_denom, game.CHARON_NEW_COIN_POSITION)
			coin.play_power_used_effect(payoff_coin.get_active_power_family())
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffBuryLamia extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		var target = Global.choose_one(player_row.get_multi_filtered_randomized([CoinRow.FILTER_NOT_BURIED, CoinRow.FILTER_CAN_TARGET]))
		if target:
			target.bury(Global.LAMIA_BURY[payoff_coin.get_denomination()])
			target.play_power_used_effect(payoff_coin.get_active_power_family())
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffBuryOread extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		var target = Global.choose_one(player_row.get_multi_filtered_randomized([CoinRow.FILTER_NOT_BURIED, CoinRow.FILTER_CAN_TARGET]))
		if target:
			target.bury(Global.OREAD_BURY[payoff_coin.get_denomination()])
			target.play_power_used_effect(payoff_coin.get_active_power_family())
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffBuryCyclops extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		var target = Global.choose_one(player_row.get_multi_filtered_randomized([CoinRow.FILTER_NOT_BURIED, CoinRow.FILTER_CAN_TARGET]))
		if target:
			target.bury(Global.CYCLOPS_BURY[payoff_coin.get_denomination()])
			target.play_power_used_effect(payoff_coin.get_active_power_family())
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffBurySelfBoar extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		payoff_coin.FX.flash(Color.SADDLE_BROWN)
		payoff_coin.turn()
		payoff_coin.bury(Global.BOAR_BURY[payoff_coin.get_denomination()])
		payoff_coin.play_power_used_effect(payoff_coin.get_active_power_family())
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffTransform extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		var target = Global.choose_one(player_row.get_filtered_randomized(CoinRow.FILTER_CAN_TARGET))
		if target:
			target.init_coin(Global.random_coin_family_excluding([target.get_coin_family()]), target.get_denomination(), target.get_current_owner())
			target.play_power_used_effect(payoff_coin.get_active_power_family())
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffGainObol extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		payoff_coin.FX.flash(Color.WHITE)
		if player_row.get_child_count() != Global.COIN_LIMIT:
			var new_coin = game.make_and_gain_coin(Global.random_coin_family(), Global.Denomination.OBOL, payoff_coin.global_position, true)
			new_coin.play_power_used_effect(payoff_coin.get_active_power_family())
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffDecreaseCost extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		payoff_coin.FX.flash(Color.WHITE)
		payoff_coin.change_monster_appease_price(-payoff_coin.get_active_power_charges())
		payoff_coin.play_power_used_effect(payoff_coin.get_active_power_family())
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffIncreaseCost extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		payoff_coin.change_monster_appease_price(payoff_coin.get_active_power_charges())
		payoff_coin.play_power_used_effect(payoff_coin.get_active_power_family())
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffDestroySelf extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		game.destroy_coin(payoff_coin)
		payoff_coin.play_power_used_effect(payoff_coin.get_active_power_family())
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffCurseUnluckySelf extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		payoff_coin.curse()
		payoff_coin.make_unlucky()
		payoff_coin.play_power_used_effect(payoff_coin.get_active_power_family())
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffDowngrade extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		for target in Global.choose_x(player_row.get_filtered_randomized(CoinRow.FILTER_CAN_TARGET), payoff_coin.get_active_power_charges()):
			game.downgrade_coin(target)
			target.play_power_used_effect(payoff_coin.get_active_power_family())
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffDoomRightmost extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		var leftmost = player_row.get_leftmost_to_rightmost()[0]
		var right_to_left = player_row.get_rightmost_to_leftmost()
		for coin in right_to_left:
			if coin == leftmost:
				break
			if not coin.is_doomed():
				coin.doom()
				coin.play_power_used_effect(payoff_coin.get_active_power_family())
				break # just find and do one
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffDowngradeAndPrime extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		for target in Global.choose_x(player_row.get_filtered_randomized(CoinRow.FILTER_CAN_TARGET), payoff_coin.get_active_power_charges()):
			target.prime()
			game.downgrade_coin(target)
			target.play_power_used_effect(payoff_coin.get_active_power_family())
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)
		
class PayoffUpgradeSelf extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		if payoff_coin.can_upgrade():
			payoff_coin.upgrade()
			payoff_coin.play_power_used_effect(payoff_coin.get_active_power_family())
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffIncreasePenalty extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		var target = Global.choose_one(player_row.get_multi_filtered_randomized([CoinRow.FILTER_CAN_TARGET, CoinRow.FILTER_CAN_INCREASE_PENALTY]))
		if target:
			if target.can_change_life_penalty():
				target.change_life_penalty_for_round(Global.STRIX_INCREASE[payoff_coin.get_denomination()])
				target.play_power_used_effect(payoff_coin.get_active_power_family())
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)
















class TEMPLATE extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> void:
		pass
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)
#  payoff_coin.get_active_power_charges()
#  payoff_coin.get_denomination()
