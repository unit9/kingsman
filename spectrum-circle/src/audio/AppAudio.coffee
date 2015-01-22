class AppAudio

	ctx 					: null
	loaded					: null
	paused					: true
	ended					: null

	startedAt				: null
	pausedAt				: null

	name 	 				: null
	duration 				: null
	currentTime 			: null
	playbackRate 			: 1
	isDefaultFile 			: false

	sourceNode				: null
	analyserNode			: null
	buffer 					: null

	values					: null

	FFT_SIZE				: 1024
	BINS					: 256

	@EVENT_AUDIO_ENDED 		: 'audioEnded'
	@EVENT_AUDIO_RESTARTED	: 'audioRestarted'


	init: ->
		@ctx = new AudioContext()

		@values = []
		@duration = @currentTime = 0

		@analyserNode = @ctx.createAnalyser()
		@analyserNode.smoothingTimeConstant = 0.6
		@analyserNode.fftSize = @FFT_SIZE
		@analyserNode.connect(@ctx.destination) # comment out to start mute

		# @load('sound/46905__alphahog__dyquestt.mp3')
		# @load('sound/242930__obxjohn__child-laughing.mp3')
		# @load('sound/47467__alphahog__purena-underwear.mp3')
		# @load('sound/111266__rebelspirit__metal-bass-phrase-1.mp3')
		@load('sound/intro_colin.mp3')
		

	update: ->
		if (@ended) then return

		freqData = new Uint8Array(@analyserNode.frequencyBinCount)
		@analyserNode.getByteFrequencyData(freqData)
		length = freqData.length

		bin = Math.ceil(length / @BINS)
		for i in [0...@BINS]
			sum = 0
			for j in [0...bin]
				sum += freqData[(i * bin) + j]

			# Calculate the average frequency of the samples in the bin
			average = sum / bin

			# Divide by 256 to normalize
			@values[i] = ((average / 256) / @playbackRate).toPrecision(2) / 1

		# set current time
		if (@loaded && !@ended) 
			@currentTime = if (@paused) then @pausedAt else Date.now() - @startedAt
			@currentTime *= @playbackRate

		return

		
	load: (url) ->
		request = new XMLHttpRequest()
		request.open('GET', url, true)
		request.responseType = 'arraybuffer'
		request.onprogress = @onRequestProgress
		request.onload = @onRequestLoad
		request.send()


	play: ->
		if (@ended) then window.dispatchEvent(new Event(AppAudio.EVENT_AUDIO_RESTARTED))

		@sourceNode = @ctx.createBufferSource()
		@sourceNode.onended = @onSourceEnded
		@sourceNode.connect(@analyserNode)
		@sourceNode.playbackRate.value = @playbackRate
		@sourceNode.buffer = @buffer
		# @sourceNode.loop = @isDefaultFile
		@ended = false
		@paused = false

		if (@pausedAt)
			@startedAt = Date.now() - @pausedAt
			@sourceNode.start(0, @pausedAt / 1000)
		else
			@startedAt = Date.now()
			@sourceNode.start(0)


	stop: ->
		if (!@sourceNode) then return
		@sourceNode.stop(0)
		@pausedAt = Date.now() - @startedAt
		@paused = true


	seek: (time) ->
		if (time == undefined) then return
		if (time > @buffer.duration) then return

		@ended = false

		if (!@paused)
			@sourceNode.onended = null
			@sourceNode.stop(0)
		@pausedAt = time * 1000
		if (!@paused) then @play()



	onRequestProgress: (e) =>
		# console.log('AppAudio.onRequestProgress', e, app.view.ui)

		return


	onRequestLoad: (e) =>
		# console.log('AppAudio.onRequestLoad', e)
		@isDefaultFile = true
		@ctx.decodeAudioData(e.target.response, @onBufferLoaded, @onBufferError)

		return


	onFileDrop: (file) =>
		if (@buffer)
			@sourceNode.stop(0)
			@buffer = null

		@isDefaultFile = false
		@ctx.decodeAudioData(file, @onBufferLoaded, @onBufferError)
		document.getElementById('feedback').innerText = 'decoding...'

		return


	onBufferLoaded: (@buffer) =>
		@loaded = true
		@duration = @buffer.duration * 1000 * @playbackRate
		@play()
		if (@name) then document.getElementById('feedback').innerText = @name + ' loaded'


	onBufferError: (e) ->
		# console.log('AppAudio.onBufferError', e)


	onSourceEnded: (e) =>
		# console.log('AppAudio.onSourceEnded', @paused)
		if (@paused) then return

		@currentTime = @duration
		@ended = true
		@paused = true
		@pausedAt = 0

		window.dispatchEvent(new Event(AppAudio.EVENT_AUDIO_ENDED))