**Charon's Obol v0.3 - Myths and Monsters**
- [ ] **Active Goals - Feb 16 Sprint**
	- [ ] **Week**
		- [ ] **Implementing Difficulties**
			- [ ] Hostile - Malice
		- [ ] **Malice**
			- [ ] Ensure that we don't get any buggy behavior - possibly wait for any pending flips to finish before resolving malice attack.
			- [ ] Slight vignette flash red when taking damage. Vignette strength based on current health. Lightly persists even outside of damage taking.
			- [ ] **Malice effect ideas:**
				- [ ] Goal - do something that doesn't totally wipe you out, but feels mean and targetted.
				- [ ] Charon should only do a single, impactful ability - not multiple smaller things.
				- [ ] Each ability should have a corresponding line of Charon's exclaimation of anger.
				- [ ] Future improvement - we could look at the coins in the row, categorize them by power type, and base decisions on that
					- [ ] if zeus/artemis is in row - more likely to unlucky
					- [ ] if hades is in row - don't bother with obols of thorns
					- [ ] if heph is in row - more likely to downgrade
					- [ ] if poseidon is row - more likely to ignite or target it specifically (lol)
					- [ ] if hestia is in row - more likely to curse and unlucky
				- [ ] Abilities for post-payoff
					- [x] Apply Unlucky to half coins (odds increased for Lucky coins; odds also increased based on arrows)
					- [x] Apply Ignite half coins (odds increased for coins frozen on heads; also increased if the round count and life count is high (ie counter healing stall))
					- [ ] Curse coins. (odds increased for coins on heads or blessed; odds increased for coins of high denoms; aims for coins on heads and of high denom)
					- [ ] Increase tails penalty (odds increased for each coin on tails)
					- [ ] Give an Obol of Thorns. (odds increased based on having empty spaces in row; don't do this unless the player has <=8 coins. ie don't lock the last slot)
					- [ ] Turn several power coins to stone (prefer to target power coins with charges)
					- [ ] Strengthen monsters (odds increased based on rounds passed; require 2+ monsters; ie punish for not clearing them; increase their denoms by 1).
				- [ ] Abilities for post-power
					- [ ] Turn all payoffs to tails. (odds increased for payoffs on heads. Minimum 2 coins turned.)
					- [ ] Drain power charges from all (odds increased for power coins on heads with 2+ charges. Minimum 3 coins drained.)
					- [ ] Spawn 2-3 monsters (odds increased based on monsters killed this round; delta between this round's monster strength and row's current strength; only if 2 or fewer monsters; monster denoms based on round strength). 
					- [ ] Reflip all coins on heads. (odds increased based on coins on heads, but only if 2/3rd of coins are on heads)
					- [ ] Freeze coins on tails (odds increased for coins on tails, but only if half coins are on heads.)
					- [ ] Blank, curse, freeze, unlucky a single coin (odds increased for a powerful high denom power coin on heads; aims for the most powerful coin; basically screw this coin)
					- [ ] Downgrade some coins (odds increased based on having many more coins than the next tollgate, if there is one. can't hit obols, no destruction)
	- [ ] **Weekend**
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
	- [ ] **More Coins +20**
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




**Potential Coins**
Achilles - Held by the Heel - High shard reward, huge life loss on tails and destroy itself.
Icarus - Waxen Wings, Melting - Shards based on number of heads; but if all heads, destroyed
Hercules - Twelve Labors - Increased payoff each time it pays out in a row. Reset to 0 on tails. Base amount determined by denomination level.
Tantalus - Whenever this card is on heads, gain souls then immediately turn it to tails.
Helios - Sun Rise and Set - Gain 1 soul, plus another 3 souls for every coin to the right of this, then move once to the left. Also blesses coins as it passes.
??? - +1 soul per 20/17/14/10 life you have.
??? - At the end of the round, destroy this and gain a random coin of greater value. (low payoff)
??? - 10/20/30/40 souls, reduced by 3/5/7/9 for each power you've used this toss.


Perseus - Reflect the Gorgon's Gaze- Turn a coin to stone (never flips again, does not recharge) or unstone a coin. Stone coins also lose 1 value.
??? - Blank 2 random tails coins.
??? - This payoff, when you would lose life, gain that much instead. Requires 6/5/4/3 tosses to recharge.
??? - Gain a random Obol/Diobol/Triobol/Tetrobol (on heads). It is Doomed (destroy at the end of the round).
??? - Gain a coin with +5/-5 and flip it. After payoff, destroy it.
??? - Hero - Downgrade a monster coin. If this destroys it, gain 10 souls. (diobol - 15 souls; triobol - double downgrade; tetrobol - 30 souls.)
??? - Infinite uses. Reflip a coin, then lose 1 life. Life loss increases each time this is used. Resets when upgraded.
Aeolus - The Winds Shall Obey - Reflip each coin to the left/right of this (alternates each use)
Notus - Southern Heat - Choose a coin. Swap positions with it, then reflip each coin between that coin and this coin. 
Boreas - Northern Hail - Choose a coin. Swap positions with it, then reflip this coin's new neighbors.
Zephyros - Westward Breeze - Choose a coin. Move it to the left, then reflip its neighbors (but not it).
Eurus - Eastern Turbulence - Choose a coin. Move it to the rightmost position. Reflip the leftmost and rightmost coins.
Gaia - Gravitic Pull - pull a coin 1 space closer to this coin (pulls to other side if already adjacent), then flip both coins adjacent to this coin to their opposite side.
Uranus - Sky Pulse - choose a coin. Push the coin to the left and right of that coin once away from it. Then reflip each coin to the left of the coin pushed left or the right of the coin pushed right.
??? - Choose a coin. Pull it once closer to this coin. Then flip each coin that moved.
??? - Destroy this coin. Gain 1 god power charge, 3 arrows, 5 souls, and 3 life. Upgrades each round.
Dolos - Choose a coin. This coin permanently becomes a copy of that coin.
??? - Split a Diobol, Triobol, or Tetrobol into two coins of half value (cannot be used on Obols)
??? - Transform into a random heads power coin every flip. The first time this power is used, permanently become that type of coin.
??? - Jack of all coins - rotates between these powers each toss, only ever 1 activation, cannot be upgraded: Reflip, Bless, Freeze, Destroy, Stone
??? - Reflip the coins to the left and right of this. Whenever you use a neighboring coin's power, it spends from here instead.
Fickle Nymph - Coins to the left land on heads 10/12/15/18% more often; coins to the right land on tails more often. Power - move this randomly once to the left or right.
	- [ ] Daedalus(?) - Choose two coins you control; merge them together (the coin becomes heads on two sides basically) and destroy this coin.
		- [ ] Handling - Each side of this coin is the Daedalus power, which is "permaently copy another coin's power to this face."
??? - Daedalus - Copy another coin's power onto this coin's tails and give it +0/1/2/3 charges, but it does not recharge naturally.
Midas - Gain a golden Obol/Diobol/Triobol/Tetrobol! Golden coins do nothing, but can be used to pay for tolls or other abilities
??? - Destroy this coin. Gain 2 coins of equal denomination. Cannot be upgraded in the shop. Upgrades automatically when a round ends.




		- [ ] Odysseus - The Hero's Return. A variety of stages in order must be completed. Always starts as Obol and upgrades at set points; cannot be upgraded in shop. Change flavor text each use.
			- [ ] Reflip 2 random coins.
			- [ ] Lose 5 shards.
			- [ ] Bless a coin.
			- [ ] Exchange a coin.
			- [ ] Destroy a coin.
			- [ ] Move a coin thrice to the left (must be able to move the coin).
			- [ ] Curse a coin and its neighbors.
			- [ ] Change a coin to heads.
			- [ ] Reflip each coin on hjeads.
			- [ ] Upgrade a coin.
			- [ ] Destroy your highet value coin besides this, lose all god power charges, and gain an upgraded monster coin which cannot be destroyed or spent.
			- [ ] Bury this coin. After 5 tosses, return, permanently change to heads, and annihilate all monster coins.
			- [ ] Turn your souls into life. Flip all your coins to heads. Destroy this coin.


		- [ ] Pandora - 7 sins + hope (alt win condition)
			- [ ] Wrath - Lose all your life (minimum 25)
			- [ ] Sloth - End the round. Must be the first power you use this round.
			- [ ] Greed - lose 100 souls.
			- [ ] Gluttony - lose every charge from a heads coin (min 20), curse all coins.
			- [ ] Lust - lose all your god power charges. permanently destroy your god statue.
			- [ ] Pride - flip all your coins to tails and freeze them.
			- [ ] Envy - transform every other coin into a random coin and reflip them.
			- [ ] Hope - you win the game.


THIS WOULD BE GOOD AS A MONSTER
	- [ ] ??? - Merchant - Randomly transforms between the following 'powers'/'items', which cost souls to use
		- [ ] Freeze a coin.
		- [ ] Reflip a coin.
		- [ ] Make a coin Lucky.
		- [ ] Bless a coin.
		- [ ] Change a coin to its other face.
		- [ ] Clear negative statuses from a coin.
??? - Many charges - Change a random coin to its other side.


- [ ] Locked - Prevents the coin from flipping, payoff, or being activated for the rest of the round (bound in chains graphically).
- [ ] Ward - Blocks the next power applied to this coin, then deletes the ward.
- [ ] Reflip some heads coins.

- [ ] Tap a coin - whenever a power on that coin is used, lose life.
- [ ] Imprison a coin - locks up a coin (blank + doesn't flip); spend souls to unlock.
- [ ] Sap - Coin does not naturally recharge each toss.