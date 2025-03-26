**Charon's Obol v0.3 - Myths and Monsters**
- [ ] **Active Goals - Mar 30 Sprint**
	- [ ] **Content**
		- [ ] Freeze nerf - do not recharge if frozen
			- [ ] don't retract frozen coins as part of signaling this
		- [ ] Add monsters to map.
		- [ ] **New Trials**
	- [ ] **QoL**
		- [ ]  Add a hotkey which, when held, shows the icons of your coins. (shift or control probably)
		- [ ] Add a button to disable tooltips. (tab probably, also visible on screen).
		- [ ] Can't accidentally mash through shop. Put a 1sec delay on entering shop and being allowed to press continue (don't show this visually, just ignore the click)
		- [ ] Tooltip improvements/fixes (directional tooltips - tooltips prefer going in a specific direction depending on row etc)
		- [ ] Need some visual effect to denote passive
			- [ ] ideal - rotating pixel around edge, but we would need to do a lot of annoying handling for this; it is not generalizable. We would need to hand-make an animation for each possible coin shape that has a passive. This is doable but inconvenient, especially for trials. In this case, we may as well just make the trial coin size uniform. There isn't really a good reason for them to be differnet like they are now tbh.
		- [ ] Patron token passives (Charon included) should do an additional animation or raise or jiggle or something when they trigger. I could see a slight rotation shake being effective for both this and for coin payoffs.
	- [ ] **Tutorial Tuning**
		- [ ] fixed?
			- [ ] Don't show UPGRADE mouse cursor change during tutorial until it is unlocked.
			- [ ] Don't show upgrade prices or allow upgrades in the first shop.
			- [ ] The Shop Mat should be brought to front when introducing the shop.
			- [ ]  "Patrons have both an activated power" <- use POWER icon here instead of the word power
			- [ ] Change POWER on patron tokens to a different color to imply it is different from other powers and does not recharge each toss like coins do.
			- [ ] Force default tutorial coinpool when playing the tutorial (don't use any unlocks)
			- [ ] We shouldn't show the first power coin until Charon introduces the shop a bit more.
			- [ ] Make sure prices are reasonable. (possibly reduce them significantly during tutorial?)
			- [ ] During the round, once a player has enough souls, Charon interrupts (just once) to explain that you can click the enemy to destroy it.
			- [ ] When entering the shop, add a delay before you can click to leave (0.5 second should be plenty). Prevent accidental rushing through shop. don't need to show player disabled, just prevent clickty

**Backlog**
- [ ] **More Characters (2-3 days)**
	- [ ] 4 new characters.
		- [ ] The Merchant
		- [ ] The Archon
		- [ ] The Gardener
		- [ ] The Child
	- [ ] Coin exclusion list per character to block bad interactions.

**Charon's Obol Release**
- [ ] **Sound - 8 weeks**
- [ ] **Revamped Unlock System - 2 weeks**
	- [ ] Achievement system for unlocks. Should appear on main menu.
- [ ] **Orphic Tablets - 1 week**
	- [ ] Option unlocked on main menu once unlocked.
	- [ ] New tablets unlocked in progression.
	- [ ] Unlocked upon tutorial completion, populated with initial tutorials rehashing tutorial.
	- [ ] Status - shows a list of all status icons and effects
	- [ ] **Coin Gallery**
		- [ ] Shows all coins unlocked and their upgrade states, in rows. Page-able list.
- [ ] **Settings Menu & Controller Support - 2 weeks**
	- [ ] Add settings menu.
	- [ ] Add support for controllers.
- [ ] **More Content - 8 weeks**
	- [ ] **20 Characters**
	- [ ] **100 Coins**
	- [ ] **Charon Extension**
		- [ ] Charon action ideas:
			- [ ] Bury valuable coin.
			- [ ] Ignite monsters.
			- [ ] Lucky monsters.
			- [ ] Bless monsters.
* [ ] **Coin Graphical Effects - 2 weeks**
	- [ ] **Improved Graphical effects for coins (ie lightning, fire, wind, etc - basic effects, reuse)**
	- [ ] **Enhanced Monster Effects (Projectile animations)**
		- [ ] Add projectiles for monster coins targetting coins in player's row.
			- [ ] projectilesystem creates projectiles (Sprite2D with particles in charge of moving), signal when it hits
			- [ ] Just need to await for it to finish
				- [ ] if there are multiple, it's slightly trickier. maybe we actually create a projectilesystem, which can manage multiple projectiles and signals when both are done? seems reasonable. it can keep a reference count
- [ ] **Gameplay Options - 1 week**
	- [ ] **Treasury of Atreus** - multiple options for what coins form the coinpool.
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
- [ ] **Polish & Balance - 4 weeks**
- [ ] **Tartarus Bonus Boss - 1 week**




**Post Launch Dreams**
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
- [ ] **Custom Seed**
	- [ ] Change RNG so that Trails/Boss/Charon, Shop, and coin RNG are all different.