**Charon's Obol v0.3 - Myths and Monsters**
- [ ] **Current Goals - Jan 19th Sprint b0.1.0**
	- [ ] **Goals**
		- [ ] **Saturday - Sunday: Graphical Improvements**
			- [ ] **Saturday**
				- [ ] **Particles**
					- [ ] Create particle types
						- [ ] EruptOutPoint - Particle moves rapidly outward from a point
						- [ ] EruptOutRing - Particle moves rapidly outward from a ring.
							- [ ] Used for dust on coin flips.
						- [ ] Windy - Particles fly from a certain direction constantly across the screen.
							- [ ] Used both on main menu and game.
						- [ ] AmbientAir - Particles fade in/out periodically across a large area.
							- [ ] Used when a power is active (color depends on power)
						- [ ] PulledIn - Particles start widely from a line and move towards a central point
							- [ ] Used for death animation
						- [ ] Trail - Just a steady stream of particles. attach to a moving object.
							- [ ] Used for coin flips, souls, lives.
						- [ ] IconGrow - An icon starts at a point, rapidly scales up and fades.
							- [ ] Used for powers
						- [ ] IconShrink - An icon starts at a point, rapidly scales down and fades.
					- [ ] Initial particle additions.
						- [ ] Particles coming off of an activated coin.
						- [ ] Ambient particles on main menu and game.
						- [ ] Particle effect across the entire screen while a power is active.
			- [ ] **Sunday**
				- [ ] Filters for the patron selection and main scenes.
					- [ ] Heavy checker/purple filter on main menu should not include UI elements (tooltips and textboxes). Need to move inside the scenes instead of on main on top of everything.
				- [ ] Coins with activatable powers should glow solid when hovered. Patron token also. Remove tinting if we do this.
				- [ ] **Unlock Improvements**
					- [ ] Transitions between unlocks. Transitions between unlock ending and main menu
					- [ ] Add an additional space for 'advice' with each coin unlocked and character.
						- [ ] Apollo - explain curse and bless.
						- [ ] Artemis - explain arrows.
						- [ ] Hephaestus - explain ignite.
						- [ ] Eleusianian - "Now, let the real game begin..."
	- [ ] **Etc**
		- [ ] Needs an Abandon Run button somewhere. 
			- [ ] Add an X somewhere on the board on the top right.
			- [ ] When clicked, open a popup window with abandon run. In the future, we will also put settings here probably.
			- [ ] Also triggered on esc
			- [ ] maybe can steal this implementation from MonScript (script editor definitely had a popup thingy)
		- [ ] Map should use icons from trials and boss instead of just generic T and purple skull. Also would be nice to fit in a special 'miniboss' round for the first time an Elite spawns.




**Fruits**
- [ ] Choose coins to add to update.
- [ ] Choose bosses to add to update.
- [ ] Choose monsters to add to update.
- [ ] Choose characters to add to update.
	- [ ] The Archon
	- [ ] The Merchant
	- [ ] The Gardener
	- [ ] The Sickly
	- [ ] The Hoplite
	- [ ] The Idealist

**Charon's Obol Beta - Coalescence**
- [ ] **Patron Revamp - Jan 19th**
- [ ] **Difficulty levels - Feb 2nd**
	- [ ] Charon will unleash his Malice.
	- [ ] Trials have 2 modifiers.  Tollgates are more expensive.
	- [ ] Monsters are stronger. The Nemesis is more powerful.
	- [ ] (infinite scaling) 5% more likely to land on tails (configurable with arrows; max increases by 2% on victory.)
- [ ] **Charon's Malice - Feb 2nd**
	- [ ] Hands hovering over board.
	- [ ] Activates on a cycle every so foten.
	- [ ] Graphical effects (glowing hands etc) to
	- [ ] **Malice Effects**
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
- [ ] **Coin Graphical Effects - Feb 16th**
- [ ] **Increase Coin Limit & Other Refactors Feb 23rd**
	- [ ] **Coin Limit Increase**
		- [ ] Goal - 10 coins.
			- [ ] Coins need to cap at diobol size. 
			- [ ] Think of different ways to denote coins besides size - or experiment with sizes between obol and diobol. 
				- [ ] Obol - keep
				- [ ] Diobol - 1 larger on bottom?
				- [ ] Triobol - replace with current diobol
				- [ ] Tetrobol - triobol 1 larger on bottom?
		- [ ] Status row probably caps at ~3. Move it closer to new shrunken coin. 
		- [ ] Move price label down as well to make more space.
		- [ ] Move shop, enemy row, and hands down with extra space.
		- [ ] Look for anywhere we hardcoded the coin limit at 8 and fix that.
		- [ ] Possibly remove a few pixels from the cloth playmat.
		- [ ] Clean up coinrow code some too, it's terrible right now (the coin positioning that is, the math is not very well done - let's redo the calcs)
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
- [ ] **More Content - Mar 16th**
	- [ ] **New bosses**
	- [ ] **More Monsters**
	- [ ] **More Coins**
	- [ ] **More Characters**
	- [ ] **Steady Unlocks** + **Unlocks for each character & nemesis**
- [ ] **Basic Sound - March 30th**


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
	- [ ] Predestined - Absolutely no coins that reflip, focus on lucky/bless etc
	- [ ] Fundamental - Absolutely no coins with Statuses.
	- [ ] Oracle's Choice - randomized pool of 25 coins, changing daily.
	- [ ] Charon's Choice - randomized pool of 25 coins, changes each time you choose it.






https://en.wikipedia.org/wiki/Apega_of_Nabis
https://en.wikipedia.org/wiki/Macaria

---
**Expanded - Characters, Coins, Difficulties, Unlocks**
- [ ] Charon dialogue implementation
	- [ ] Malice
		- [ ] Basically a counter which increments when Charon is mad, once it peaks, do a negative thing and reset the counter.
		- [ ] Increases whenever you...
			- [ ] Land heads from a toss flip.
			- [ ] Trigger a god power
			- [ ] Payoff a coin on heads
		- [ ] Decreases...
			- [ ] At the end of the round (to 50%?)
			- [ ] After Charon triggers.
		- [ ] Visible graphical effects to imply when Charon is getting angry - flames, particles, darkening screen, etc...
		- [ ] The visual graphical effects imply what negative thing he is going to do.
			- [ ] First indication at 50%.
			- [ ] Becomes more fierce at 70%.
			- [ ] Becomes more fierce at 90%
		- [ ] At the start of each run, Charon rolls a set rotation of 3 abilities which he performs in order.
		- [ ] Ending a toss reduces Malice somewhat and moves to the next ability.
		- [ ] Ending a round reduces Malice to 0 and moves to the next ability.
		- [ ] After an ability activates, Charon's Malice is reduced to 0.
		- [ ] After each Trial, Charon adds a new ability to the rotation in a random position.
		- [ ] Bad things:
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
		- [ ] Separately, and possibly as a different difficulty modifier, Charon may choose to summon monsters from a small pool rolled at the start of each run at the start of any given round. 
- [ ] Add custom seed option in main menu eventually
- [ ] Change RNG so that Trails/Boss/Charon, Shop, and coin RNG are all different.

