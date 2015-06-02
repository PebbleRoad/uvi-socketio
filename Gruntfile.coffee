module.exports = (grunt) ->

  # Tasks
  grunt.initConfig {

    # ----------------------
    # Clean
    # ----------------------
    # clean:
    #   src: ['!public/js/templates.js', 'public/js']
    #   templates: ['public/js/templates.js']

    # ----------------------
    # Coffee
    # ----------------------
    coffee:
      dev:
        options:
          bare: true
        expand: true
        cwd: 'public/coffee/'
        src: ['**.coffee', '**/*.coffee']
        dest: 'public/js/'
        ext: '.js'

    copy:
      main:
        files: [
          { expand: true, src: ['public/bower_components/jquery/dist/jquery.min.js'], dest: 'public/js/libs/', filter: 'isFile', flatten: true }
          { expand: true, src: ['public/bower_components/foundation/js/foundation.min.js'], dest: 'public/js/libs/', filter: 'isFile', flatten: true }
          { expand: true, src: ['public/bower_components/FitText.js/jquery.fittext.js'], dest: 'public/js/libs/', filter: 'isFile', flatten: true }
          { expand: true, src: ['public/bower_components/Chart.js/Chart.min.js'], dest: 'public/js/libs/', filter: 'isFile', flatten: true }
          { expand: true, src: ['public/bower_components/moment/min/moment.min.js'], dest: 'public/js/libs/', filter: 'isFile', flatten: true }
        ]

    # ----------------------
    # Watch
    # ----------------------
    watch:
      scripts:
        files: 'public/coffee/**/*.coffee'
        tasks: ['coffee']

  }

  # Plugins
  require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks)

  # Commands
  grunt.registerTask 'default', ['']

  return grunt