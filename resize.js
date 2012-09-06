// Generated by CoffeeScript 1.3.3
/**
 * リサイズ&トリミング
 * version 1.1
*/

var $dialog, ControlUI, DialogUI, WindowUI, action, close, resize, save, varDump,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

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
    if (!__hasProp.call(obj, _key)) continue;
    try {
      _val = obj[_key];
      if (!(_val instanceof Function)) {
        _rlt.push(_key + ': ' + _val);
      }
    } catch (error) {

    }
  }
  return alert(_rlt.join('\n'));
};

ControlUI = (function() {

  function ControlUI($window, type, width, height, left, top, options) {
    this.type = type;
    this.width = width != null ? width : 100;
    this.height = height != null ? height : 20;
    this.left = left != null ? left : 0;
    this.top = top != null ? top : 0;
    if (options == null) {
      options = [];
    }
    this.window = $window.window;
    this.context = this.window.add.apply(this.window, [this.type, [this.left, this.top, this.width + this.left, this.height + this.top]].concat(options));
  }

  ControlUI.prototype.close = function(value) {
    return this.window.close(value);
  };

  ControlUI.prototype.val = function() {
    var value;
    switch (this.type) {
      case 'edittext':
      case 'statictext':
        value = this.context.text;
        break;
      default:
        value = this.context.value;
    }
    return value;
  };

  ControlUI.prototype.on = function(event, callback) {
    var self,
      _this = this;
    event = event.toLowerCase().replace(/^on/i, '').replace(/^./, function(character) {
      return character.toUpperCase();
    });
    self = this;
    this.context['on' + event] = function() {
      return callback.apply(self, arguments);
    };
    return this;
  };

  return ControlUI;

})();

WindowUI = (function() {

  function WindowUI(type, name, width, height, options, callback) {
    var stop;
    this.type = type;
    this.name = name != null ? name : 'ダイアログボックス';
    this.width = width != null ? width : 100;
    this.height = height != null ? height : 100;
    this.window = new Window(this.type, this.name, [0, 0, this.width, this.height], options);
    this.window.center();
    this.controls = [];
    stop = callback != null ? callback.call(this) : void 0;
    if (stop !== false) {
      this.show();
    }
  }

  WindowUI.prototype.close = function(value) {
    return this.window.close(value);
  };

  WindowUI.prototype.show = function() {
    this.window.show();
    return this;
  };

  WindowUI.prototype.hide = function() {
    this.window.hide();
    return this;
  };

  WindowUI.prototype.center = function() {
    this.window.center();
    return this;
  };

  WindowUI.prototype.addControl = function(type, width, height, left, top, options, events) {
    var $ctrl, callback, event;
    $ctrl = new ControlUI(this, type, width, height, left, top, options);
    if (events != null) {
      for (event in events) {
        if (!__hasProp.call(events, event)) continue;
        callback = events[event];
        $ctrl.on(event, callback);
      }
    }
    this.controls.push($ctrl);
    return $ctrl;
  };

  WindowUI.prototype.addTextbox = function(width, height, left, top, defaultText, events) {
    if (defaultText == null) {
      defaultText = '';
    }
    return this.addControl('edittext', width, height, left, top, [defaultText], events);
  };

  WindowUI.prototype.addText = function(text, width, height, left, top, events) {
    if (text == null) {
      text = '';
    }
    return this.addControl('statictext', width, height, left, top, [text], events);
  };

  WindowUI.prototype.addButton = function(label, width, height, left, top, events) {
    return this.addControl('button', width, height, left, top, [label], events);
  };

  WindowUI.prototype.addRadio = function(label, width, height, left, top, events) {
    return this.addControl('radiobutton', width, height, left, top, [label], events);
  };

  return WindowUI;

})();

DialogUI = (function(_super) {

  __extends(DialogUI, _super);

  function DialogUI(name, width, height, options, callback) {
    this.name = name;
    this.width = width;
    this.height = height;
    DialogUI.__super__.constructor.call(this, 'dialog', this.name, this.width, this.height, options, callback);
  }

  return DialogUI;

})(WindowUI);

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

action = function(width, height, trim, fill) {
  var AUTO_INCREMENT, FILL_ZERO, INCREMENT_INITIAL, file, fileList, fileName, filter, increment, newName, saveFolder, targetFolder, _i, _len;
  AUTO_INCREMENT = true;
  INCREMENT_INITIAL = 0;
  FILL_ZERO = 3;
  trim = true;
  fill = true;
  filter = void 0;
  targetFolder = Folder.selectDialog('対象のフォルダを選択してください');
  saveFolder = Folder.selectDialog('保存先のフォルダを選択してください');
  fileList = targetFolder.getFiles(filter);
  width = parseInt(width, 10);
  height = parseInt(height, 10);
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
};

$dialog = new DialogUI('リサイズ & トリミング', 700, 400, null, function() {
  var $height, $method, $width;
  this.addText('幅', 30, 20, 10, 10);
  $width = this.addTextbox(100, 20, 50, 10);
  this.addText('高さ', 30, 20, 10, 40);
  $height = this.addTextbox(100, 20, 50, 40);
  this.addText('リサイズ方法', 70, 20, 10, 70);
  $method = [];
  $method.push(this.addRadio('描画範囲内の中でトリミング', 200, 20, 10, 100));
  $method.push(this.addRadio('トリミングせずに余白を作る', 200, 20, 210, 100));
  this.addButton('OK', 75, 20, 415, 370, {
    click: function() {
      var height, width;
      width = $width.val();
      height = $height.val();
      return action(width, height, true, true);
    }
  });
  return this.addButton('キャンセル', 75, 20, 330, 370, {
    click: function() {
      return this.close();
    }
  });
});
