// Generated by CoffeeScript 1.3.3
/**
 * リサイズ&トリミング
 * version 1.0
*/

var AUTO_INCREMENT, FILL_ZERO, INCREMENT_INITIAL, close, file, fileList, fileName, fill, filter, height, increment, newName, resize, save, saveFolder, targetFolder, trim, varDump, width, _i, _len;

AUTO_INCREMENT = true;

INCREMENT_INITIAL = 0;

FILL_ZERO = 3;

trim = true;

fill = true;

preferences.rulerUnits = Units.PIXELS;

Number.prototype.fillZero = function(n) {
  var zeros;
  zeros = new Array(n + 1 - this.toString(10).length);
  return zeros.join('0') + this;
};

varDump = function(obj) {
  var _key, _rlt, _val;
  _rlt = [];
  for (_key in obj) {
    _val = obj[_key];
    _rlt.push(_key + ': ' + _val);
  }
  return _rlt.join('\n');
};

resize = function(width, height) {
  var originHeight, originRatio, originWidth, ratio, resizeHeight, resizeWidth, trimHeight, trimWidth;
  originWidth = activeDocument.width.value;
  originHeight = activeDocument.height.value;
  originRatio = originHeight / originWidth;
  ratio = height / width;
  if (fill) {
    resizeWidth = width;
    resizeHeight = height;
    if (trim && originWidth > originHeight) {
      trimWidth = originHeight / ratio;
      trimHeight = originHeight;
    } else {
      trimWidth = originWidth;
      trimHeight = originWidth * ratio;
    }
    activeDocument.resizeCanvas(trimWidth, trimHeight, AnchorPosition.MIDDLECENTER);
  } else {
    if (width > height) {
      resizeWidth = height / originRatio;
      resizeHeight = height;
      if (resizeWidth > width) {
        resizeWidth = width;
        resizeHeight = width * originRatio;
      }
    } else {
      resizeWidth = width;
      resizeHeight = width * originRatio;
      if (resizeHeight > height) {
        resizeWidth = height / originRatio;
        resizeHeight = height;
      }
    }
  }
  activeDocument.resizeImage(resizeWidth, resizeHeight);
};

save = function(fileName, folder) {
  var jpegOpt, newFile;
  if (folder == null) {
    folder = '~';
  }
  newFile = new File(folder + '/' + fileName);
  jpegOpt = new JPEGSaveOptions();
  jpegOpt.embedColorProfile = false;
  jpegOpt.quality = 12;
  jpegOpt.formatOptions = FormatOptions.OPTIMIZEDBASELINE;
  jpegOpt.scans = 3;
  jpegOpt.matte = MatteType.NONE;
  activeDocument.saveAs(newFile, jpegOpt, true, Extension.LOWERCASE);
};

close = function(showDialog) {
  if (showDialog == null) {
    showDialog = false;
  }
  if (showDialog) {
    if (!confirm('閉じてよろしいですか?')) {
      return;
    }
  }
  activeDocument.close(SaveOptions.DONOTSAVECHANGES);
};

filter = void 0;

targetFolder = Folder.selectDialog('対象のフォルダを選択してください');

saveFolder = Folder.selectDialog('保存先のフォルダを選択してください');

fileList = targetFolder.getFiles(filter);

width = prompt('WIDTH:', '');

width = parseInt(width, 10);

height = prompt('HEIGHT', '');

height = parseInt(height, 10);

if (confirm('トリミングしますか?')) {
  trim = true;
} else {
  fill = confirm('余白を埋めますか?');
}

increment = INCREMENT_INITIAL;

for (_i = 0, _len = fileList.length; _i < _len; _i++) {
  fileName = fileList[_i];
  if (!/\.(jpe?g|gif|png|bmp|tiff?)$/i.test(fileName)) {
    continue;
  }
  file = new File(fileName);
  try {
    if (file.open('r')) {
      open(fileName);
      if (true) {
        newName = increment.fillZero(FILL_ZERO) + '.jpg';
        increment += 1;
      }
      resize(width, height);
      save(newName, saveFolder);
      close();
    } else {
      alert(fileName);
      throw 'fail';
    }
  } catch (error) {
    alert(error.message);
    continue;
  }
}
