- [ ] Scrolls of Knowledge - an optional rule review + tips that unlocks on the main menu after the tutorial.
- [ ] Tooltips on bottom should appear above coins; tooltips on top should appear below coins. Should be able to pass 'direction priority' to a tooltip. (priority_left/right, priority_up/down - this defines the default way the tooltip goes IF there is enough space for either.)

- [ ] **Performance improvements
	- [ ] Updated Godot engine version - should improve web performance.
	- [ ] Run the profiler for a run and look for any obvious fixes.

- [ ] Particle Global
	- [ ] Create autoload singleton Particles
	- [ ] Move the partcile scenes from inside coin to here. 
	- [ ] Allow requesting a oneshot particle given a texture for it.
		- [ ] then requester is in charge of adding it to scene at correct point