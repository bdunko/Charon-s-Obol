- [ ] **Color Standardization**
	- [ ] Go through and find all instances of hardcoded colors and standardize them a bit more... Global should have a list of colors used by labels etc. Also make sure labels with hardcoded colors match these standard colors. 


- [ ] **Update Shader to work with Spritesheets**
	- [ ] Shader does not work with spritesheets which work across the entire sheet, notably we removed scanline from coins.
	- [ ] **Particles**
		- [ ] Extra
			- [ ] After a flip ends, play dust effect with EruptOutRing
			- [ ] Colored Trail on life fragments, souls, and coins. Enable/disable only when moving to save GPU power.
			- [ ] While a coin's power is active, sparkly glow on it...
			- [ ] Frozen coins have a constant sparkle effect.
			- [ ] Ignited coins have a constant smoke effect.