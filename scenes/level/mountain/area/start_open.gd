extends BaseNode2D

func start() -> void:
	super.start()
	$YellowArrow.reset()
	$YellowArrow.start()
	
	$YellowArrow2.reset()
	$YellowArrow2.start()
	
	$YellowArrow3.reset()
	$YellowArrow3.start()
	
	$ExplodingBarrel.reset()
	$ExplodingBarrel.start()

func stop() -> void:
	super.stop()
	$YellowArrow.stop()
	$YellowArrow2.stop()
	$YellowArrow3.stop()
	$ExplodingBarrel.stop()
