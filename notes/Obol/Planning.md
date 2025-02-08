**Charon's Obol v0.3 - Myths and Monsters**
- [ ] **Active Goals - Feb 16 Sprint**
	- [ ] **Weekend**
		- [ ] **Implementing Difficulties**
			- [x] Indifferent - done
			- [ ] Hostile - Malice
			- [ ] Greedy - Coin upgrade prices uniformly higher. Obols are very slightly more expensive. Tollgates require a larger payment. 
				- [ ] New prices are hardcoded in Global. Obols uniformly cost an extra ~2 souls perhaps.
				- [ ] Tollgate prices increased by a flat multiplier of 1.3 or so?
			- [ ] Cruel - Trials have two modifiers. Trial soul quotas are higher. 
				- [ ] On map, show two icons for trial in a column. 
				- [ ] Soul quotas increased by a flat multiplier of 1.3 or so?
			- [ ] Unfair - Monsters are stronger and more numerous. Nemesis is stronger.
				- [ ] Add Pentobol and Drachma for all coins. 
					- [ ] Update Hepaestus ability to allow upgrades up to Drachma. Active just becomes "upgrade a coin, recharge it, and turn it to heads."
				- [ ] Make Nemesis abilities scale with denomination. 
				- [ ] On this difficulty, Nemesis spawn as Drachma.
				- [ ] Change how monster waves work. Each round defines a 'monster strength' value and a 'number of elites'. Then the game generates an appropriate monster wave based on that value when you reach that, instead of hardcoded possible wave types, with the required number of elites.
				- [ ] For the difficulty level, monster strength is increased by a certain amount which scales with round_count.
		- [ ] **Malice**
			- [ ] Basically a counter which increments when Charon is mad, once it peaks, do a negative thing and reset the counter.
			- [ ] Increases when you land heads from a toss flip; trigger a god power, or payoff a coin on heads. 
			- [ ] Decreased when you end the round (by half).
			- [ ] Decreases to 0 after Charon activates.
			- [ ] Visual graphical effects to imply when Charon is getting angry - flames, particles, darkening screen, etc.
				- [ ] Indicator at 50%, 70%, and 90%.
			- [ ] **Malice effect ideas:**
				- [ ] Turn all payoffs to tails
				- [ ] Turn half powers to tails
				- [ ] Reflip all coins
				- [ ] Drain power charges
				- [ ] Curse a coin
				- [ ] Unlucky a coin
				- [ ] Ignite a coin
				- [ ] Freeze coins on tails
				- [ ] Clear positive statuses
				- [ ] Summon a monster
				- [ ] Blank a coin
				- [ ] Increase tails penalty
				- [ ] Give Obol of Thorns. (what happens if row is full? maybe just skips to next attack in rotation)
				- [ ] Sap - Coin does not naturally recharge each toss.
				- [ ] Locked - Prevents the coin from flipping, payoff, or being activated for the rest of the round (bound in chains graphically).
				- [ ] Ward - Blocks the next power applied to this coin, then deletes the ward.
				- [ ] Reflip some heads coins.
				- [ ] Curse some coins.
				- [ ] Turn a coin to stone.
				- [ ] Ignite a coin.
				- [ ] Turn a coin to glass.
				- [ ] Blank a coin for the rest of the round.
				- [ ] Flip a heads coin to tails.
				- [ ] Give an Obol of Thorns.
				- [ ] Freeze a coin on tails.
				- [ ] Summon a monster. (maybe do this instead of monster encounter rounds, just have Charon regularly summon monsters over time)
				- [ ] Downgrade a coin.
				- [ ] Deal some damage.
				- [ ] Extinguish Prometheus flame. (maybe half the stacks)
				- [ ] Tap a coin - whenever a power on that coin is used, lose life.
				- [ ] Imprison a coin - locks up a coin (blank + doesn't flip); spend souls to unlock.
				- [ ] (at 20+ flips) forcibly end the round.
				- [ ] Give Obol of Thorns
				- [ ] Summon monsters
			- [ ] For now - Charon does not tell what he is going to do until he does it. You know he will do 'something', but not what that 'something' is. When Charon activates, he has a simplistic AI script which determines something painful (but not devastating) which he will do. 
	- [ ] **Enhanced Monster Effects (Projectile animations)**
		- [ ] Charon Hands have 2 new states - Open and Slam. Open and glowing while preparing for Malice. Slam + screen shake when he does it (then open while casting).
		- [ ] Add projectiles for monster coins targetting coins in player's row. 
			- [ ] projectilesystem creates projectiles (Sprite2D with particles in charge of moving), signal when it hits
			- [ ] Just need to await for it to finish
				- [ ] if there are multiple, it's slightly trickier. maybe we actually create a projectilesystem, which can manage multiple projectiles and signals when both are done? seems reasonable. it can keep a reference count
	- [ ] **Tutorial Tuning**
		- [ ] Don't show UPGRADE mouse cursor change during tutorial until it is unlocked.
		- [ ] The Shop Mat should be brought to front when introducing the shop.
		- [ ] Mouse cursor replacements need scaling based on the size of the window. Right now they are constant size. This makes them very large on smaller monitors and smaller on large ones. 
		- [ ] Patron token passives (Charon included) should do an additional animation or raise or jiggle or something when they trigger. I could see a slight rotation shake being effective for both this and for coin payoffs. 
		- [ ] "Patrons have both an activated power" <- use POWER icon here instead of the word power
		- [ ] When entering the shop, add a delay before you can click to leave (0.5 second should be plenty). Prevent accidental rushing through shop.
		- [ ] Improve wording for enemy coins. Instead of "they may be affected by powers (sic)"; mention you can USE coin powers on them.
			- [ ] During the round, once a player has enough souls, Charon interrupts (just once) to explain that you can click the enemy to destroy it.
		- [ ] Change POWER on patron token to a different color to imply it is different from other powers and does not recharge each toss like coins do.
		- [ ] Better wording for "doesn't flip coins... it simply turns them to their other side" ('isn't that what flip means'?) perhaps, add the word randomly
		- [ ] Make sure the Wait! when Zeusing a heads coin in tutorial does not trigger on monster coins (since that may be intended)
		- [ ] If you click a button, drag off and release, the button shouldn't activate (but it does).


	- [ ] Stretch Goals
		- [ ] **Scales of Themis**
			- [ ] Shows overall 'heat' level of difficulty settings.
			- [ ] Offers further difficulty tuning, can be used at any difficulty once unlocked. Scales shown on main menu.
			- [ ] Tails chance
			- [ ] Shop prices
				- [ ] Affects both obol scaling and upgrades
			- [ ] Tollgate prices
				- [ ] flat increase based on round
			- [ ] Monster strength
			- [ ] Life penalties
				- [ ] flat increase/decrease
			- [ ] Strain
				- [ ] flat increase/decrease
		- [ ] **Orphic Tablets**
			- [ ] Option unlocked on main menu once unlocked.
			- [ ] New tablets unlocked in progression.
			- [ ] Unlocked upon tutorial completion, populated with initial tutorials rehashing tutorial.
			- [ ] Status - shows a list of all status icons and effects
			- [ ] **Coin Gallery**
				- [ ] Shows all coins unlocked and their upgrade states, in rows. Page-able list.

**Charon's Obol Beta - Coalescence**
- [ ] **Coin Graphical Effects**
- [ ] **More Content**
	- [ ] **New bosses**
	- [ ] **More Monsters**
	- [ ] **More Coins +30**
	- [ ] **More Characters +3**
	- [ ] **Steady Unlocks** + **Unlocks for each character & nemesis**
- [ ] **Basic Sound
- [ ] **Additional Refactors**
	- [ ] Separate out Global.gd into multiple files.
		- [ ] VoyageInfo, Util, CoinInfo, PatronInfo, SaveLoad, EventBus
	- [ ] Cleanup game.gd so that functions are ordered better; try to reduce size.
	- [ ] Cleanup coin.gd in the same way.
	- [ ] **Coin Power Refactor**
		- [ ] Each power should specify a TargetType enum. "OwnCoins" "Auto" "EnemyCoins" "AnyCoin" "PayoffGainSouls" "PayoffLoseLife. 
			- [ ] If "Auto", that's how we know not to prompt for a target and to immediately activate
			- [ ] The Payoff powers are used to determine if/how this coin resolves during payoff. Ie each lose life power would use PayoffLoseLife, but with a different charge count.
			- [ ] Each Soul payoff coin could use PayoffGainSouls and automatically update its charges as required.
		- [ ] Powers should have a lambda function they call. We may need to change how certain functions such as destroy_coin, downgrade_coin, and safe_flip function to make this feasible. (these should probably not exist in game.gd. Rather, they should be part of flip, destroy, and downgrade in coin. We may need to add signal emits to let game.gd react - ie coinrow may need to perform cleanup, track active flips, etc. Event bus is probably appropriate.)

**Charon's Obol Release**
- [ ] **Settings menu**
- [ ] **Controller Support**
- [ ] **Coin Gallery**
- [ ] **More Content**
- [ ] **Polish**
- [ ] **Bugs**
- [ ] **Coinsets** - multiple options for what coins form the coinpool.
	- [ ] Complete - everything
	- [ ] Classic - Olympians (the 13 original)
	- [ ] Classic+ - Classic with a few more additions, around ~25 coins.
	- [ ] Remix/Redux/Remake - Small sets of 25 coins, basically alternative Classic.
	- [ ] Finesse - Tricky coins, hard to use
	- [ ] Elements - Manipulation with lightning, freeze, ignite, wind coins.
	- [ ] Heroic - No gods, instead only heroic greek figures.
	- [ ] Worldly - nature themed coins, healing focus
	- [ ] Corrupted - Coins with downsides
	- [ ] Metamorphosis - Coins that trade, exchange, gain, destroy coins.
	- [ ] Preordained - Absolutely no coins that reflip, focus on lucky/bless etc
	- [ ] Fundamentals - Absolutely no coins with Statuses.
	- [ ] Oracle's Choice - randomized pool of 25 coins, changing daily.
	- [ ] Charon's Choice - randomized pool of 25 coins, changes each time you choose it.





https://en.wikipedia.org/wiki/Apega_of_Nabis
https://en.wikipedia.org/wiki/Macaria

---
**Expanded - Characters, Coins, Difficulties, Unlocks**

- [ ] Add custom seed option in main menu eventually
- [ ] Change RNG so that Trails/Boss/Charon, Shop, and coin RNG are all different.

