###*
 * PSDのスマートオブジェクトをPNGに書き出し
 * version 1.0
 ###

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- # Global Settings #
# 単位をピクセルに
preferences.rulerUnits = Units.PIXELS;

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- # Global Variables #
originalWidth = 0
originalHeight = 0
currentWidth = 0
currentHeight = 0
offsetX = 0
offsetY = 0
saveFolder = null
nameCounter = 0
structures = []
fileNames = {} # ファイル名重複対策
fileNameCounter = 0 # ファイル名重複対策

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- # Utility #
# 数値処理拡張
Number::fillZero = (n) ->
  zeros = new Array n + 1 - @toString(10).length
  zeros.join('0') + @;

# ハッシュの出力用（再帰なし）
varDump = (obj) ->
	_rlt = []
	for own _key of obj
		try
			_val = obj[_key]
			unless _val instanceof Function then _rlt.push _key + ': ' + _val
		catch error
	alert _rlt.join '\n'
	# $window = new Window 'dialog', 'log', [200, 150, 1200, 650], resizable: true, closeButton: true
	# $window.add 'edittext', [0, 0, 1000, 500], _rlt.join '\n'
	# $window.show()

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- # Classes #
class ControlUI
	constructor: (@$window, @type, @width = 100, @height = 20, @left = 0, @top = 0, options = []) ->
		@window = @$window.window
		@context = @window.add.apply @window, [@type, [@left, @top, @width + @left, @height + @top]].concat options
	close: (value) ->
		@window.close value
	val: (getValue) ->
		switch @type
			when 'edittext', 'statictext'
				type = 'text'
			else
				type = 'value'
		if getValue?
			@context[type] = value = getValue.toString()
		else
			value = @context[type]
		value
	on: (event, callback) ->
		event = event.toLowerCase().replace(/^on/i, '').replace /^./, (character) ->
			character.toUpperCase()
		self = @
		@context['on' + event] = =>
			callback.apply self, arguments
		@

class WindowUI
	constructor: (@type, @name = 'ダイアログボックス', @width = 100, @height = 100, options, callback) ->
		@window = new Window @type, @name, [0, 0, @width, @height], options
		@window.center()
		@controls = []
		@onOK = ->
		@onCancel = ->
		BUTTON_WIDTH = 100
		BUTTON_HEIGHT = 20
		BUTTON_MARGIN = 10
		@addButton 'OK', BUTTON_WIDTH, BUTTON_HEIGHT, @width - BUTTON_WIDTH - BUTTON_MARGIN, @height - BUTTON_HEIGHT - BUTTON_MARGIN,
			click: ->
				@$window.onOK.apply @, arguments
		@addButton 'キャンセル', BUTTON_WIDTH, BUTTON_HEIGHT, @width - BUTTON_WIDTH - BUTTON_MARGIN - BUTTON_WIDTH - BUTTON_MARGIN, @height - BUTTON_HEIGHT - BUTTON_MARGIN,
			click: ->
				@$window.onCancel.apply @, arguments
				@close()
		stop = callback?.call @
		unless stop is false
			@show()
	close: (value) ->
		@window.close value
	show: ->
		@window.show()
		@
	hide: ->
		@window.hide()
		@
	center: ->
		@window.center()
		@
	addControl: (type, width, height, left, top, options, events) ->
		$ctrl = new ControlUI @, type, width, height, left, top, options
		if events?
			for own event, callback of events
				$ctrl.on event, callback
		@controls.push $ctrl
		$ctrl
	addTextbox: (width, height, left, top, defaultText = '', events) ->
		@addControl 'edittext', width, height, left, top, [defaultText], events
	addText: (text = '', width, height, left, top, events) ->
		@addControl 'statictext', width, height, left, top, [text], events
	addButton: (label, width, height, left, top, events) ->
		@addControl 'button', width, height, left, top, [label], events
	addRadio: (label, width, height, left, top, events) ->
		@addControl 'radiobutton', width, height, left, top, [label], events
	addCheckbox: (label, width, height, left, top, events) ->
		@addControl 'checkbox', width, height, left, top, [label], events
	ok: (callback = ->) ->
		@onOK = callback
		@
	cancel: (callback = ->) ->
		@onCancel = callback
		@

class DialogUI extends WindowUI
	constructor: (@name, @width, @height, options, callback) ->
		super 'dialog', @name, @width, @height, options, callback

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- # Functions #
getLayerPath = (layer) ->
	path = []
	getLayerName = (layer) ->
		path.push layer.name
		if layer.parent
			getLayerName layer.parent
		return
	getLayerName layer
	path.shift()
	path.pop()
	path.pop()
	path.reverse()
	encodeURI '/' + path.join '/'

# 保存
saveJPEG = (fileName, folder = '~', quality = 12) ->
	newFile = new File folder + '/' + fileName
	jpegOpt = new JPEGSaveOptions()
	jpegOpt.embedColorProfile = false
	jpegOpt.quality = quality
	jpegOpt.formatOptions = FormatOptions.OPTIMIZEDBASELINE
	jpegOpt.scans = 3
	jpegOpt.matte = MatteType.NONE
	activeDocument.saveAs newFile, jpegOpt, true, Extension.LOWERCASE
	return

savePNG = (fileName, dir = '') ->
	exp = new ExportOptionsSaveForWeb
	exp.format = SaveDocumentType.PNG
	exp.interlaced = off
	exp.PNG8 = off
	folder = new Folder saveFolder + dir + '/'
	unless folder.exists
		folder.create()
	filePath = folder + '/' + fileName + '.png'
	file = new File filePath
	activeDocument.exportDocument file, ExportType.SAVEFORWEB, exp
	return file.getRelativeURI saveFolder

# 閉じる
close = (showDialog = false) ->
	if showDialog
		unless confirm '閉じてよろしいですか?'
			return
	activeDocument.close(SaveOptions.DONOTSAVECHANGES);
	return

getBounds = (layer) ->
	bounds = layer.bounds
	return {
		x: parseInt bounds[0], 10
		y: parseInt bounds[1], 10
		x2: parseInt bounds[2], 10
		y2: parseInt bounds[3], 10
	}

enlargeForSelect = (layer) ->
	bounds = getBounds layer
	if bounds.x < 0
		currentWidth -= bounds.x
		offsetX += bounds.x
		activeDocument.resizeCanvas currentWidth, currentHeight, AnchorPosition.TOPRIGHT
	if bounds.y < 0
		currentHeight -= bounds.y
		offsetY += bounds.y
		activeDocument.resizeCanvas currentWidth, currentHeight, AnchorPosition.BOTTOMLEFT
	if bounds.x2 > currentWidth + offsetX
		currentWidth += bounds.x2 + offsetX
		activeDocument.resizeCanvas currentWidth, currentHeight, AnchorPosition.TOPLEFT
	if bounds.y2 > currentHeight + offsetY
		currentHeight += bounds.y2 + offsetY
		activeDocument.resizeCanvas currentWidth, currentHeight, AnchorPosition.TOPLEFT
	return getBounds layer

restoreDimension = ->
	activeDocument.resizeCanvas originalWidth - offsetX, originalHeight - offsetY, AnchorPosition.TOPLEFT
	activeDocument.resizeCanvas originalWidth, originalHeight, AnchorPosition.BOTTOMRIGHT

select = (layer) ->
	bounds = enlargeForSelect layer
	activeDocument.selection.select [
		[bounds.x,  bounds.y]
		[bounds.x2, bounds.y]
		[bounds.x2, bounds.y2]
		[bounds.x,  bounds.y2]
	]
	return

copy = (layer) ->
	activeDocument.activeLayer = layer
	activeDocument.selection.copy()
	activeDocument.selection.deselect()
	return

paste = (doc) ->
	doc.paste()
	return

getMetrics = (layer) ->
	bounds = getBounds layer
	return {
		x: bounds.x + offsetX
		y: bounds.y + offsetY
		width: bounds.x2 - bounds.x
		height: bounds.y2 - bounds.y
	}

createDocument = (width, height, name) ->
	return documents.add(width, height, 72, name, NewDocumentMode.RGB, DocumentFill.TRANSPARENT);

outputCSS = (structures) ->
	structures.reverse()

	outputText = []
	for layer, i in structures
		z = 10000 - i * 10
		text =
			"""
			.#{layer.name} \{
				position: absolute;
				top: #{layer.y}px;
				left: #{layer.x}px;
				z-index: #{z};
				width: #{layer.width}px;
				height: #{layer.height}px;
				background: url(#{layer.url}) no-repeat scroll 0 0;
			\}
			"""
		outputText.push text
	outputFile = new File saveFolder + '/' + 'style.css'
	outputFile.open 'w'
	outputFile.encoding = 'utf-8'
	outputFile.write outputText.join '\n'
	outputFile.close()

	outputText = []
	for layer, i in structures
		text =
			"""
				<div class="#{layer.name}"></div>
			"""
		outputText.push text
	html =
		"""
		<!doctype html>
		<html>
		<head>
			<meta charset="utf-8">
			<link rel="stylesheet" href="style.css">
		$
		</haed>
		<body>
		</body>
		</html>
		"""
	outputFile = new File saveFolder + '/' + 'index.html'
	outputFile.open 'w'
	outputFile.encoding = 'utf-8'
	outputFile.write html.replace '$', outputText.join '\n'
	outputFile.close()
	return

outputLESS = (structures) ->
	alert 'LESSはまだつくってない'

outputJSON = (structures) ->
	structures.reverse()

	outputText = []
	for layer, i in structures
		z = 10000 - i * 10
		text =
			"""
			\{
				"name": "#{layer.name}",
				"className": "#{layer.name}",
				"x": #{layer.x},
				"y": #{layer.y},
				"z": #{z},
				"width": #{layer.width},
				"height": #{layer.height},
				"url": "#{layer.url}"
			\}
			"""
		outputText.push text
	outputFile = new File saveFolder + '/' + 'structures.json'
	outputFile.open 'w'
	outputFile.encoding = 'utf-8'
	outputFile.write '[' + outputText.join(',\n') + ']'
	outputFile.close()

	vars = []
	for layer, i in structures
		vars.push "$#{layer.name} = $('<div class=\"#{layer.name}\">')"
	outputFile = new File saveFolder + '/' + 'structures.js'
	outputFile.open 'w'
	outputFile.encoding = 'utf-8'
	outputFile.write ';(function ($) {\n\nvar\n' + vars.join(',\n') + ';\n}(this.jQuery));'
	outputFile.close()

# 抽出
extract = (layer) ->
	# 自分以外を隠す
	parent = layer.parent
	if parent
		for sub, i in parent.layers
			sub._v = sub.visible
			sub.visible = off
	layer.visible = on

	name = layer.name.replace(/^[^a-z_-]/i, 'image').replace /[^0-9a-z_-]/gi, ''
	if name is 'image' then name = 'image_' + nameCounter++
	if fileNames[name]
		name += fileNameCounter++
	fileNames[name] = on

	select layer
	copy layer

	metrics = getMetrics layer

	newDoc = createDocument metrics.width, metrics.height, layer.name

	paste newDoc

	dir = getLayerPath layer

	url = savePNG name, dir

	newDoc.close SaveOptions.DONOTSAVECHANGES

	data = metrics
	data.name = name
	data.url = url

	structures.push data

	# 表示状態を元に戻す
	parent = layer.parent
	if parent
		for sub, i in parent.layers
			sub.visible = sub._v
	return

# アウトプット
output = (layers) ->
	for layer, i in layers
		if layer.typename is 'LayerSet'
			output layer.layers
		else
			# スマートオブジェクトであり、且つ表示状態であれば抽出する
			if layer.visible and layer.kind is LayerKind.SMARTOBJECT
				extract layer
	return


action = (typeFlag, saveFolderPath = '~/') ->
	originalWidth = activeDocument.width
	originalHeight = activeDocument.height
	currentWidth = originalWidth
	currentHeight = originalHeight

	saveFolder = new Folder saveFolderPath

	layers = activeDocument.layers

	output layers

	restoreDimension()

	FLAG_CSS = 1
	FLAG_LESS = 2
	FLAG_JQUERY = 4

	if typeFlag & FLAG_CSS
		outputCSS structures

	if typeFlag & FLAG_LESS
		outputLESS structures

	if typeFlag & FLAG_JQUERY
		outputJSON structures

	return



# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- # Show Dialog #
$dialog = new DialogUI 'PSD to PNG', 700, 400, null, ->
	@addText '書き出しフォルダ', 120, 20, 10, 50
	$saveFolder = @addTextbox 540, 20, 60, 70
	@addButton '選択', 80, 20, 610, 70,
		click: ->
			saveFolder = Folder.selectDialog '保存先のフォルダを選択してください'
			$saveFolder.val decodeURI saveFolder.getRelativeURI '/'
	@addText '書き出し形式', 120, 20, 10, 160
	$types = []
	$types.push @addCheckbox 'HTML&CSS', 220, 20, 10, 190
	$types.push @addCheckbox 'LESS', 220, 20, 230, 190
	$types.push @addCheckbox 'jQuery', 220, 20, 450, 190
	@ok ->
		saveFolderPath = encodeURI $saveFolder.val()
		typeFlag = 0
		for $type, i in $types
			if $type.val()
				typeFlag += Math.pow 2, i
		@close()
		action typeFlag, saveFolderPath




