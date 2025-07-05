**Audio Export Process**
From Ableton - Export each individual track. Length should be size of longest track (don't forget to account for reverb tail!)
We now need to trim away the silence at the end of each .wav file.
In Audacity, File -> Import Audio. Multi-select all .wav files.
Select all of them. Effect -> Special -> Truncate Silence.
Change the Truncate to length to a short value (0.1s) and apply.
Now we need to export the modified files.
Export Audio. Tick Multiple Files. Tick Overwrite existing files. Press export.

**Click at Start of Loop in Godot but not Ableton**
Most likely, one of the clips is ending on a non-zero crossing. Add very slight fades to the end of every clip to fix this.
If it feels like there is a sudden start/stop, the fade is too long. You can make the fade really quite short - the goal is just to remove the zero crossing. Additionally, you can shape the fade so it isn't linear to make it 'sharper' - then you don't need to make it very long at all. 