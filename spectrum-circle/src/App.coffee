#<< audio/*
#<< view/*

window.app = 
	view 			: null
	audio			: null


	init: ->
		app.initAudio()
		app.initView()

		app.audio.init()
		app.view.init()


	initAudio: ->
		app.audio = new AppAudio()


	initView: ->
		app.view = new AppView()
		

window.onload = ->
	if (window.FileReader)
		cancel = (e) ->
			if (e.preventDefault) then e.preventDefault()
			return false

		drop = (e) ->
			if (e.preventDefault) then e.preventDefault()

			files = e.dataTransfer.files
			for i in [0...files.length]
				file = files[i]
				reader = new FileReader()

				# console.log('FileReader drop', file.name, file.type)
				isAudio = file.type.indexOf('audio') == 0

				reader.onloadend = (e) ->
					# console.log('FileReader reader.onloadend', e)
	
					if (isAudio) 
						app.audio.name = file.name
						app.audio.onFileDrop(e.target.result)
					else
						console.log('not an audio file')

				if (isAudio) then reader.readAsArrayBuffer(file)

			return false

		container = document.getElementById('container')
		container.ondragover = cancel
		container.ondragenter = cancel
		container.ondrop = drop



do app.init