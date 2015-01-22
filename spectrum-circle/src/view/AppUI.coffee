class AppUI

	view 					: null
	audio 					: null

	numSticks				: null
	stickSize				: null
	iniBin 					: null
	endBin 					: null
	mute 					: false

	drawBarChart 			: false


	constructor: ->
		@view = app.view
		@audio = app.audio

		@numSticks = 150
		@stickSize = 40
		@iniBin = 30
		@endBin = @iniBin + @numSticks

		@initGUI()
		@initBarChart()


	initGUI: ->
		gui = new dat.GUI()
		gui.open()
		that = @

		f4 = gui.addFolder('Audio')
		f4.open()
		f4.add(@, 'numSticks', 0, 360).step(1)
		f4.add(@, 'stickSize', 0, 200).step(1)
		f4.add(@, 'iniBin', 0, @audio.BINS).step(1)
		f4.add(@, 'endBin', 0, @audio.BINS).step(1)
		f4.add(@, 'mute').onChange(-> that.onMuteChange())

		f6 = gui.addFolder('Debug')
		f6.open()
		f6.add(@, 'drawBarChart')


	initBarChart: =>
		@barChart = new BarChartView(@view.sketch)


	onMuteChange: ->
		if (@mute) then	@audio.analyserNode.disconnect()
		else @audio.analyserNode.connect(@audio.ctx.destination)


	# ---------------------------------------------------------------------------------------------
	# PUBLIC
	# ---------------------------------------------------------------------------------------------

	update: ->
		@barChart.update(@audio.values, @iniBin, @endBin)

		return


	draw: ->
		# @view.sketch.clearRect(0, 0, @view.sketch.width, @view.sketch.height)
		if (@drawBarChart) then @barChart.draw()

		return