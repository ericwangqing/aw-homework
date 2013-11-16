'''
自动运行：grunt
手动运行：
  1）grunt server 
  2）在新窗口 grunt test
'''
module.exports = (grunt)->
  # process.env.DEBUG = 'aw'
  grunt.initConfig
    clean: ["bin", 'src-temp', 'test-temp', 'test-bin']
    copy:
      main:
        files: [{expand: true, cwd:'resource/', src: ['*'], dest: 'bin/'}]
    concat: # 将每个测试中都要用的部分抽出来
      prefix_src:
        options:
          banner: "debug = require('debug')('aw')\n"
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
      src:
        files: [
          expand: true
          # flatten: true # flatten是为了避免在引用时，path长而易错。meteor自动搜集源文件，因此可以自由组织文件，不用担心path。故而这里也就不用flatten。
          cwd: 'src-temp'
          src: ['**/*.ls']
          dest: 'bin/'
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
    jshint:
      files: "bin/**/*.js"
    # env: #
    #   manual_test:
    #     SERVER_ALREADY_RUNNING: true
    simplemocha:
      src: 'test-bin/**/*.spec.js'
      options:
        reporter: 'spec'
        slow: 100
        timeout: 3000
    watch:
      auto:
        files: ["src/**/*.ls", "test/**/*.ls"]
        # tasks: ["concat", "livescript",  "copy", "simplemocha"]
        tasks: ["clean", "copy", "concat", "livescript", "simplemocha"]
        options:
          spawn: true
      manual:
        files: ["src/**/*.ls"]
        tasks: ["concat:prefix_src", "livescript:src",  "copy"]
        options:
          spawn: true
    # nodemon:
    #   all:
    #     options: 
    #       file: 'bin/app.js'
    #       watchedFolders: ['bin']
    # concurrent:
    #   target: 
    #     tasks:
    #       ['nodemon', 'watch:manual']
    #     options:
    #       logConcurrentOutput: true

  grunt.loadNpmTasks "grunt-livescript"
  grunt.loadNpmTasks "grunt-simple-mocha"
  # grunt.loadNpmTasks "grunt-nodemon"
  # grunt.loadNpmTasks "grunt-env"
  grunt.loadNpmTasks "grunt-contrib-jshint"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-clean"
  # grunt.loadNpmTasks "grunt-concurrent"
  grunt.loadNpmTasks "grunt-contrib-copy"
  grunt.loadNpmTasks "grunt-contrib-concat"

  grunt.registerTask "default", ["clean", "copy", "concat", "livescript", "simplemocha", "watch:auto"]
  # grunt.registerTask "server", ["clean", "copy", "concat", "livescript", "concurrent"]
  # grunt.registerTask "test", ["env:manual_test", "concat:prefix_test", "livescript:test", "livescript:test_helper", "simplemocha"]


  grunt.registerTask 'delayed-simplemocha', "run mocha later for nodemon picks up changes", ->
    done = this.async()
    DELAY = TIME_WAIT_SERVER_RESTART 
    grunt.log.writeln 'run mocha after %dms', DELAY
    setTimeout (->
      grunt.task.run 'simplemocha'
      done()
    ), DELAY

  grunt.event.on 'watch', (action, filepath)->
    console.log 'filepath: ', filepath
    grunt.config ['livescript', 'src'], filepath
    grunt.config ['livescript', 'test'], filepath