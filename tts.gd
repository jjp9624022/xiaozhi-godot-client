extends Node
# One-time steps.
# Pick a voice. Here, we arbitrarily pick the first English voice.
var voices = DisplayServer.tts_get_voices_for_language("zh")
var voice_id = voices[0]
var long_message = "实验"
func _ready():
# Say "Hello, world!".
	#DisplayServer.tts_speak("你好",voice_id)

# Say a longer sentence, and then interrupt it.
# Note that this method is asynchronous: execution proceeds to the next line immediately,
# before the voice finishes speaking.

	#DisplayServer.tts_speak(long_message, voice_id)

# Immediately stop the current text mid-sentence and say goodbye instead.
	#DisplayServer.tts_stop()
	#DisplayServer.tts_speak("再见", voice_id)
	pass
func speek(msg:String):
	DisplayServer.tts_speak(msg,voice_id)
	
	
