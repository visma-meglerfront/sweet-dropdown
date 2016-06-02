module.exports = function(grunt) {
	require('load-grunt-tasks')(grunt);

	grunt.initConfig({
		pkg: grunt.file.readJSON('package.json'),
		copyrightBanner: grunt.file.read('COPYRIGHT'),

		opts: {
			scss: 'src/scss',
			js: 'src/js',
			examples: 'examples',

			dist: {
				parent: 'dist',
				min: 'dist/min',
				dev: 'dist/dev'
			},

			archive: {
				zip: 'jquery.sweet-dropdown-<%= pkg.version %>.zip'
			}
		},

		clean: {
			dist: ['<%= opts.dist.parent %>/*'],
			examples: [
				'<%= opts.examples %>/css',
				'<%= opts.examples %>/js'
			]
		},

		copy: {
			'examples-deps-js': {
				expand: true,
				flatten: true,
				src: ['node_modules/jquery/dist/jquery.min.js', '<%= opts.dist.min %>/jquery.sweet-dropdown.min.js'],
				dest: '<%= opts.examples %>/js/'
			},

			'examples-deps-css': {
				expand: true,
				flatten: true,
				src: ['<%= opts.dist.min %>/jquery.sweet-dropdown.min.css'],
				dest: '<%= opts.examples %>/css/'
			}
		},

		coffee: {
			options: {
				bare: true
			},

			'sweet-dropdown': {
				files: {
					'<%= opts.dist.dev %>/jquery.sweet-dropdown.js': ['<%= opts.js %>/sweet-dropdown.coffee']
				}
			}
		},

		sass: {
			options: {
				trace: true,
				sourcemap: 'none',
				style: 'compressed'
			},

			'sweet-dropdown': {
				options: {
					style: 'nested',
					sourcemap: 'auto'
				},

				files: {
					'<%= opts.dist.dev %>/jquery.sweet-dropdown.css': ['<%= opts.scss %>/sweet-dropdown.scss']
				}
			},

			'sweet-dropdown-min': {
				files: {
					'<%= opts.dist.min %>/jquery.sweet-dropdown.min.css': ['<%= opts.scss %>/sweet-dropdown.scss']
				}
			},

			examples: {
				files: {
					'<%= opts.examples %>/css/examples.css': ['<%= opts.scss %>/examples.scss']
				}
			}
		},

		file_append: {
			'sweet-dropdown': {
				files: [
					{
						prepend: '<%= copyrightBanner %>',
						input: '<%= opts.dist.dev %>/jquery.sweet-dropdown.js',
						output: '<%= opts.dist.dev %>/jquery.sweet-dropdown.js'
					}
				]
			}
		},

		uglify: {
			options: {
				screwIE8: true,
				mangle: {
					except: ['jQuery', '$', 'module']
				},
				banner: '<%= copyrightBanner %>',
				mangle: false,
				sourceMap: false
			},

			'sweet-dropdown-min': {
				files: {
					'<%= opts.dist.min %>/jquery.sweet-dropdown.min.js': ['<%= opts.dist.dev %>/jquery.sweet-dropdown.js']
				}
			}
		},

		watch: {
			scss: {
				files: ['<%= opts.scss %>/**/*.scss'],
				tasks: ['compile:scss', 'copy:examples-deps-css']
			},

			js: {
				files: ['<%= opts.js %>/**/*.coffee'],
				tasks: ['compile:js', 'copy:examples-deps-js']
			}
		},

		compress: {
			'sweet-dropdown': {
				options: {
					archive: '<%= opts.dist.parent %>/<%= opts.archive.zip %>'
				},

				files: [
					{
						expand: true,
						cwd: '<%= opts.dist.parent %>',
						src: ['*', '**/*', '!*.zip', '../LICENSE-GPL', '../LICENSE-MIT', '../README.md'],
						dest: '/'
					}
				]
			}
		}
	});

	grunt.registerTask('copy:examples-deps', ['copy:examples-deps-js', 'copy:examples-deps-css']);

	grunt.registerTask('compile:js', ['coffee:sweet-dropdown', 'uglify:sweet-dropdown-min']);

	grunt.registerTask('compile:scss', ['sass']);
	grunt.registerTask('compile:scss:sweet-dropdown', ['sass:sweet-dropdown', 'sass:sweet-dropdown-min']);
	grunt.registerTask('compile:scss:examples', ['sass:examples']);

	grunt.registerTask('compile:examples', ['clean:examples', 'compile:scss:examples', 'copy:examples-deps']);

	grunt.registerTask('compile', ['clean', 'compile:js', 'file_append:sweet-dropdown', 'compile:scss:sweet-dropdown', 'compile:examples']);

	grunt.registerTask('default', ['compile']);
};