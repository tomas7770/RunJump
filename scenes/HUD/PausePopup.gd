extends PopupDialog

enum PAUSEINFO {DIFFICULTY, HIGHSCORE}
var current_pause_info = PAUSEINFO.DIFFICULTY

func on_open():
	$InfoFadeTimer.start()
	
func on_close():
	$InfoFadeTimer.stop()

func _on_InfoFadeTimer_timeout():
	match current_pause_info:
		PAUSEINFO.DIFFICULTY:
			$AnimationPlayer.play("PauseInfoFade")
			current_pause_info = PAUSEINFO.HIGHSCORE
		PAUSEINFO.HIGHSCORE:
			$AnimationPlayer.play_backwards("PauseInfoFade")
			current_pause_info = PAUSEINFO.DIFFICULTY

func _on_LabelSwitchButton_pressed():
	$InfoFadeTimer.stop()
	_on_InfoFadeTimer_timeout()
