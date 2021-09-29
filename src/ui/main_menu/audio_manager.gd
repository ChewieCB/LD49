extends AudioStreamPlayer

export (Resource) var cursor_sfx
export (Resource) var confirm_sfx
export (Resource) var cancel_sfx


func cursor():
	self.stream = cursor_sfx
	play()


func confirm():
	self.stream = confirm_sfx
	play()


func cancel():
	self.stream = cancel_sfx
	play()

