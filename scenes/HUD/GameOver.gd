extends PopupDialog

var showing_new_highscore = false

func on_new_highscore(old, new):
	$HighScoreLabel.text = "New High Score!"
	$NewScoreLabel.text = "("+str(old)+" -> "+str(new)+")"
	$InfoFadeTimer.start(1)

func _on_InfoFadeTimer_timeout():
	if showing_new_highscore:
		$AnimationPlayer.play_backwards("GameOverInfoFade")
		$InfoFadeTimer.start(1)
	else:
		$AnimationPlayer.play("GameOverInfoFade")
		$InfoFadeTimer.start(2)
	showing_new_highscore = !showing_new_highscore
