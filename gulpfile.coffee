gulp = require 'gulp'
jade = require 'gulp-jade'
sass = require 'gulp-sass'
plumber = require 'gulp-plumber'
webpack = require 'gulp-webpack'
_webpack = require 'webpack'
browserSync = require 'browser-sync'
reload = browserSync.reload

gulp.task 'webpack', ->
  return gulp.src 'app/scripts/main.coffee'
  .pipe plumber()
  .pipe webpack
    output:
      filename: 'app.js'
    module:
      loaders: [
        {test: /\.coffee/, loader: 'coffee'}
      ]
    resolve:
      extensions: ["", ".web.coffee", ".web.js", ".coffee", ".js"]
      modulesDirectories: ['node_modules', '../../bower_components']
      # alias: bootstrap: '../../node_modules/bootstrap/dist/js/bootstrap.js'
  .pipe gulp.dest 'public/'
  .pipe reload stream: true

gulp.task 'webpack2', ->
  return gulp.src 'app/scripts/otp/otp.coffee'
  .pipe plumber()
  .pipe webpack
    output:
      filename: 'otp-app.js'
    module:
      loaders: [
        {test: /\.coffee/, loader: 'coffee'}
      ]
    resolve:
      extensions: ["", ".web.coffee", ".web.js", ".coffee", ".js"]
      modulesDirectories: ['node_modules', '../../bower_components']
      # alias: bootstrap: '../../node_modules/bootstrap/dist/js/bootstrap.js'
  .pipe gulp.dest 'public/'
  .pipe reload stream: true

gulp.task 'watch', ['jade', 'webpack', 'sass', 'browser-sync'], ->
  gulp.watch 'app/**/*.coffee', ['webpack', 'webpack2']
  gulp.watch 'app/**/*.jade', ['jade']
  gulp.watch ['app/**/*.sass', 'app/**/*.scss'], ['sass']

gulp.task 'jade', ->
  return gulp.src 'app/**/*.jade'
  .pipe plumber()
  .pipe jade
    locals: {}
  .pipe gulp.dest "public/"
  .pipe reload stream: true

gulp.task 'sass', ->
  return gulp.src 'app/styles/main.scss'
  .pipe plumber()
  .pipe sass()
  .pipe gulp.dest 'public/'
  .pipe reload stream: true

gulp.task 'browser-sync', ->
  browserSync
    server:
      baseDir: ['public', 'bower_components']

gulp.task 'default', ['watch']
