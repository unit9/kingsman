class SpectrumCircle

	ctx 					: null

	values 					: null
	bins 					: null
	radius 					: null
	stickSize 				: null
	numSticks				: null
	color 					: null


	constructor: (@ctx, @color = '#fff', @radius = 200) ->


	update: (@values, @bins) ->

		return


	draw: ->
		@ctx.beginPath()

		a = TWO_PI / @numSticks

		for i in [0...@numSticks]
			v = MathUtils.map(i, 0, @numSticks, 0, @bins, true)
			# value = if (i < @numSticks / 2) then @values[i] else @values[@numSticks - i]
			value = if (v < @bins / 2) then @values[v] else @values[@bins - v]
			if (!value) then value = 0
			angle = a * i - HALF_PI
			stick = @stickSize * value + 2

			x = cos(angle) * (@radius - stick)
			y = sin(angle) * (@radius - stick)
			@ctx.moveTo(x, y)
			x = cos(angle) * (@radius + stick)
			y = sin(angle) * (@radius + stick)
			@ctx.lineTo(x, y)

		@ctx.strokeStyle = @color
		@ctx.stroke()

		return