
- [ ] Improve prometheus indicator - make the text 'pop' in like the phase text
- [ ] Need some visual effect to denote passive
	- [ ] ideal - rotating pixel around edge, but we would need to do a lot of annoying handling for this; it is not generalizable. We would need to hand-make an animation for each possible coin shape that has a passive. This is doable but inconvenient, especially for trials. In this case, we may as well just make the trial coin size uniform. There isn't really a good reason for them to be differnet like they are now tbh.
- [ ] Patron token passives (Charon included) should do an additional animation or raise or jiggle or something when they trigger. I could see a slight rotation shake being effective for both this and for coin payoffs.
- [ ] can't activate demeter if no coins are showing a life penalty
- [ ] Permanent statuses should say so in their tooltip (OR, the icon should be different - possibly a different outline could work.)
	- [ ] Bury could also say the turns remaining in the tooltip.
- [ ] After hand slam during malice, hand should shake a bit.
- [ ] Need to clear tooltips when performing transitions, otherwise tooltips can get stuck on screen (try Embark -> hold mouse over difficulty skull)
- [ ] Different coin art for the elite monsters and nemesis monsters.
- [ ] Refactor - Colors as global references instead of interspersed all around
- [ ] Play with checkerboard full screen effect with light.
- [ ] Art - Since the NUMBER does not change on Artemis/Demeter/Hades upgrades, perhaps change the ICON to indicate the power is stronger as well? Just minor graphical effect such as fancy pixels around the edges n stuff; maybe multiple arrows for Artemis or whatever.
- [ ] FX - Lighting effects (experiment with)
- [ ] Code - Change text color if not original number on numbers in coin tooltip (light blue = modified)
- [ ] Graphics - Coin shadows
- [ ] Graphics - Skeletal hand shadows.
- [ ] Graphics - Shard shadows while they're moving.
- [ ] Graphics - Show purple bars (styx) on sides instead of black bars
- [ ] After you use a power, if you run out of charges, the targeted coin stays highlighted (it should stop being highlighted). So minor. Ex: Athena can do this.
- [ ] Icarus - include a warning indicator above (flashing exclaimiation point) if all coins are on heads. We can also add this for Achilles on tails.




- [ ] **Update Shader to work with Spritesheets**
	- [ ] Shader does not work with spritesheets which work across the entire sheet, notably we removed scanline from coins.

	- [ ] **Particles**
		- [ ] Extra
			- [ ] After a flip ends, play dust effect with EruptOutRing
			- [ ] Colored Trail on life fragments, souls, and coins. Enable/disable only when moving to save GPU power.
			- [ ] While a coin's power is active, sparkly glow on it...
			- [ ] Frozen coins have a constant sparkle effect.
			- [ ] Ignited coins have a constant smoke effect.
