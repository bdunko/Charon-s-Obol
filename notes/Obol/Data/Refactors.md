- [ ] Will need to add an indestructible tag to coins and check that in some coin powers. (maybe?)
	- [ ] Better long term solution - powers should specify the possible 'targets' from a list of enums; ie "OwnCoins", "Auto", "EnemyCoins", "AllCoins". Then instead of each case in the match having to check if that power is targetting correctly, we can just check at the start. 
- [ ] Tooltips on bottom should appear above coins; tooltips on top should appear below coins. Should be able to pass 'direction priority' to a tooltip. (priority_left/right, priority_up/down - this defines the default way the tooltip goes IF there is enough space for either.)
- [ ] We should handle LIFE_LOSS powers better - instead of the current, weird array solution, coins should have an additional PAYOFF_POWER field which may be null or may be an enum.
	- [ ] PAYOFF_POWER should be used for life loss, soul gain, soul loss, monster effects, etc.
	- [ ] PAYOFF_POWER is checked in the big switch statement to determine what to do.

- [ ] **Performance improvements
	- [ ] Updated Godot engine version - should improve web performance.
	- [ ] Run the profiler for a run and look for any obvious fixes.