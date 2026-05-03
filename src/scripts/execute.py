"""
Execute DAT

me - this DAT

Make sure the corresponding toggle is enabled in the Execute DAT.
"""

def onStart():
	"""
	Called when the project starts.
	"""
	events_table = op('osc/EVENTS')
	events_table.clear()
	events_table.appendRow(['cycle', 'cps', 'instrument', 'wBegin', 'wDur', 'pBegin', 'pDur', 'pitch'])

	# Register randomisation targets (execute1 is inside osc comp, randomise is in parent)
	r = op('randomise').module
	r.clear()
	r.register('tile1', 'cropright', low=0, high=10, every_n=4, discrete=True)
	r.register('tile1', 'croptop', low=0, high=10, every_n=4, discrete=True)
	# r.register('tile1', 'repeatx', low=1, high=2, every_n=2, discrete=True)
	# r.register('tile1', 'repeaty', low=1, high=2, every_n=2, discrete=True)
	r.register('tile1', 'flop', low=0, high=1, every_n=3, discrete=True)
	r.register('tile1', 'flipx', low=0, high=1, every_n=3, discrete=True)
	r.register('tile1', 'flipy', low=0, high=1, every_n=3, discrete=True)
	r.register('tile1', 'reflectx', low=0, high=1, every_n=7, discrete=True)
	r.register('tile1', 'reflecty', low=0, high=1, every_n=4, discrete=True)
	r.register('tile1', 'extend', choices=['repeat', 'mirror', 'hold'], every_n=4)
	return

def onCreate():
	"""
	Called when the DAT is created.
	"""
	return

def onExit():
	"""
	Called when the project exits.
	"""
	return

def onFrameStart(frame: int):
	"""
	Called at the start of each frame.
	
	Args:
		frame: The current frame number
	"""
	return

def onFrameEnd(frame: int):
	"""
	Called at the end of each frame.
	
	Args:
		frame: The current frame number
	"""
	return

def onPlayStateChange(state: bool):
	"""
	Called when the play state changes.
	
	Args:
		state: False if the timeline was just paused
	"""
	return

def onDeviceChange():
	"""
	Called when a device change occurs.
	"""
	return

def onProjectPreSave():
	"""
	Called before the project is saved.
	"""
	return

def onProjectPostSave():
	"""
	Called after the project is saved.
	"""
	return
