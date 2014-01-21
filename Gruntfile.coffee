module.exports = (grunt)->
  # process.env.DEBUG = 'aw'
  require 'sugar'
  bp = require './bp/jade-scripts/_bp' # 将bp引入jade，编译出Router和View需要的代码
  grunt.initConfig
    clean: 
      src:
        files: [
          expand: true # 将来改为在dev下的配置
          cwd: 'bin'
          src: ['**/*.html', '**/*.js', '!.meteor/**/*', '!packages/**/*', '!public/**/*']
        ]
      temp: ['src-temp', 'test-temp']
      test: ['test-bin']

    copy:
      main:
        files: [{expand: true, cwd:'resource/', flatten:true, src: ['**/*.*'], dest: 'bin/public/resource'}]
      lib:
        files: [{expand: true, cwd:'lib/', src: ['**/*.js'], dest: 'bin/public/lib'}]
      lib_css:
        files: [{expand: true, cwd:'lib/', src: ['**/*.css'], dest: 'bin/stylesheets/lib'}]
      lib_style_resource:
        files: [{expand: true, cwd:'lib/', src: ['**/*', '!**/*.css', '!**/*.js'], dest: 'bin/public/stylesheets/lib'}]


    concat: # 将每个测试中都要用的部分抽出来
      prefix_src_ls:
        # options:
          # banner: "debug = require('debug')('aw')\n"
        files: [
          expand: true # 将来改为在dev下的配置
          # flatten: true
          cwd: 'src'
          src: ['**/*.ls', '!header.ls']
          dest: 'src-temp/'
          ext: '.ls'
        ]

      prefix_src_jade:
        options:
          banner: "include ../bp/jade-templates/bp-mixins\n"
        files: [
          expand: true # 将来改为在dev下的配置
          # flatten: true
          cwd: 'src'
          src: ['**/*.jade']
          dest: 'src-temp/'
          ext: '.jade'
        ]

      prefix_test:
        options:
          banner: require('fs').readFileSync('test/header.ls', {encoding: 'utf-8'})
        files: [
          expand: true # 将来改为在dev下的配置
          # flatten: true
          cwd: 'test'
          src: ['**/*.ls', '!header.ls', '!helpers/**/*', '!fixtures/**/*']
          dest: 'test-temp/'
          ext: '.ls'
        ]

    livescript: 
      bp_main: # jade.ls生成的B+应用启动代码
        files: [
          src: ['bp/main.ls']
          dest: 'bin/main.js'
        ]
      bp_lib:
        files: [
          expand: true
          cwd: 'bp'
          src: ['**/*.ls', '!main.ls', '!jade-scripts/_bp*.ls']
          dest: 'bin/lib'
          ext: '.js'
        ]
      src:
        files: [
          expand: true
          # flatten: true # flatten是为了避免在引用时，path长而易错。meteor自动搜集源文件，因此可以自由组织文件，不用担心path。故而这里也就不用flatten。
          cwd: 'src-temp'
          src: ['**/*.ls']
          dest: 'bin'
          ext: '.js'
        ]
      test:
        files: [
          expand: true # 将来改为在dev下的配置
          flatten: true
          cwd: 'test-temp'
          src: ['**/*.ls']
          dest: 'test-bin/'
          ext: '.spec.js'
        ]
      test_helper:
        options:
          bare: true
        files: [
          expand: true
          flatten: true
          cwd: 'test'
          src: ['helpers/**/*.ls', 'fixtures/**/*.ls']
          dest: 'test-bin/'
          ext: '.js'
        ]
    jade:
      app:
        files: [
          expand: true
          flatten: true # flatten是为了避免在引用时，path长而易错。meteor自动搜集源文件，因此可以自由组织文件，不用担心path。故而这里也就不用flatten。
          cwd: ''
          src: ['bp/runtime-scripts/client/**/*.jade', 'src-temp/**/*.jade']
          dest: 'bin'
          ext: '.html'
        ]
        options:
          pretty: true
          filters: require './bp/jade-scripts/_bp-filters'
          data:
            bp: bp # ！！！十分重要，将bp引入jade，编译出Router和View需要的代码
          #   grunt: ()-> grunt
          
    compass:
      all:
        options:
          config: 'compass/config.rb'

    simplemocha:
      src: 'test-bin/**/*.spec.js'
      options:
        reporter: 'spec'
        slow: 100
        timeout: 3000
    docco:
      jade:
        src: ['bp/jade-templates/**/*.jade']
        options:
          structured: "$(find bp -name '*.jade')"
          output: 'docs/jade'
      livescript:
        src: ['bp/**/*.ls']
        options:
          structured: "$(find bp -name '*.ls')"
          output: 'docs/ls'
    watch:
      app:
        files: ["bp/**/*.ls", "!bp/main.ls", "src/**/*.ls", "test/**/*.ls", "src/**/*.jade", "bp/**/*.jade", "compass/**/*.sass"]
        # tasks: ["concat", "livescript",  "copy", "simplemocha"]
        tasks: ["clean", "copy", "concat", "jade", "livescript", "compass", "simplemocha"]
        options:
          spawn: true
      bp_jade_doc:
        files: ["bp/jade-templates/**/*.jade"]
        tasks: ["docco:jade"]
      bp_ls_doc:
        files: ["bp/**/*.ls"]
        tasks: ["docco:livescript"]


  grunt.loadNpmTasks "grunt-livescript"
  grunt.loadNpmTasks "grunt-contrib-jade"
  grunt.loadNpmTasks "grunt-contrib-compass"
  grunt.loadNpmTasks "grunt-simple-mocha"
  # grunt.loadNpmTasks "grunt-nodemon"
  # grunt.loadNpmTasks "grunt-env"
  grunt.loadNpmTasks "grunt-contrib-jshint"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-clean"
  # grunt.loadNpmTasks "grunt-concurrent"
  grunt.loadNpmTasks "grunt-contrib-copy"
  grunt.loadNpmTasks "grunt-contrib-concat"
  grunt.loadNpmTasks "grunt-docco"

  grunt.registerTask "default", ["clean", "copy", "concat", "jade", "livescript", "compass", "simplemocha", "watch"]
