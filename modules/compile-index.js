var through = require('through2');
var vinyl = require('vinyl');

var commands;
var html;
var css;

module.exports = function (outputFileName) {
    function compileIndex (file) {
        var filePath = file.path.split('/');
        var fileName = filePath[filePath.length - 1];
        var fileExtension = fileName.split('.')[fileName.split('.').length - 1].toLowerCase();
        if (fileExtension === 'js') {
            // console.log(JSON.stringify(require(file.path)));
            commands = file.contents.toString();
            commands = commands.split('\n');
            commands.splice(0, 1);
            commands.splice(commands.length - 2, 1);
            commands = commands.join('\n');
        } else if (fileExtension === 'html') {
            html = file.contents.toString().split('\n').join(' ');
        } else if (fileExtension === 'css') {
            css = file.contents.toString().split('\n').join(' ');
        }

        if (commands && html && css) {
            var output = 'render: function () { return \'' + html + '\'; },\n';
            output += 'style: \'' + css + '\',\n';
            output += commands;

            commands = undefined;
            html = undefined;
            css = undefined;

            var outputFile = new vinyl({
                cwd: file.cwd,
                base: '',
                path: outputFileName,
                contents: new Buffer(output)
            });
            return outputFile;
        }
    }

    return through.obj(function (file, encoding, callback) {
        callback(null, compileIndex(file));
    });
};
