# => SRC FOLDER
toast 'src',

  # EXCLUDED FOLDERS (optional)
  # exclude: ['folder/to/exclude', 'another/folder/to/exclude', ... ]

  # => VENDORS (optional)
  vendors: ['js/EventEmitter-4.0.3.min.js']

  # => OPTIONS (optional, default values listed)
  bare: true
  # packaging: true
  # expose: ''
  # minify: true

  # => HTTPFOLDER (optional), RELEASE / DEBUG (required)
  httpfolder: 'js'
  release: 'js'
  debug: 'js-debug'
