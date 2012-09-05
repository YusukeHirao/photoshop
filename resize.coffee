###*
 * リサイズ&トリミング
 * version 1.0
 ###

# 連番で保存する
AUTO_INCREMENT = true
INCREMENT_INITIAL = 0
# 連番ゼロ埋め
FILL_ZERO = 3
# トリミング
trim = true
# リサイズで余白を作るか
fill = true

# 単位をピクセルに
preferences.rulerUnits = Units.PIXELS;

# 数値処理拡張
Number::fillZero = (n) ->
  zeros = new Array n + 1 - @toString(10).length
  zeros.join('0') + @;

# ハッシュの出力用（再帰なし）
varDump = (obj) ->
	_rlt = []
	for _key, _val of obj
		_rlt.push _key + ': ' + _val
	_rlt.join '\n'

# リサイズ
resize = (width, height) ->
	# 元の幅と高さ
	originWidth = activeDocument.width.value
	originHeight = activeDocument.height.value
	# 元の縦横比(高さ÷幅)
	originRatio = originHeight / originWidth
	# 指定の縦横比(高さ÷幅)
	ratio = height / width
	if fill
		resizeWidth = width
		resizeHeight = height
		if trim and originWidth > originHeight
			trimWidth = originHeight / ratio
			trimHeight = originHeight
		else
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

filter = undefined # TODO: getFilesの引数はまだ理解していないのであとで解決する。
targetFolder = Folder.selectDialog '対象のフォルダを選択してください'
saveFolder = Folder.selectDialog '保存先のフォルダを選択してください'
fileList = targetFolder.getFiles filter

width = prompt 'WIDTH:', ''
width = parseInt width, 10
height = prompt 'HEIGHT', ''
height = parseInt height, 10

if confirm 'トリミングしますか?'
	trim = true
else
	fill = confirm '余白を埋めますか?'

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
			resize width, height
			save newName, saveFolder
			close()
		else
			alert fileName
			throw 'fail'
	catch error
		alert error.message
		continue
