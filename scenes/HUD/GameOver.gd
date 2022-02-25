extends PopupDialog

var showing_new_highscore = false

func on_new_highscore(old, new):
	$HighScoreLabel.text = "New High Score!"
	$NewScoreLabel.text = "("+str(old)+" -> "+str(new)+")"
	$HighScoreLabel.modulate = Color(0xffbf00ff)
	$InfoFadeTimer.start(2)
	$LabelSwitchButton.visible = true

func _on_InfoFadeTimer_timeout(do_restart = true):
	if showing_new_highscore:
		$AnimationPlayer.play_backwards("GameOverInfoFade")
		if do_restart:
			$InfoFadeTimer.start(2)
	else:
		$AnimationPlayer.play("GameOverInfoFade")
		if do_restart:
			$InfoFadeTimer.start(3)
	showing_new_highscore = !showing_new_highscore

func _on_LabelSwitchButton_pressed():
	$InfoFadeTimer.stop()
	_on_InfoFadeTimer_timeout(false)
