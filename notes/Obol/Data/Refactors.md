- [ ] Scrolls of Knowledge - an optional rule review + tips that unlocks on the main menu after the tutorial.
- [ ] Tooltips on bottom should appear above coins; tooltips on top should appear below coins. Should be able to pass 'direction priority' to a tooltip. (priority_left/right, priority_up/down - this defines the default way the tooltip goes IF there is enough space for either.)

- [ ] **Performance improvements
	- [ ] Updated Godot engine version - should improve web performance.
	- [ ] Run the profiler for a run and look for any obvious fixes.

- [ ] **Coin Power Refactor**
	- [ ] Each power should specify a TargetType enum. "OwnCoins" "Auto" "EnemyCoins" "AnyCoin" "PayoffGainSouls" "PayoffLoseLife. 
		- [ ] If "Auto", that's how we know not to prompt for a target and to immediately activate
		- [ ] The Payoff powers are used to determine if/how this coin resolves during payoff. Ie each lose life power would use PayoffLoseLife, but with a different charge count.
		- [ ] Each Soul payoff coin could use PayoffGainSouls and automatically update its charges as required.