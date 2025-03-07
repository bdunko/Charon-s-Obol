
- [ ] Tooltips on bottom should appear above coins; tooltips on top should appear below coins. Should be able to pass 'direction priority' to a tooltip. (priority_left/right, priority_up/down - this defines the default way the tooltip goes IF there is enough space for either.)

- [ ] **Performance improvements
	- [ ] Updated Godot engine version - should improve web performance.
	- [ ] Run the profiler for a run and look for any obvious fixes.

- [ ] Particle Global
	- [ ] Create autoload singleton Particles
	- [ ] Move the partcile scenes from inside coin to here. 
	- [ ] Allow requesting a oneshot particle given a texture for it.
		- [ ] then requester is in charge of adding it to scene at correct point

- [ ] **Additional Refactors**
	- [ ] Separate out Global.gd into multiple files.
		- [ ] VoyageInfo, Util, CoinInfo, PatronInfo, SaveLoad, EventBus
	- [ ] Cleanup game.gd so that functions are ordered better; try to reduce size.
	- [ ] Cleanup coin.gd in the same way.
	- [ ] Powers should have a lambda function they call. We may need to change how certain functions such as destroy_coin, downgrade_coin, and safe_flip function to make this feasible. (these should probably not exist in game.gd. Rather, they should be part of flip, destroy, and downgrade in coin. We may need to add signal emits to let game.gd react - ie coinrow may need to perform cleanup, track active flips, etc. Event bus is probably appropriate.)