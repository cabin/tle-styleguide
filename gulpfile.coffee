gulp = require('gulp')
$ = require('gulp-load-plugins')()

paths =
  coffee: 'app/js/**/*.coffee'
  sass: 'app/css/**/*.s[ac]ss'
  html: 'app/*.html'
  ngtemplates: 'app/partials/**/*.html'
ports =
  connect: 5011
  livereload: 35730
beepMsg = (err) -> console.log('\x07', err)


## Build  ####################################################################

gulp.task('build', ['coffee', 'sass', 'html', 'ngtemplates'])

gulp.task 'coffee', buildCoffee = ->
  gulp.src(paths.coffee)
    .pipe($.coffee()).on('error', beepMsg)
    .pipe(gulp.dest('build'))

gulp.task 'sass', buildSass = ->
  gulp.src(paths.sass)
    .pipe($.rubySass(loadPath: 'bower_components')).on('error', beepMsg)
    .pipe(gulp.dest('build'))

gulp.task 'html', buildHtml = ->
  fs = require('fs')
  dateformat = require('dateformat')
  gulp.src(paths.html)
    .pipe $.template
      section: (name) -> fs.readFileSync("app/sections/#{name}.html")
      timestamp: dateformat('mmmm d, yyyy')
    .on('error', beepMsg)
    .pipe(gulp.dest('build'))

gulp.task 'ngtemplates', buildTemplates = ->
  gulp.src(paths.ngtemplates)
    .pipe($.angularTemplatecache(module: 'styleguide', root: 'partials'))
    .pipe(gulp.dest('build'))


## Production build  #########################################################

gulp.task('dist', ['images', 'downloads', 'useref'])

gulp.task 'clean:dist', ->
  gulp.src('dist', read: false).pipe($.clean())

gulp.task 'images', ['clean:dist'], ->
  gulp.src('app/img/**/*').pipe(gulp.dest('dist/img'))

gulp.task 'downloads', ['clean:dist'], ->
  gulp.src('app/downloads/**/*').pipe(gulp.dest('dist/downloads'))

gulp.task 'useref', ['build', 'clean:dist'], ->
  gulp.src('build/index.html')
    .pipe($.useref.assets(searchPath: ['build', '.']))
    .pipe($.if('**/*.js', $.ngmin()))
    .pipe($.if('**/*.js', $.uglify()))
    .pipe($.if('**/*.css', $.csso()))
    .pipe($.rev())
    .pipe($.useref.restore())
    .pipe($.useref())
    .pipe($.revReplace())
    .pipe(gulp.dest('dist'))

gulp.task 'deploy', ['dist'], (next) ->
  spawn = require('child_process').spawn
  args = [
    '--acl-public'
    '--delete-removed'
    '--add-header=Cache-Control:max-age=86400'
    'sync'
    'dist/'
    's3://tle.madebycabin.com/'
  ]
  spawn('s3cmd', args, stdio: 'inherit').on('close', next)


## Development  ##############################################################

gulp.task('default', ['build', 'connect'], -> gulp.start('watch'))

gulp.task 'connect', (next) ->
  connect = require('connect')
  app = connect()
    .use(require('connect-livereload')(port: ports.livereload))
    .use(connect.static('build'))
    .use(connect.static('app'))
    .use('/bower_components', connect.static('bower_components'))
    .listen ports.connect, ->
      console.log "[connect] Listening on http://localhost:#{ports.connect}/"
      next()
  
gulp.task 'watch', (next) ->
  gulp.watch(paths.coffee, ['coffee'])
  gulp.watch(paths.sass, ['sass'])
  gulp.watch([paths.html, 'app/sections/*.html'], ['html'])
  gulp.watch(paths.ngtemplates, ['ngtemplates'])
  $.livereload.listen(ports.livereload, silent: true)
  gulp.watch('build/**/*').on 'change', (file) ->
    $.livereload.changed(file, ports.livereload)
