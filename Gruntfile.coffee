module.exports = (grunt)->
  # process.env.DEBUG = 'aw'
  require 'sugar'
  bp = require './bp/jade-scripts/_jade' # 将bp引入jade，编译出Router和View需要的代码
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
        files: [{expand: true, cwd:'resource/', flatten:true, src: ['**/*'], dest: 'bin/public/resource'}]
      lib:
        files: [{expand: true, cwd:'lib/', src: ['*'], dest: 'bin/public/lib'}]

    concat: # 将每个测试中都要用的部分抽出来
      prefix_src:
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
          src: ['**/*.ls', '!main.ls', '!jade-scripts/_jade.ls']
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
      bp:
        files: [
          expand: true
          cwd: 'bp/client'
          src: ['**/*.jade']
          dest: 'bin/lib/client'
          ext: '.html'
        ]
        options:
          debug: false
          pretty: true
          data:
            bp: bp # ！！！十分重要，将bp引入jade，编译出Router和View需要的代码
       all:
        files: [
          expand: true
          cwd: 'src'
          src: ['**/*.jade']
          dest: 'bin'
          ext: '.html'
        ]
        options:
          debug: false
          pretty: true
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

    watch:
      app:
        files: ["bp/**/*.ls", "!bp/main.ls", "src/**/*.ls", "test/**/*.ls", "src/**/*.jade", "bp/**/*.jade", "compass/**/*.sass"]
        # tasks: ["concat", "livescript",  "copy", "simplemocha"]
        tasks: ["clean", "copy", "jade", "concat", "livescript", "compass", "simplemocha"]
        options:
          spawn: true


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

  grunt.registerTask "default", ["clean", "copy", "jade", "concat", "livescript", "compass", "simplemocha", "watch"]
