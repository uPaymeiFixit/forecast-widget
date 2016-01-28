var through = require('through2');
var vinyl = require('vinyl');

module.exports = function (output) {
    function compileIndex (file) {
        var filePath = file.path.split('/');
        var fileName = filePath[filePath.length - 1];
        var fileExtension = fileName.split('.')[fileName.split('.').length - 1];
        if (fileExtension === 'js') {
            console.log(require(file.path));
        }
        // console.log(output);
        // console.log('File name: ' + file.contents);
    }

    return through.obj(function (file, encoding, callback) {
        callback(null, compileIndex(file));
    });
};
