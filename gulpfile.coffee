gulp = require 'gulp'
webpack = require 'gulp-webpack'
jade = require 'gulp-jade'
browserSync = require 'browser-sync'
reload = browserSync.reload

gulp.task 'webpack', ->
  return gulp.src 'app/scripts/app.coffee'
  .pipe webpack
    output:
      filename: 'app.js'
    module:
      loaders: [
        {test: /\.coffee/, loader: 'coffee'}
      ]
    resolve:
      extensions: ["", ".web.coffee", ".web.js", ".coffee", ".js"]
  .pipe gulp.dest 'public/'
  .pipe reload stream: true

gulp.task 'watch', ['jade', 'webpack', 'browser-sync'], ->
  gulp.watch 'app/**/*.coffee', ['webpack']
  gulp.watch 'app/**/*.jade', ['jade']

gulp.task 'jade', ->
  return gulp.src 'app/**/*.jade'
  .pipe jade
    locals: {}
  .pipe gulp.dest "public/"
  .pipe reload stream: true  

gulp.task 'browser-sync', ->
  browserSync
    server:
      baseDir: ['public', 'bower_components']

gulp.task 'default', ['watch']