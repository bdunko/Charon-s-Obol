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
	
	var description: String
	var _uses_for_denom: Array[int]
	var power_type: PowerType
	var icon_path: String
	var prefer_icon_only: bool
	var tags: Array
	
	func _init(desc: String, uses_per_denom: Array[int], pwrType: PowerType, icon: String, pref_icn_only: bool, tgs: Array = []) -> void:
		self.description = desc
		self.power_type = pwrType
		self._uses_for_denom = uses_per_denom
		self.icon_path = icon
		self.prefer_icon_only = pref_icn_only
		assert(FileAccess.file_exists(self.icon_path))
		self.tags = tgs
	
	func get_uses_for_denom(denom: Global.Denomination) -> int:
		# singularity trial - max charges = 1
		if Global.is_passive_active(Global.TRIAL_POWER_FAMILY_SINGULARITY) and is_power(): 
			return min(1, _uses_for_denom[denom])
		
		return _uses_for_denom[denom]
	
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
	
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
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
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		game.safe_flip(target, false)
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if not target.can_flip():
			return CanUseResult.new(false, "Can't flip that coin...")
		return CanUseResult.new(true)

class Freeze extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		target.freeze()
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if target.is_frozen():
			return CanUseResult.new(false, "It's already (FROZEN)...")
		return CanUseResult.new(true)

class ReflipAndNeighbors extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		game.safe_flip(target, false)
		if left:
			left.play_power_used_effect(Global.active_coin_power_family)
			left.safe_flip(left, false)
		if right:
			right.play_power_used_effect(Global.active_coin_power_family)
			right.safe_flip(left, false)
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if (not target.can_flip()) and (not left or (left and not left.can_flip())) and (not right or (right and not right.can_flip())):
			return CanUseResult.new(false, "Can't flip that coin...")
		return CanUseResult.new(true)

class TurnAndBlurse extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		target.turn()
		target.curse() if target.is_heads() else target.bless()
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class ReducePenalty extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		target.change_life_penalty_for_round(-2)
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if not target.can_reduce_life_penalty():
			return CanUseResult.new(false, "No need...")
		return CanUseResult.new(true)

class PrimeAndIgnite extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		target.prime()
		target.ignite()
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if target.is_primed() and target.is_ignited():
			return CanUseResult.new(false, "No need...")
		return CanUseResult.new(true)

class CopyPowerForToss extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		Global.active_coin_power_coin.overwrite_active_face_power_for_toss(target.get_copied_power_family())
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if not target.can_copy_power() or target.get_copied_power_family() == Global.active_coin_power_family:
			return CanUseResult.new(false, "Can't copy that...")
		return CanUseResult.new(true)

class ClonePermanently extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		Global.active_coin_power_coin.init_coin(target.get_coin_family(), target.get_denomination(), Coin.Owner.PLAYER)
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if target.get_copied_power_family() == Global.active_coin_power_family:
			return CanUseResult.new(false, "Can't copy that...")
		if Global.active_coin_power_coin.get_denomination() != target.get_denomination():
			return CanUseResult.new(false, "Can't copy a different denomination...")
		return CanUseResult.new(true)

class CopyPowerPermanentlyAndDestroy extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		Global.active_coin_power_coin.overwrite_active_face_power(target.get_copied_power_family())
		game.destroy_coin(target)
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if not target.can_copy_power() or target.get_copied_power_family() == Global.active_coin_power_family:
			return CanUseResult.new(false, "Can't copy that...")
		return CanUseResult.new(true)

class Exchange extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		var new_coin = game._make_and_gain_coin(Global.random_coin_family_excluding([target.get_coin_family()]), target.get_denomination(), game.CHARON_NEW_COIN_POSITION, true)
		new_coin.get_parent().move_child(new_coin, target.get_index())
		new_coin.play_power_used_effect(Global.active_coin_power_family)
		game.remove_coin_from_row_move_then_destroy(target, game.CHARON_NEW_COIN_POSITION)
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class MakeLucky extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		target.make_lucky()
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if not target.can_make_lucky():
			return CanUseResult.new(false, "No need...")
		return CanUseResult.new(true)

class DowngradeForLife extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		game.downgrade_coin(target)
		if target.is_monster_coin():
			var cost = Global.HADES_MONSTER_COST[Global.active_coin_power_coin.get_value() - 1]
			Global.lives -= cost
			LabelSpawner.spawn_label(Global.LIFE_DOWN_PAYOFF_FORMAT % cost, target.get_label_origin(), game)
		elif target.is_owned_by_player():
			var heal = Global.HADES_SELF_GAIN[Global.active_coin_power_coin.get_value() - 1]
			Global.heal_life(heal)
			LabelSpawner.spawn_label(Global.LIFE_UP_PAYOFF_FORMAT % heal, target.get_label_origin(), game)
		else:
			assert(false, "Hades shouldn't get here...")
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if target.is_owned_by_player() and player_row.get_child_count() == 1 and target.get_denomination() == Global.Denomination.OBOL:
			return CanUseResult.new(false, "Can't destroy last coin...")
		return CanUseResult.new(true)

class Stone extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		if target.is_stone():
			target.clear_material()
		else:
			target.stone()
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if not target.is_stone() and not target.can_stone():
			return CanUseResult.new(false, "Can't (STONE) that...")
		return CanUseResult.new(true)

class BlankTails extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
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
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
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
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		target.ignite()
		target.charge()
		target.make_lucky()
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if not target.can_ignite() and not target.can_charge() and not target.can_make_lucky():
			return CanUseResult.new(false, "No need...")
		return CanUseResult.new(true)

class ConsecrateDoom extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		target.consecrate()
		target.doom()
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if target.is_doomed() and target.is_consecrated():
			return CanUseResult.new(false, "No need...")
		return CanUseResult.new(true)

class BuryHarvest extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		target.bury(3)
		target.set_coin_metadata(Coin.METADATA_TRIPTOLEMUS, Global.TRIPTOLEMUS_HARVEST[Global.active_coin_power_coin.get_denomination()])
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class BuryTurnOtherTails extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		target.bury(1)
		for c in Global.choose_one(target_row.get_multi_filtered_randomized([CoinRow.FILTER_CAN_TARGET, CoinRow.FILTER_TAILS])):
			c.turn()
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class InfiniteTurnHunger extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		var current_cost = Global.active_coin_power_coin.get_active_face_metadata(Coin.METADATA_ERYSICHTHON, 0)
		Global.lives -= current_cost
		LabelSpawner.spawn_label(Global.LIFE_DOWN_PAYOFF_FORMAT % current_cost, target.get_label_origin(), game)
		
		Global.active_coin_power_coin.set_active_face_metadata(Coin.METADATA_ERYSICHTHON, current_cost + 1)
		target.turn()
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if not target.can_turn():
			return CanUseResult.new(false, "Can't turn that...")
		return CanUseResult.new(true)

class FlipAndTag extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		target.set_coin_metadata(Coin.METADATA_ERIS, true)
		for c in player_row.get_children() + enemy_row.get_children():
			if c.get_coin_metadata(Coin.METADATA_ERIS, false):
				if c.can_flip():
					c.play_power_used_effect(Global.active_coin_power_family)
					game.safe_flip(c, false)
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if not target.can_flip():
			return CanUseResult.new(false, "Can't flip that coin...")
		return CanUseResult.new(true)

class SwapReflipNeighbors extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		pass
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if not target.can_flip():
			return CanUseResult.new(false, "Can't flip that coin...")
		return CanUseResult.new(true)

class IgniteThenBlessThenSacrifice extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
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
	func use_power(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		var heal = Global.DEMETER_GAIN[activated.get_denomination()]
		Global.heal_life(heal)
		if heal != 0:
			LabelSpawner.spawn_label(Global.LIFE_UP_PAYOFF_FORMAT % heal, activated.get_label_origin(), game)
	
	func can_use(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class GainArrow extends PowerFamily:
	func use_power(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		var arrows_before = Global.arrows
		Global.arrows = min(Global.arrows + (activated.get_denomination()+1), Global.ARROWS_LIMIT)
		var arrows_gained = Global.arrows - arrows_before
		if arrows_gained != 0:
			LabelSpawner.spawn_label(Global.ARROW_UP_PAYOFF_FORMAT % arrows_gained, activated.get_label_origin(), game)
	
	func can_use(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if Global.arrows == Global.ARROWS_LIMIT:
			return CanUseResult.new(false, "Too many arrows...")
		return CanUseResult.new(true)

class ReflipAll extends PowerFamily:
	func use_power(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
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
	func use_power(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		var new_coin = game.make_and_gain_coin(Global.random_coin_family(), Global.Denomination.OBOL, activated.global_position, true)
		new_coin.play_power_used_effect(activated.get_active_power_family())
	
	func can_use(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if player_row.get_child_count() == Global.COIN_LIMIT:
			return CanUseResult.new(false, "Too many coins...")
		return CanUseResult.new(true)

class DestroySelfForReward extends PowerFamily:
	func use_power(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		var souls_earned = Global.PHAETHON_REWARD_SOULS[activated.get_denomination()]
		var life_healed = Global.PHAETHON_REWARD_LIFE[activated.get_denomination()]
		var arrows_before = Global.arrows
		Global.earn_souls(souls_earned)
		Global.heal_life(life_healed)
		Global.arrows = min(Global.arrows + Global.PHAETHON_REWARD_ARROWS[activated.get_denomination()], Global.ARROWS_LIMIT)
		var arrows_gained = Global.arrows - arrows_before
		var txt = ("%s\n%s\n%s" % [Global.SOUL_UP_PAYOFF_FORMAT, Global.LIFE_UP_PAYOFF_FORMAT, Global.ARROW_UP_PAYOFF_FORMAT]) % [souls_earned, life_healed, arrows_gained]
		LabelSpawner.spawn_label(txt, activated.get_label_origin() - Vector2(0, 10), game)
		Global.patron_uses = Global.patron.get_uses_per_round()
		game.destroy_coin(activated)
	
	func can_use(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class TurnSelf extends PowerFamily:
	func use_power(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		activated.turn()
	
	func can_use(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class ReflipLeftAlternating extends PowerFamily:
	func use_power(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
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
	func use_power(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
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
	func use_power(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
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
	func use_power(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		var new_coin = game.make_and_gain_coin(Global.GENERATED_GOLDEN_FAMILY, activated.get_denomination(), activated.global_position, true)
		new_coin.play_power_used_effect(activated.get_active_power_family())
	
	func can_use(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		if player_row.get_child_count() == Global.COIN_LIMIT:
			return CanUseResult.new(false, "Too many coins...")
		return CanUseResult.new(true)

class TurnAll extends PowerFamily:
	func use_power(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		for c in player_row.get_children() + enemy_row.get_children():
			c.turn()
			c.play_power_used_effect(Global.POWER_FAMILY_TURN_ALL) # pass in power family direclty here since it might turn itself
	
	func can_use(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)





# PATRON POWERS
class PatronCharon extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		target.turn()
		target.make_lucky()
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		assert(target != null)
		return CanUseResult.new(true)

class PatronAthena extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		target.change_life_penalty_permanently(-2)
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		assert(target != null)
		if not target.can_reduce_life_penalty():
			return CanUseResult.new(false, "No need...")
		return CanUseResult.new(true)

class PatronApollo extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		target.clear_statuses()
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		assert(target != null)
		if not target.has_status():
			return CanUseResult.new(false, "No need...")
		return CanUseResult.new(true)

class PatronHephaestus extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		target.upgrade()
		target.reset_power_uses(true)
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		assert(target != null)
		if not target.can_upgrade():
			return CanUseResult.new(false, "Can't upgrade further...")
		return CanUseResult.new(true)

class PatronHades extends PowerFamily:
	func use_power(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		var life_healed = Global.HADES_PATRON_MULTIPLIER * target.get_value()
		var souls_earned = Global.HADES_PATRON_MULTIPLIER * target.get_value()
		Global.heal_life(life_healed)
		Global.earn_souls(souls_earned)
		game.destroy_coin(target)
		var txt = ("%s\n%s" % [Global.SOUL_UP_PAYOFF_FORMAT, Global.LIFE_UP_PAYOFF_FORMAT]) % [souls_earned, life_healed]
		LabelSpawner.spawn_label(txt, patron_token.get_label_origin() - Vector2(0, 5), game)
	
	func can_use(game: Game, target: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		assert(target != null)
		if player_row.get_child_count() == 1:
			return CanUseResult.new(false, "Can't destroy last coin...")
		return CanUseResult.new(true)

class PatronDemeter extends PowerFamily:
	func use_power(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		for coin in player_row.get_children():
			var as_coin: Coin = coin
			if as_coin.is_tails() and as_coin.get_active_power_family().power_type == PF.PowerType.PAYOFF_LOSE_LIFE:
				Global.heal_life(as_coin.get_active_power_charges())
				as_coin.play_power_used_effect(Global.patron.power_family)
				LabelSpawner.spawn_label(Global.LIFE_UP_PAYOFF_FORMAT % as_coin.get_active_power_charges(), as_coin.get_label_origin(), game)
	
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
	func use_power(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		for coin in player_row.get_children() + enemy_row.get_children():
			coin.turn()
			coin.play_power_used_effect(Global.patron.power_family)
	
	func can_use(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PatronAphrodite extends PowerFamily:
	func use_power(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
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
	func use_power(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
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
			var souls_earned = 0
			var life_healed = 0
			var arrows_gained = 0
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
							var arrows_before = Global.arrows
							Global.arrows = min(Global.ARROWS_LIMIT, Global.arrows + bonus_arrows)
							arrows_gained += (Global.arrows - arrows_before)
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
								var soul_amt = max(4, Global.RNG.randi_range(Global.round_count, 2 * Global.round_count))
								Global.earn_souls(soul_amt)
								souls_earned += soul_amt
							2:
								var life_amt = max(6, Global.RNG.randi_range(Global.round_count * 2, 3 * Global.round_count))
								Global.heal_life(life_amt)
								life_healed += life_amt
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
			# end while
			var txt = ""
			var added_height = 0
			if souls_earned != 0:
				txt = txt + Global.SOUL_UP_PAYOFF_FORMAT % souls_earned
			if life_healed != 0:
				if txt != "":
					txt = txt + "\n"
					added_height += 5
				txt = txt + Global.LIFE_UP_PAYOFF_FORMAT % life_healed
			if arrows_gained != 0:
				if txt != "":
					txt = txt + "\n"
					added_height += 5
				txt = txt + Global.ARROW_UP_PAYOFF_FORMAT % arrows_gained
			
			if txt != "":
				LabelSpawner.spawn_label(txt, patron_token.get_label_origin() - Vector2(0, added_height), game)
	
	func can_use(game: Game, activated: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

# PAYOFF POWERS
class PayoffLoseLife extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		var charges = payoff_coin.get_active_power_charges()
		var payoff_power_family: PF.PowerFamily = payoff_coin.get_active_power_family()
		
		payoff_coin.FX.flash(Color.RED)
		if Global.is_passive_active(Global.TRIAL_POWER_FAMILY_PAIN): # trial pain - 3x loss from tails penalties
			Global.emit_signal("passive_triggered", Global.TRIAL_POWER_FAMILY_PAIN)
			Global.lives -= charges * 3
			if charges * 3 != 0:
				LabelSpawner.spawn_label(Global.LIFE_DOWN_PAYOFF_FORMAT % charges, payoff_coin.get_label_origin(), game)
		else:
			Global.lives -= charges
			if charges != 0:
				LabelSpawner.spawn_label(Global.LIFE_DOWN_PAYOFF_FORMAT % charges, payoff_coin.get_label_origin(), game)
		
		# handle special payoff actions
		if payoff_power_family == Global.POWER_FAMILY_LOSE_LIFE_ACHILLES_HEEL:
			game.destroy_coin(payoff_coin)
		elif payoff_power_family == Global.NEMESIS_POWER_FAMILY_SCYLLA_DAMAGE:
			payoff_coin.change_life_penalty_for_round(Global.SCYLLA_INCREASE[payoff_coin.get_denomination()])
		elif payoff_power_family == Global.NEMESIS_POWER_FAMILY_MINOTAUR_SCALING_DAMAGE:
			payoff_coin.change_life_penalty_for_round(charges)
		elif payoff_power_family == Global.MONSTER_POWER_FAMILY_GADFLY_LOSE_LIFE_SCALING:
			payoff_coin.change_life_penalty_for_round(Global.GADFLY_INCREASE[payoff_coin.get_denomination()])
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(payoff_coin.get_active_power_charges() != 0)

class PayoffHalveLife extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		payoff_coin.FX.flash(Color.RED)
		var life_lost = int(Global.lives / 2.0)
		Global.lives -= life_lost
		if life_lost != 0:
			LabelSpawner.spawn_label(Global.LIFE_DOWN_PAYOFF_FORMAT % life_lost, payoff_coin.get_label_origin(), game)
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffGainLife extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		payoff_coin.FX.flash(Color.GREEN_YELLOW)
		Global.heal_life(payoff_coin.get_active_power_charges())
		LabelSpawner.spawn_label(Global.LIFE_UP_PAYOFF_FORMAT % payoff_coin.get_active_power_charges(), payoff_coin.get_label_origin(), game)
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(payoff_coin.get_active_power_charges() != 0)

class PayoffGainSouls extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
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
			LabelSpawner.spawn_label(Global.SOUL_UP_PAYOFF_FORMAT % payoff, payoff_coin.get_label_origin(), game)
		
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
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		Global.flame_boost = min(Global.FLAME_BOOST_LIMIT, Global.flame_boost + Global.PROMETHEUS_MULTIPLIER[payoff_coin.get_denomination()])
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffLoseSouls extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		var payoff = payoff_coin.get_active_souls_payoff()
		payoff_coin.FX.flash(Color.DARK_BLUE)
		Global.lose_souls(payoff)
		if payoff != 0:
			LabelSpawner.spawn_label(Global.SOUL_DOWN_PAYOFF_FORMAT % payoff, payoff_coin.get_label_origin(), game)
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(payoff_coin.get_active_souls_payoff() != 0)

class PayoffGainArrows extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		payoff_coin.FX.flash(Color.GHOST_WHITE)
		var arrows_before = Global.arrows
		Global.arrows = min(Global.arrows + payoff_coin.get_active_power_charges(), Global.ARROWS_LIMIT)
		var arrows_gained = Global.arrows - arrows_before
		game._disable_interaction_coins_and_patron() # stupid bad hack to make the arrow not light up
		if arrows_gained != 0:
			LabelSpawner.spawn_label(Global.ARROW_UP_PAYOFF_FORMAT % arrows_gained, payoff_coin.get_label_origin(), game)
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffDoNothing extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		pass
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffLucky extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		Audio.play_sfx(SFX.PayoffMonster)
		payoff_coin.FX.flash(Color.GHOST_WHITE)
		
		var targets = Global.choose_x(player_row.get_multi_filtered_randomized([CoinRow.FILTER_NOT_LUCKY, CoinRow.FILTER_CAN_TARGET]), payoff_coin.get_active_power_charges())
		
		var callback = func(target):
			target.make_lucky()
			target.play_power_used_effect(payoff_coin.get_active_power_family())
		
		await ProjectileManager.fire_projectiles(payoff_coin, targets, callback, Projectile.PARAMS_GREEN)
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		var targets = Global.choose_x(player_row.get_multi_filtered_randomized([CoinRow.FILTER_NOT_LUCKY, CoinRow.FILTER_CAN_TARGET]), payoff_coin.get_active_power_charges())
		return CanUseResult.new(targets.size() != 0)

class PayoffUnlucky extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		Audio.play_sfx(SFX.PayoffMonster)
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		
		var targets = Global.choose_x(player_row.get_multi_filtered_randomized([CoinRow.FILTER_NOT_UNLUCKY, CoinRow.FILTER_CAN_TARGET]), payoff_coin.get_active_power_charges())
		
		var callback = func(target):
			target.make_unlucky()
			target.play_power_used_effect(payoff_coin.get_active_power_family())
		
		await ProjectileManager.fire_projectiles(payoff_coin, targets, callback, Projectile.PARAMS_RED)
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		var targets = Global.choose_x(player_row.get_multi_filtered_randomized([CoinRow.FILTER_NOT_UNLUCKY, CoinRow.FILTER_CAN_TARGET]), payoff_coin.get_active_power_charges())
		return CanUseResult.new(targets.size() != 0)

class PayoffCurse extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		Audio.play_sfx(SFX.PayoffMonster)
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		
		var targets = Global.choose_x(player_row.get_multi_filtered_randomized([CoinRow.FILTER_NOT_CURSED, CoinRow.FILTER_CAN_TARGET]), payoff_coin.get_active_power_charges())
		
		var callback = func(target):
			target.curse()
			target.play_power_used_effect(payoff_coin.get_active_power_family())
		
		await ProjectileManager.fire_projectiles(payoff_coin, targets, callback)
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		var targets = Global.choose_x(player_row.get_multi_filtered_randomized([CoinRow.FILTER_NOT_CURSED, CoinRow.FILTER_CAN_TARGET]), payoff_coin.get_active_power_charges())
		return CanUseResult.new(targets.size() != 0)

class PayoffBlank extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		Audio.play_sfx(SFX.PayoffMonster)
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		
		var targets = Global.choose_x(player_row.get_multi_filtered_randomized([CoinRow.FILTER_NOT_BLANK, CoinRow.FILTER_CAN_TARGET]), payoff_coin.get_active_power_charges())
		
		var callback = func(target):
			target.blank()
			target.play_power_used_effect(payoff_coin.get_active_power_family())
		
		await ProjectileManager.fire_projectiles(payoff_coin, targets, callback, Projectile.PARAMS_WHITE)
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		var targets = Global.choose_x(player_row.get_multi_filtered_randomized([CoinRow.FILTER_NOT_BLANK, CoinRow.FILTER_CAN_TARGET]), payoff_coin.get_active_power_charges())
		return CanUseResult.new(targets.size() != 0)

class PayoffFreezeTails extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		Audio.play_sfx(SFX.PayoffMonster)
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		
		var targets = player_row.get_multi_filtered([CoinRow.FILTER_TAILS, CoinRow.FILTER_CAN_TARGET])
		
		var callback = func(target):
			target.freeze()
			target.play_power_used_effect(payoff_coin.get_active_power_family())
		
		await ProjectileManager.fire_projectiles(payoff_coin, targets, callback, Projectile.PARAMS_BLUE)
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		var targets = player_row.get_multi_filtered([CoinRow.FILTER_TAILS, CoinRow.FILTER_CAN_TARGET])
		return CanUseResult.new(targets.size() != 0)

class PayoffStone extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		Audio.play_sfx(SFX.PayoffMonster)
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		
		var targets = Global.choose_x(player_row.get_multi_filtered_randomized([CoinRow.FILTER_NOT_STONE, CoinRow.FILTER_CAN_TARGET]), payoff_coin.get_active_power_charges())
		
		var callback = func(target):
			target.stone()
			target.play_power_used_effect(payoff_coin.get_active_power_family())
		
		await ProjectileManager.fire_projectiles(payoff_coin, targets, callback, Projectile.PARAMS_GRAY)
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		var targets = Global.choose_x(player_row.get_multi_filtered_randomized([CoinRow.FILTER_NOT_STONE, CoinRow.FILTER_CAN_TARGET]), payoff_coin.get_active_power_charges())
		return CanUseResult.new(targets.size() != 0)

class PayoffIgnite extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		Audio.play_sfx(SFX.PayoffMonster)
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		
		var targets = Global.choose_x(player_row.get_multi_filtered_randomized([CoinRow.FILTER_NOT_STONE, CoinRow.FILTER_NOT_IGNITED, CoinRow.FILTER_CAN_TARGET]), payoff_coin.get_active_power_charges())
		
		var callback = func(target):
			target.ignite()
			target.play_power_used_effect(payoff_coin.get_active_power_family())
		
		await ProjectileManager.fire_projectiles(payoff_coin, targets, callback, Projectile.PARAMS_RED)

	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		var targets = Global.choose_x(player_row.get_multi_filtered_randomized([CoinRow.FILTER_NOT_STONE, CoinRow.FILTER_NOT_IGNITED, CoinRow.FILTER_CAN_TARGET]), payoff_coin.get_active_power_charges())
		return CanUseResult.new(targets.size() != 0)

class PayoffIgniteSelf extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		Audio.play_sfx(SFX.PayoffMonster)
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		payoff_coin.ignite() #ignite itself
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffDowngradeMostValuable extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		Audio.play_sfx(SFX.PayoffMonster)
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		
		var targets = _get_targets(payoff_coin, player_row)
			
		var callback = func(target):
			target.play_power_used_effect(payoff_coin.get_active_power_family())
			game.downgrade_coin(target)
		
		await ProjectileManager.fire_projectiles(payoff_coin, targets, callback)
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(_get_targets(payoff_coin, player_row).size() != 0)
	
	func _get_targets(payoff_coin, player_row) -> Array:
		var targets = []
		var all_previous_were_obols = true
		var high_to_low = player_row.get_highest_to_lowest_value_that_can_be_targetted()
		for i in range(0, payoff_coin.get_active_power_charges()):
			if high_to_low.size() <= i:
				break # no more to take
			
			var candidate_coin  = high_to_low[i]
			
			# extreme edge case... 
			# if we are trying to take a coin, and it is the last coin in high to low
			# and all previous coins were obols, and this coin is also an obol
			# we don't want to do it, since it would destroy the last coin (leaves player with no coins)
			# in this case, skip.
			if high_to_low.size() - 1 == i and all_previous_were_obols and candidate_coin .get_denomination() == Global.Denomination.OBOL:
				break
			
			# otherwise, add to targets
			if all_previous_were_obols and candidate_coin .get_denomination() != Global.Denomination.OBOL:
				all_previous_were_obols = false
				
			targets.append(candidate_coin )
		return targets

class PayoffSpawnStrong extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		Audio.play_sfx(SFX.PayoffMonster)
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		game.spawn_enemy(Global.get_standard_monster(), Global.ECHIDNA_SPAWN_DENOM[payoff_coin.get_denomination()], 0)
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(game.can_spawn_enemy())

class PayoffSpawnFleeting extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		Audio.play_sfx(SFX.PayoffMonster)
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		for i in range(0, payoff_coin.get_active_power_charges()):
			var enemy = game.spawn_enemy(Global.get_standard_monster(), Global.Denomination.OBOL, 0)
			if enemy != null: #may have not had space to spawn the monster, if so, returned null
				enemy.make_fleeting()
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(game.can_spawn_enemy())

class PayoffUpgradeMonsters extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		Audio.play_sfx(SFX.PayoffMonster)
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		
		var targets = _get_targets(enemy_row)
		
		var callback = func(target):
			target.play_power_used_effect(payoff_coin.get_active_power_family())
			target.upgrade()
		
		await ProjectileManager.fire_projectiles(payoff_coin, targets, callback)

	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(_get_targets(enemy_row).size() != 0)
	
	func _get_targets(enemy_row) -> Array:
		var targets = []
		for enemy in enemy_row.get_children():
			if enemy.get_coin_family() in [Global.ECHIDNA_FAMILY, Global.TYPHON_FAMILY]:
				continue
			if enemy.can_upgrade():
				targets.append(enemy)
		return targets

class PayoffBlessMonsters extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		Audio.play_sfx(SFX.PayoffMonster)
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		for enemy in enemy_row.get_children():
			enemy.bless()
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffPermanentlyIgniteMonster extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		Audio.play_sfx(SFX.PayoffMonster)
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		
		var targets = Global.choose_x(enemy_row.get_multi_filtered_randomized([CoinRow.FILTER_NOT_IGNITED, CoinRow.FILTER_CAN_TARGET]), payoff_coin.get_active_power_charges())
		
		var callback = func(target):
			target.play_power_used_effect(payoff_coin.get_active_power_family())
			target.permanently_ignite()
		
		await ProjectileManager.fire_projectiles(payoff_coin, targets, callback)
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		var targets = Global.choose_x(enemy_row.get_multi_filtered_randomized([CoinRow.FILTER_NOT_IGNITED, CoinRow.FILTER_CAN_TARGET]), payoff_coin.get_active_power_charges())
		return CanUseResult.new(targets.size() != 0)

class PayoffAmplifyIgnite extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		Audio.play_sfx(SFX.PayoffMonster)
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		Global.ignite_damage += Global.CERBERUS_INCREASE_IGNITE[payoff_coin.get_denomination()]
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffIncreaseAllPlayerPenalty extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		Audio.play_sfx(SFX.PayoffMonster)
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		
		var targets = _get_targets(player_row)
		
		var callback = func(target):
			target.change_life_penalty_for_round(Global.STRIX_INCREASE[payoff_coin.get_denomination()])
			target.play_power_used_effect(payoff_coin.get_active_power_family())
		
		await ProjectileManager.fire_projectiles(payoff_coin, targets, callback)
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(_get_targets(player_row).size() != 0)
	
	func _get_targets(player_row) -> Array:
		var targets = []
		
		for coin in player_row.get_children():
			if coin.can_change_life_penalty():
				targets.append(coin)
		
		return targets

class PayoffIncreasePenaltyPermanently extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		Audio.play_sfx(SFX.PayoffMonster)
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		
		var targets =  Global.choose_x(player_row.get_multi_filtered_randomized([CoinRow.FILTER_CAN_INCREASE_PENALTY, CoinRow.FILTER_CAN_TARGET]), payoff_coin.get_active_power_charges())
		
		var callback = func(target):
			target.play_power_used_effect(payoff_coin.get_active_power_family())
			target.change_life_penalty_permanently(Global.KERES_INCREASE[payoff_coin.get_denomination()])
		
		await ProjectileManager.fire_projectiles(payoff_coin, targets, callback)
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		var targets =  Global.choose_x(player_row.get_multi_filtered_randomized([CoinRow.FILTER_CAN_INCREASE_PENALTY, CoinRow.FILTER_CAN_TARGET]), payoff_coin.get_active_power_charges())
		return CanUseResult.new(targets.size() != 0)

class PayoffIncreaseAllPenaltyPermanently extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		Audio.play_sfx(SFX.PayoffMonster)
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		
		var targets = _get_targets(player_row, enemy_row)
		
		var callback = func(target):
			target.change_life_penalty_permanently(Global.CERBERUS_INCREASE[payoff_coin.get_denomination()])
			target.play_power_used_effect(payoff_coin.get_active_power_family())
		
		await ProjectileManager.fire_projectiles(payoff_coin, targets, callback)
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(_get_targets(player_row, enemy_row).size() != 0)
	
	func _get_targets(player_row, enemy_row):
		var targets = []
		for coin in player_row.get_children() + enemy_row.get_children():
			if coin.can_change_life_penalty():
				targets.append(coin)
		return targets

class PayoffDesecrate extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		Audio.play_sfx(SFX.PayoffMonster)
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		
		var targets = Global.choose_x(player_row.get_multi_filtered_randomized([CoinRow.FILTER_NOT_DESECRATED, CoinRow.FILTER_CAN_TARGET]), payoff_coin.get_active_power_charges())
		
		var callback = func(target):
			target.play_power_used_effect(payoff_coin.get_active_power_family())
			target.desecrate()
		
		await ProjectileManager.fire_projectiles(payoff_coin, targets, callback)
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		var targets = Global.choose_x(player_row.get_multi_filtered_randomized([CoinRow.FILTER_NOT_DESECRATED, CoinRow.FILTER_CAN_TARGET]), payoff_coin.get_active_power_charges())
		return CanUseResult.new(targets.size() != 0)

class PayoffShuffle extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		Audio.play_sfx(SFX.PayoffMonster)
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		player_row.shuffle()
		for coin in player_row.get_children():
			coin.play_power_used_effect(payoff_coin.get_active_power_family())
		payoff_coin.clear_round_life_penalty()
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffBlankLeftHalf extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		Audio.play_sfx(SFX.PayoffMonster)
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		
		var targets = []
		var left_to_right = player_row.get_leftmost_to_rightmost()
		var n_affected = floor(player_row.get_child_count() / 2.0)
		for i in n_affected:
			targets.append(left_to_right[i])
		
		var callback = func(target):
			target.play_power_used_effect(payoff_coin.get_active_power_family())
			target.blank()
		
		await ProjectileManager.fire_projectiles(payoff_coin, targets, callback, Projectile.PARAMS_WHITE)
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffBlankRightHalf extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		Audio.play_sfx(SFX.PayoffMonster)
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		
		var targets = []
		var right_to_left = player_row.get_rightmost_to_leftmost()
		var n_affected = floor(player_row.get_child_count() / 2.0)
		for i in n_affected:
			targets.append(right_to_left[i])
			
		var callback = func(target):
			target.play_power_used_effect(payoff_coin.get_active_power_family())
			target.blank()
		
		await ProjectileManager.fire_projectiles(payoff_coin, targets, callback, Projectile.PARAMS_WHITE)
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffCurseUnluckyScaling extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		Audio.play_sfx(SFX.PayoffMonster)
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		
		var targets = _get_targets(payoff_coin, player_row)
		
		var callback = func(target):
			target.play_power_used_effect(payoff_coin.get_active_power_family())
			if target.is_unlucky():
				target.curse()
			elif target.is_cursed():
				target.make_unlucky()
			else:
				target.curse() if Global.RNG.randi_range(0, 1) == 0 else target.make_unlucky()

		# double the charges
		payoff_coin.change_charge_modifier_for_round(payoff_coin.get_active_power_charges())
		
		await ProjectileManager.fire_projectiles(payoff_coin, targets, callback)
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(_get_targets(payoff_coin, player_row).size() != 0)
	
	func _get_targets(payoff_coin, player_row):
		var targets = []
		var candidates = player_row.get_multi_filtered_randomized([CoinRow.FILTER_NOT_UNLUCKY, CoinRow.FILTER_CAN_TARGET]) + player_row.get_multi_filtered_randomized([CoinRow.FILTER_NOT_CURSED, CoinRow.FILTER_CAN_TARGET])
		candidates.shuffle()
		for i in payoff_coin.get_active_power_charges():
			if candidates.size() <= i:
				break
			targets.append(candidates[i])
		return targets

class PayoffAWayOut extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		payoff_coin.FX.flash(Color.WHITE)
		game.destroy_coin(payoff_coin)
		payoff_coin.play_power_used_effect(payoff_coin.get_active_power_family())
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffUnluckySelf extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		Audio.play_sfx(SFX.PayoffMonster)
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		payoff_coin.make_unlucky()
		payoff_coin.play_power_used_effect(payoff_coin.get_active_power_family())
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffFreezeSelf extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		Audio.play_sfx(SFX.PayoffMonster)
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		payoff_coin.freeze()
		payoff_coin.play_power_used_effect(payoff_coin.get_active_power_family())
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffBurySelf extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		Audio.play_sfx(SFX.PayoffMonster)
		var payoff_family = payoff_coin.get_active_power_family()
		
		payoff_coin.FX.flash(Color.SADDLE_BROWN)
		
		var duration = 1
		match payoff_family:
			Global.NEMESIS_POWER_FAMILY_LABYRINTH_WALL_BURY:
				duration = 1
			Global.MONSTER_POWER_FAMILY_ERYMANTHIAN_BOAR_BURY:
				payoff_coin.turn()
				duration = Global.BOAR_BURY[payoff_coin.get_denomination()]
		
		payoff_coin.bury(duration)
		payoff_coin.play_power_used_effect(payoff_family)
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffTrojanHorse extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		Audio.play_sfx(SFX.PayoffMonster)
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
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		Audio.play_sfx(SFX.PayoffMonster)
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		for mon in enemy_row.get_children():
			mon.make_unlucky()
			mon.play_power_used_effect(payoff_coin.get_active_power_family())
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffFreeze extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		Audio.play_sfx(SFX.PayoffMonster)
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		
		var targets = Global.choose_x(player_row.get_multi_filtered_randomized([CoinRow.FILTER_NOT_FROZEN, CoinRow.FILTER_CAN_TARGET]), payoff_coin.get_active_power_charges())
		
		var callback = func(target):
			target.play_power_used_effect(payoff_coin.get_active_power_family())
			target.freeze()
		
		await ProjectileManager.fire_projectiles(payoff_coin, targets, callback, Projectile.PARAMS_BLUE)
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		var targets = Global.choose_x(player_row.get_multi_filtered_randomized([CoinRow.FILTER_NOT_FROZEN, CoinRow.FILTER_CAN_TARGET]), payoff_coin.get_active_power_charges())
		return CanUseResult.new(targets.size() != 0)

class PayoffBless extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		payoff_coin.FX.flash(Color.GHOST_WHITE)
		
		var targets = Global.choose_x(player_row.get_multi_filtered_randomized([CoinRow.FILTER_NOT_BLESSED, CoinRow.FILTER_CAN_TARGET]), payoff_coin.get_active_power_charges())
		
		var callback = func(target):
			target.play_power_used_effect(payoff_coin.get_active_power_family())
			target.bless()
		
		await ProjectileManager.fire_projectiles(payoff_coin, targets, callback, Projectile.PARAMS_YELLOW)
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		var targets = Global.choose_x(player_row.get_multi_filtered_randomized([CoinRow.FILTER_NOT_BLESSED, CoinRow.FILTER_CAN_TARGET]), payoff_coin.get_active_power_charges())
		return CanUseResult.new(targets.size() != 0)

class PayoffGainThornsGadfly extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		Audio.play_sfx(SFX.PayoffMonster)
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		var thorns_denom = Global.GADFLY_THORNS_DENOM[payoff_coin.get_denomination()]
		if player_row.get_child_count() != Global.COIN_LIMIT:
			var coin = game.make_and_gain_coin(Global.THORNS_FAMILY, thorns_denom, game.CHARON_NEW_COIN_POSITION)
			coin.play_power_used_effect(payoff_coin.get_active_power_family())
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffGainThornsSphinx extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		Audio.play_sfx(SFX.PayoffMonster)
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		var thorns_denom = Global.SPHINX_THORNS_DENOM[payoff_coin.get_denomination()]
		if player_row.get_child_count() != Global.COIN_LIMIT:
			var coin = game.make_and_gain_coin(Global.THORNS_FAMILY, thorns_denom, game.CHARON_NEW_COIN_POSITION)
			coin.play_power_used_effect(payoff_coin.get_active_power_family())
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffBuryLamia extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		Audio.play_sfx(SFX.PayoffMonster)
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		
		var targets = [Global.choose_one(player_row.get_multi_filtered_randomized([CoinRow.FILTER_NOT_BURIED, CoinRow.FILTER_CAN_TARGET]))]
		assert(targets.size() == 0 or targets.size() == 1)
		
		var callback = func(target):
			target.play_power_used_effect(payoff_coin.get_active_power_family())
			target.bury(Global.LAMIA_BURY[payoff_coin.get_denomination()])
		
		await ProjectileManager.fire_projectiles(payoff_coin, targets, callback, Projectile.PARAMS_BROWN)
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		var targets = [Global.choose_one(player_row.get_multi_filtered_randomized([CoinRow.FILTER_NOT_BURIED, CoinRow.FILTER_CAN_TARGET]))]
		return CanUseResult.new(targets.size() != 0)

class PayoffBuryOread extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		Audio.play_sfx(SFX.PayoffMonster)
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		
		var targets = [Global.choose_one(player_row.get_multi_filtered_randomized([CoinRow.FILTER_NOT_BURIED, CoinRow.FILTER_CAN_TARGET]))]
		assert(targets.size() == 0 or targets.size() == 1)
		
		var callback = func(target):
			target.play_power_used_effect(payoff_coin.get_active_power_family())
			target.bury(Global.OREAD_BURY[payoff_coin.get_denomination()])
		
		await ProjectileManager.fire_projectiles(payoff_coin, targets, callback, Projectile.PARAMS_BROWN)
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		var targets = [Global.choose_one(player_row.get_multi_filtered_randomized([CoinRow.FILTER_NOT_BURIED, CoinRow.FILTER_CAN_TARGET]))]
		return CanUseResult.new(targets.size() != 0)

class PayoffBury extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		Audio.play_sfx(SFX.PayoffMonster)
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		
		var targets = _get_targets(payoff_coin, player_row)
		
		var callback = func(target):
			target.play_power_used_effect(payoff_coin.get_active_power_family())
			target.bury(_get_bury_duration(payoff_coin))
		
		await ProjectileManager.fire_projectiles(payoff_coin, targets, callback, Projectile.PARAMS_BROWN)
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(_get_targets(payoff_coin, player_row).size() != 0)
	
	func _get_bury_duration(payoff_coin) -> int:
		var payoff_family = payoff_coin.get_active_power_family()
		match payoff_family:
			Global.MONSTER_POWER_FAMILY_CYCLOPS_BURY:
				return 1
			Global.MONSTER_POWER_FAMILY_LAMIA_BURY:
				return 2
			Global.MONSTER_POWER_FAMILY_OREAD_BURY, _:
				return 1
	
	func _get_num_bury_targets(payoff_coin) -> int:
		var payoff_family = payoff_coin.get_active_power_family()
		match payoff_family:
			Global.MONSTER_POWER_FAMILY_CYCLOPS_BURY:
				return Global.CYCLOPS_BURY[payoff_coin.get_denomination()]
			Global.MONSTER_POWER_FAMILY_LAMIA_BURY:
				return Global.LAMIA_BURY[payoff_coin.get_denomination()]
			Global.MONSTER_POWER_FAMILY_OREAD_BURY, _:
				return Global.OREAD_BURY[payoff_coin.get_denomination()]
	
	func _get_targets(payoff_coin, player_row) -> Array:
		var num_targets = _get_num_bury_targets(payoff_coin)
		return Global.choose_x(player_row.get_multi_filtered_randomized([CoinRow.FILTER_NOT_BURIED, CoinRow.FILTER_CAN_TARGET]), num_targets)

class PayoffTransform extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		Audio.play_sfx(SFX.PayoffMonster)
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		
		var targets = [Global.choose_one(player_row.get_filtered_randomized(CoinRow.FILTER_CAN_TARGET))]
		
		var callback = func(target):
			target.init_coin(Global.random_coin_family_excluding([target.get_coin_family()]), target.get_denomination(), target.get_current_owner())
			target.play_power_used_effect(payoff_coin.get_active_power_family())
		
		await ProjectileManager.fire_projectiles(payoff_coin, targets, callback)
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		var targets = [Global.choose_one(player_row.get_filtered_randomized(CoinRow.FILTER_CAN_TARGET))]
		return CanUseResult.new(targets.size() != 0)

class PayoffGainObol extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		payoff_coin.FX.flash(Color.WHITE)
		if player_row.get_child_count() != Global.COIN_LIMIT:
			var new_coin = game.make_and_gain_coin(Global.random_coin_family(), Global.Denomination.OBOL, payoff_coin.global_position, true)
			new_coin.play_power_used_effect(payoff_coin.get_active_power_family())
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffDecreaseCost extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		payoff_coin.FX.flash(Color.WHITE)
		payoff_coin.change_monster_appease_price(-payoff_coin.get_active_power_charges())
		payoff_coin.play_power_used_effect(payoff_coin.get_active_power_family())
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffIncreaseCost extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		Audio.play_sfx(SFX.PayoffMonster)
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		payoff_coin.change_monster_appease_price(payoff_coin.get_active_power_charges())
		payoff_coin.play_power_used_effect(payoff_coin.get_active_power_family())
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffDestroySelf extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		game.destroy_coin(payoff_coin)
		payoff_coin.play_power_used_effect(payoff_coin.get_active_power_family())
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffCurseUnluckySelf extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		Audio.play_sfx(SFX.PayoffMonster)
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		payoff_coin.curse()
		payoff_coin.make_unlucky()
		payoff_coin.play_power_used_effect(payoff_coin.get_active_power_family())
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)

class PayoffDowngrade extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		Audio.play_sfx(SFX.PayoffMonster)
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		
		var targets = _get_targets(payoff_coin, player_row)
		
		var callback = func(target):
			game.downgrade_coin(target)
			target.play_power_used_effect(payoff_coin.get_active_power_family())
		
		await ProjectileManager.fire_projectiles(payoff_coin, targets, callback)
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(_get_targets(payoff_coin, player_row).size() != 0)
	
	func _get_targets(payoff_coin, player_row) -> Array:
		var targets = []
		var all_previous_were_obols = true
		var candidates = player_row.get_filtered_randomized(CoinRow.FILTER_CAN_TARGET)
		for i in range(0, payoff_coin.get_active_power_charges()):
			if candidates.size() <= i:
				break # no more to take
			
			var candidate_coin  = candidates[i]
			
			# extreme edge case... 
			# if we are trying to take a coin, and it is the last coin in high to low
			# and all previous coins were obols, and this coin is also an obol
			# we don't want to do it, since it would destroy the last coin (leaves player with no coins)
			# in this case, skip.
			if candidates.size() - 1 == i and all_previous_were_obols and candidate_coin.get_denomination() == Global.Denomination.OBOL:
				break
			
			# otherwise, add to targets
			if all_previous_were_obols and candidate_coin.get_denomination() != Global.Denomination.OBOL:
				all_previous_were_obols = false
				
			targets.append(candidate_coin)
		return Global.choose_x(targets, payoff_coin.get_active_power_charges())

class PayoffDoomRightmost extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		Audio.play_sfx(SFX.PayoffMonster)
		
		var targets = _get_targets(player_row)
		
		var callback = func(target):
			target.doom()
			target.play_power_used_effect(payoff_coin.get_active_power_family())
		
		await ProjectileManager.fire_projectiles(payoff_coin, targets, callback)
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(_get_targets(player_row).size() != 0)
	
	func _get_targets(player_row) -> Array:
		var right_to_left = player_row.get_rightmost_to_leftmost()
		for coin in right_to_left:
			if not coin.is_doomed():
				return [coin]
		return []

class PayoffDowngradeAndPrime extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		Audio.play_sfx(SFX.PayoffMonster)
		
		var targets = _get_targets(payoff_coin, player_row)
		
		var callback = func(target):
			target.prime()
			game.downgrade_coin(target)
			target.play_power_used_effect(payoff_coin.get_active_power_family())
		
		await ProjectileManager.fire_projectiles(payoff_coin, targets, callback)
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(_get_targets(payoff_coin, player_row).size() != 0)
	
	func _get_targets(payoff_coin, player_row) -> Array:
		var targets = []
		var all_previous_were_obols = true
		var candidates = player_row.get_filtered_randomized(CoinRow.FILTER_CAN_TARGET)
		for i in range(0, payoff_coin.get_active_power_charges()):
			if candidates.size() <= i:
				break # no more to take
			
			var candidate_coin  = candidates[i]
			
			# extreme edge case... 
			# if we are trying to take a coin, and it is the last coin in high to low
			# and all previous coins were obols, and this coin is also an obol
			# we don't want to do it, since it would destroy the last coin (leaves player with no coins)
			# in this case, skip.
			if candidates.size() - 1 == i and all_previous_were_obols and candidate_coin.get_denomination() == Global.Denomination.OBOL:
				break
			
			# otherwise, add to targets
			if all_previous_were_obols and candidate_coin.get_denomination() != Global.Denomination.OBOL:
				all_previous_were_obols = false
				
			targets.append(candidate_coin)
		return Global.choose_x(targets, payoff_coin.get_active_power_charges())
		
class PayoffUpgradeSelf extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		Audio.play_sfx(SFX.PayoffMonster)
		payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
		if payoff_coin.can_upgrade():
			payoff_coin.upgrade()
			payoff_coin.play_power_used_effect(payoff_coin.get_active_power_family())
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)






class TEMPLATE extends PowerFamily:
	func use_power(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow, patron_token: PatronToken = null) -> void:
		pass
	
	func can_use(game: Game, payoff_coin: Coin, left: Coin, right: Coin, target_row: CoinRow, player_row: CoinRow, enemy_row: CoinRow) -> CanUseResult:
		return CanUseResult.new(true)
#  payoff_coin.get_active_power_charges()
#  payoff_coin.get_denomination()
