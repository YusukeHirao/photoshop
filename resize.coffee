###*
 * リサイズ&トリミング
 * version 1.3
 ###

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- # Global Settings #
# 単位をピクセルに
preferences.rulerUnits = Units.PIXELS;

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
		BUTTON_WIDTH = 75
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
resize = (width, height, trim, fill) ->
	# 元の幅と高さ
	originWidth = activeDocument.width.value
	originHeight = activeDocument.height.value
	# 元の縦横比(高さ÷幅)
	originRatio = originHeight / originWidth
	# 指定の縦横比(高さ÷幅)
	ratio = height / width
	if trim
		resizeWidth = width
		resizeHeight = height
		if originWidth > originHeight
			trimWidth = originHeight / ratio
			trimHeight = originHeight
		else
			trimWidth = originWidth
			trimHeight = originWidth * ratio
		activeDocument.resizeCanvas trimWidth, trimHeight, AnchorPosition.MIDDLECENTER
	else
		if fill
			resizeWidth = width
			resizeHeight = height
			trimWidth = originWidth
			trimHeight = originWidth * ratio
			activeDocument.resizeCanvas trimWidth, trimHeight, AnchorPosition.MIDDLECENTER
		else
			if width > height
				resizeWidth = height / originRatio
				resizeHeight = height
				if resizeWidth > width
					resizeWidth = width
					resizeHeight = width * originRatio
			else
				resizeWidth = width
				resizeHeight = width * originRatio
				if resizeHeight > height
					resizeWidth = height / originRatio
					resizeHeight = height
	activeDocument.resizeImage resizeWidth, resizeHeight
	return

# 保存
save = (fileName, folder = '~') ->
	newFile = new File folder + '/' + fileName
	jpegOpt = new JPEGSaveOptions()
	jpegOpt.embedColorProfile = false
	jpegOpt.quality = 12
	jpegOpt.formatOptions = FormatOptions.OPTIMIZEDBASELINE
	jpegOpt.scans = 3
	jpegOpt.matte = MatteType.NONE
	activeDocument.saveAs newFile, jpegOpt, true, Extension.LOWERCASE
	return

close = (showDialog = false) ->
	if showDialog
		unless confirm '閉じてよろしいですか?'
			return
	activeDocument.close(SaveOptions.DONOTSAVECHANGES);
	return

action = (width, height, method, targetFolderPath, saveFolderPath) ->
	# 連番で保存する
	AUTO_INCREMENT = true
	INCREMENT_INITIAL = 1
	# 連番ゼロ埋め
	FILL_ZERO = 3

	switch method
		when 0
			trim = true
			fill = false
		when 1
			trim = false
			fill = true
		else
			trim = false
			fill = false

	filter = undefined # TODO: getFilesの引数はまだ理解していないのであとで解決する。

	targetFolder = new Folder targetFolderPath
	saveFolder = new Folder saveFolderPath
	
	fileList = targetFolder.getFiles filter

	width = parseInt width, 10
	height = parseInt height, 10

	increment = INCREMENT_INITIAL

	for fileName in fileList
		# 画像でなければ無視してループの先頭に戻る
		unless /\.(jpe?g|gif|png|bmp|tiff?)$/i.test fileName
			# alert fileName
			continue
		file = new File fileName
		try
			if file.open 'r'
				open fileName
				if true # AUTO_INCREMENT
					newName = increment.fillZero(FILL_ZERO) + '.jpg'
					increment += 1
				resize width, height, trim, fill
				save newName, saveFolder
				close()
			else
				alert fileName
				throw 'fail'
		catch error
			alert error.message
			continue
	return

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- # Show Dialog #
$dialog = new DialogUI 'リサイズ & トリミング', 700, 400, null, ->
	@addText '処理フォルダ', 100, 20, 10, 10
	$targetFolder = @addTextbox 540, 20, 60, 30
	@addButton '選択', 80, 20, 610, 30,
		click: ->
			targetFolder = Folder.selectDialog '対象のフォルダを選択してください'
			$targetFolder.val decodeURI targetFolder.getRelativeURI '/'
	@addText '書き出しフォルダ', 100, 20, 10, 50
	$saveFolder = @addTextbox 540, 20, 60, 70
	@addButton '選択', 80, 20, 610, 70,
		click: ->
			saveFolder = Folder.selectDialog '保存先のフォルダを選択してください'
			$saveFolder.val decodeURI saveFolder.getRelativeURI '/'
	@addText '幅', 30, 20, 10, 100
	$width = @addTextbox 100, 20, 50, 100
	@addText '高さ', 30, 20, 10, 130
	$height = @addTextbox 100, 20, 50, 130
	@addText 'リサイズ方法', 70, 20, 10, 160
	$methods = []
	$methods.push @addRadio '描画範囲内の中に収めトリミング', 220, 20, 10, 190
	$methods.push @addRadio 'トリミングせずに余白を作る', 220, 20, 230, 190
	$methods.push @addRadio 'トリミングせずに余白も作らない', 220, 20, 450, 190
	@ok ->
		width = $width.val()
		height = $height.val()
		targetFolderPath = encodeURI $targetFolder.val()
		saveFolderPath = encodeURI $saveFolder.val()
		for $method, i in $methods
			if $method.val()
				method = i
				break
		# alert 'method #' + method
		@close()
		action width, height, method, targetFolderPath, saveFolderPath





