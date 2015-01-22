class AppView

	audio					: null
	sketch 					: null
	ui 						: null

	down					: false
	playbackFrame			: null

	circleRecord 			: null


	init: ->
		@audio = app.audio
		@initSketch()


	initSketch: =>
		@sketch = Sketch.create
			type			: Sketch.CANVAS
			container 		: document.getElementById('container')
			retina 			: (window.devicePixelRatio >= 2)
			# interval 		: 3


		@sketch.setup = =>
			@initUI()
			@initSpectrumCircles()


		@sketch.update = =>
			@audio.update()
			@ui.update()

			values = @audio.values.slice(@ui.iniBin, @ui.endBin)

			@circleRecord.update(values, @ui.endBin - @ui.iniBin)
			@circleRecord.numSticks = @ui.numSticks
			@circleRecord.stickSize = @ui.stickSize

			return
			

		@sketch.draw = =>
			@ui.draw()

			# record
			@sketch.save()
			@sketch.translate(@sketch.width * 0.5, @sketch.height * 0.4)
			@circleRecord.draw()
			@sketch.restore()

			return


		@sketch.resize = =>
			return


		@sketch.touchstart = =>
			@down = true

			return


		@sketch.touchmove = =>
			if (!@down) then return

			return


		@sketch.touchend = =>
			@down = false

			return


		@sketch.keyup = (e) =>
			# space
			if (e.keyCode == 32)
				if (!@audio.paused) 
					@audio.stop()
				else
					@audio.play()

			return


	initUI: =>
		@ui = new AppUI()

		return


	initSpectrumCircles: =>
		@circleRecord = new SpectrumCircle(@sketch, '#fff')

		return