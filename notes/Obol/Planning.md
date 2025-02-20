**Charon's Obol v0.3 - Myths and Monsters**
- [ ] **Active Goals - Mar 1 Sprint - More Content**
	- [ ] **More Coins**
		- [ ] Organize existing coin ideas into families.
		- [ ] Choose new coins.
			- [ ] 5 Payoffs
			- [ ] 15 Powers
	
**Charon's Obol Beta - Coalescence**
- [ ] **Content Wave 2**
	- [ ] **New Bosses**
	- [ ] **More Monsters**
- [ ] **Content Wave 3**
	- [ ] **More Characters**
- [ ] **Coin Graphical Effects**
	- [ ] **Improved Graphical effects for coins (ie lightning, fire, wind, etc - basic effects, reuse)**
	- [ ] **Enhanced Monster Effects (Projectile animations)**
		- [ ] Add projectiles for monster coins targetting coins in player's row. 
			- [ ] projectilesystem creates projectiles (Sprite2D with particles in charge of moving), signal when it hits
			- [ ] Just need to await for it to finish
				- [ ] if there are multiple, it's slightly trickier. maybe we actually create a projectilesystem, which can manage multiple projectiles and signals when both are done? seems reasonable. it can keep a reference count
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
- [ ] **Orphic Tablets**
	- [ ] Option unlocked on main menu once unlocked.
	- [ ] New tablets unlocked in progression.
	- [ ] Unlocked upon tutorial completion, populated with initial tutorials rehashing tutorial.
	- [ ] Status - shows a list of all status icons and effects
	- [ ] **Coin Gallery**
		- [ ] Shows all coins unlocked and their upgrade states, in rows. Page-able list.
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
- [ ] **Unlocks; both steady and an unlock for each character/nemesis**
	- [ ] Achievement system for unlocks. Should appear on main menu. 

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
- [ ] Add custom seed option in main menu eventually
	- [ ] Change RNG so that Trails/Boss/Charon, Shop, and coin RNG are all different.



https://en.wikipedia.org/wiki/Apega_of_Nabis
https://en.wikipedia.org/wiki/Macaria

---

**Potential Coins**



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