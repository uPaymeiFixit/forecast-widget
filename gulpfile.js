var gulp = require('gulp');
// var exit = require('gulp-exit');
var chalk = require('chalk');
var bower;
// var jshint;
// var mocha;
var sass;
var compileIndex;
var zip;
// var concat;

gulp.task('bower-install', function () {
    if (!bower) {
        bower = require('gulp-bower');
    }
    return bower();
});

// gulp.task('lint', function () {
//     if (!jshint) {
//         jshint = require('gulp-jshint');
//     }
//     return gulp.src('*.js')
//         .pipe(jshint())
//         .pipe(jshint.reporter('default'));
// });

// gulp.task('test', function () {
//     if (!mocha) {
//         mocha = require('gulp-mocha');
//     }
//     return gulp.src(['modules/test/*',
//                      'modules/pages/resources/scripts/shared/test/*',
//                      'modules/pages/resources/scripts/landing/test/*',
//                      'modules/pages/resources/scripts/locations/test/*',
//                      'modules/pages/resources/scripts/menu/test/*'
//                     ], {read: false})
//         .pipe(mocha({
//             growl: true,
//             useColors: true
//         }))
//         .pipe(exit());
// });

gulp.task('sass', function () {
    if (!sass) {
        sass = require('gulp-sass');
    }
    return gulp.src('style.scss')
        .pipe(sass().on('error', function (err) {
            var msg = '';
            var lines = err.messageFormatted.split('\n');
            for (var i = 0; i < lines.length; i++) {
                if (i > 0) {
                    msg += chalk.red(lines[i]);
                } else {
                    msg += lines[i];
                }
                if (i + 1 < lines.length) {
                    msg += '\n';
                }
            }
            console.log(msg);
        }))
        .pipe(gulp.dest('build/final'));
});

gulp.task('compile-index', function () {
    if (!compileIndex) {
        compileIndex = require('./modules/compile-index');
    }
    return gulp.src(['layout.html', 'script.js'])
        .pipe(compileIndex('index.js'))
        .pipe(gulp.dest('build/final'));
    // if (!concat) {
    //     concat = require('gulp-concat');
    // }
    // return gulp.src(['layout.html', 'script.js'])
    //     .pipe(concat('index.js'))
    //     .pipe(gulp.dest('build/final'));
});

gulp.task('zip', function () {
    if (!zip) {
        zip = require('gulp-zip');
    }
    return gulp.src('build/final')
        .pipe(zip('forecast.widget.zip'))
        .pipe(gulp.dest('build'));
});

gulp.task('watch', function () {
    gulp.watch('style.scss', ['sass', 'compile-index']);
    gulp.watch('script.js', ['compile-index']);
    gulp.watch('index.html', ['compile-index']);
});

gulp.task('default', ['watch', 'sass', 'compile-index']);
gulp.task('build', ['sass', 'compile-index', 'zip']);
