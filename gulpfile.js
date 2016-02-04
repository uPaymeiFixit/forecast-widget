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
        .pipe(gulp.dest('build/intermediate'));
});

gulp.task('copy-resources', function () {
    return gulp.src('resources/**/*')
        .pipe(gulp.dest('build/final'));
});

gulp.task('compile-index', function () {
    if (!compileIndex) {
        compileIndex = require('./modules/compile-index');
    }
    return gulp.src(['layout.html', 'build/intermediate/style.css', 'script.js'])
        .pipe(compileIndex('index.js'))
        .pipe(gulp.dest('build/final'));
});

gulp.task('zip', function () {
    if (!zip) {
        zip = require('gulp-zip');
    }
    return gulp.src('build/final/**/*')
        .pipe(zip('forecast.widget.zip'))
        .pipe(gulp.dest('build'));
});

gulp.task('install-widget', function () {
    return gulp.src('build/final/**/*')
        .pipe(gulp.dest('/Users/Josh/Library/Application Support/Übersicht/widgets/forecast.widget'));
});

gulp.task('watch', function () {
    gulp.watch('style.scss', ['sass', 'compile-index', 'install-widget']);
    gulp.watch('script.js', ['compile-index', 'install-widget']);
    gulp.watch('index.html', ['compile-index', 'install-widget']);
});

gulp.task('default', ['watch', 'sass', 'copy-resources', 'compile-index', 'install-widget']);
gulp.task('build', ['sass', 'copy-resources', 'compile-index', 'zip']);
