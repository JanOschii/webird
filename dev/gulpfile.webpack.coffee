'use strict'

path = require 'path'
fs = require 'fs'
crypto = require 'crypto'
# Gulp
gulp = require 'gulp'
gutil = require 'gulp-util'
# Webpack
webpack = require 'webpack'
WebpackDevServer = require 'webpack-dev-server'
ResolverPlugin = require 'webpack/lib/ResolverPlugin'
ProvidePlugin = require 'webpack/lib/ProvidePlugin'
DefinePlugin = require 'webpack/lib/DefinePlugin'
CommonsChunkPlugin = require 'webpack/lib/optimize/CommonsChunkPlugin'
ExtractTextPlugin = require 'extract-text-webpack-plugin'
# utilties
_ = require 'lodash'

# Project root paths
projectRoot = path.resolve '..'
etcRoot = path.join projectRoot, 'etc'
appRoot = path.join projectRoot, 'app'
devRoot = path.join projectRoot, 'dev'
distRoot = path.join projectRoot, 'dist'
# Application resources
webpackRoot = path.join appRoot, 'webpack'
appModulesRoot = path.join webpackRoot, 'modules'
themeRoot = path.join appRoot, 'theme'
# Development resources
bowerRoot = path.join devRoot, 'bower_components'
nodeModulesRoot = path.join devRoot, 'node_modules'

projectRootHash = crypto.createHash('md5').update(projectRoot).digest('hex')

wpConf =
  cache: true
  context: webpackRoot

  output:
    path: "/tmp/webird-#{projectRootHash}-webpack"
    publicPath: '/'
    filename: 'js/[name].js'
    chunkFilename: 'js/chunk/[id].js'
    namedChunkFilename: 'js/[name].js'

  resolve:
    root: [
      appModulesRoot
      bowerRoot
      nodeModulesRoot
      themeRoot
    ]

    modulesDirectories: [appModulesRoot, 'node_modules', 'bower_components']

    alias:
      underscore: 'lodash'
      handlebars: 'handlebars/dist/handlebars'
      Backbone:   'backbone'
      Marionette: 'backbone.marionette'
      jade:       'jade/lib/runtime'

    extensions: [
      ""
      ".js", ".coffee"
      ".html", ".jade", ".hbs"
      ".css", ".scss", ".less", ".styl"
    ]

  resolveLoader:
    root: nodeModulesRoot

  plugins: [
    new DefinePlugin
      # Constants to be evaluated at build time.
      THEME_ROOT: JSON.stringify "#{appRoot}/theme"
      LOCALE_ROOT: JSON.stringify "#{appRoot}/locale"

    new ExtractTextPlugin 'css/[name].css', allChunks: false

    # Automatically loaded modules. Module (value) is loaded when the
    # identifier (key) is used as free variable in a module.
    new ProvidePlugin
      _          : 'lodash'
      $          : 'jquery'
      jQuery     : 'jquery'

    # This plugin makes webpack not only looking for package.json, but also
    # for a bower.json with a main-field
    new ResolverPlugin [
      new ResolverPlugin.DirectoryDescriptionFilePlugin "bower.json", ["main"]
    ], ["normal", "loader"]

    new webpack.IgnorePlugin /jade/
  ]
  module:
    # Saves substantial time on inital build by not parsing libaries.
    # Only use this on modules that are not using commonjs require.
    noParse: [
      path.join bowerRoot, "/lodash"
      path.join bowerRoot, "/jquery"
      path.join bowerRoot, "/bootstrap"
      path.join bowerRoot, "/angular"
      path.join bowerRoot, "/angular-ui-router"
      path.join bowerRoot, "/angular-cookies"
      path.join bowerRoot, "/angular-resource"
      path.join nodeModulesRoot, "/handlebars"
    ]
    loaders: [
      {
        # "Shims" Angular to return itself
        test: /[\/]angular\.js$/
        loader: "exports?angular"
      }
      {
        # "Shims" Handlebars to return itself
        test: /handlebars\.js$/
        loader: "exports?Handlebars"
      }
      {
        # Exposes jQuery and $ to the window object.
        # The ProvidePlugin is set to auto require() it within CommonJS code
        test: /jquery\.js$/
        loader: "expose?jQuery!expose?$"
      }
      {
        # Script Loader
        test: /\.coffee$/
        loader: "coffee"
      }
      {
        # Json Loader
        test: /\.json$/
        loader: "json"
      }
      {
        # PO translation messages Loader
        test: /\.po$/
        loader: "json!po"
      }
      {
        # HTML Loaders
        test: /\.html$/
        loader: "html"
      }
      {
        test: /\.jade$/
        loader: "jade"
      }
      {
        test: /\.hbs$/
        loader: "html"
      }
      # Style Loaders, style! inlines the css into the bundle files
      {
        test: /\.css$/
        loader: ExtractTextPlugin.extract("style-loader", "css-loader")
        # loader: "style!css"
      }
      {
        test: /\.less$/
        loader: ExtractTextPlugin.extract("style-loader", "css-loader!less-loader")
        # loader: "style!css!less"
      }
      {
        test: /\.scss$/
        loader: ExtractTextPlugin.extract("style-loader", "css-loader!sass-loader")
        # loader: "style!css!sass"
      }
      {
        test: /\.styl$/
        loader: ExtractTextPlugin.extract("style-loader", "css-loader!stylus-loader")
        # loader: "style!css!stylus"
      }
      # Fonts.  These are built into the output.path/fonts/ directory
      {
        test: /\.woff$/
        loader: "url?name=fonts/[hash].[ext]&limit=10000&minetype=application/font-woff"
      }
      {
        test: /\.ttf$/
        loader: "file?name=fonts/[hash].[ext]"
      }
      {
        test: /\.eot$/
        loader: "file?name=fonts/[hash].[ext]"
      }
      {
        test: /\.svg$/
        loader: "file?name=fonts/[hash].[ext]"
      }
    ]




# user app configure
appConfig = require "#{webpackRoot}/config"

getEntryNames = (filepath) ->
  files = fs.readdirSync filepath
  baseNames = _.chain(files)
    .filter (filename) ->
      filename[0] isnt '#'
    .map (filename) ->
      ext = path.extname filename
      entryName = filename.substr 0, filename.length - ext.length
    .value()
  return baseNames


commons = getEntryNames "#{webpackRoot}/commons"
entries = getEntryNames "#{webpackRoot}/entries"
if (_.intersection commons, entries).length > 0
  console.log 'Error: commons and entries may not share the same name'
  return

entryMap = {}
for i, common of commons
  entryMap[common] = "./commons/#{common}"
for i, entry of entries
  entryMap[entry] = "./entries/#{entry}"
wpConf.entry = entryMap


# Add user constants defined in app/webpack/config
wpConf.plugins.push new DefinePlugin appConfig.constants
# attach entries to common code
for common, entryList of appConfig.commons
  wpConf.plugins.push new CommonsChunkPlugin common, 'js/[name].js', entryList






############################################################
# Dev Server Build - uses websockets for live reloading
############################################################
gulp.task 'webpack:dev-server', (callback) ->
  config = JSON.parse fs.readFileSync "#{etcRoot}/dev_defaults.json", 'utf8'
  configCustom = JSON.parse fs.readFileSync "#{etcRoot}/dev.json", 'utf8'
  _.merge config, configCustom

  webpackPort = config.dev.webpackPort

  wpConf.devtool = 'source-map'
  wpConf.debug = true
  wpConf.output.publicPath = "http://#{config.site.domain}:#{webpackPort}/"


  # Start a webpack-dev-server
  new WebpackDevServer webpack(wpConf),
    contentBase: devRoot
    stats:
      colors: true
  .listen webpackPort, 'localhost', (err) ->
    throw new gutil.PluginError('webpack-dev-server', err) if err
    gutil.log '[webpack-dev-server]', "http://#{config.site.domain}:#{webpackPort}/webpack-dev-server"





############################################################
# Distribution build
############################################################
gulp.task 'webpack:build', (callback) ->
  # wpConf = Object.create wpConf
  # Override temporary output path
  wpConf.output.path = path.join projectRoot, 'dist', 'public'

  dedupePlugin = new webpack.optimize.DedupePlugin()
  uglifyPlugin = new webpack.optimize.UglifyJsPlugin()
  wpConf.plugins = wpConf.plugins.concat dedupePlugin, uglifyPlugin

  # run webpack
  webpack wpConf, (err, stats) ->
    throw new gutil.PluginError('webpack:build', err) if err
    gutil.log '[webpack:build]', stats.toString colors: true
    callback()





############################################################
# Dev Build
#
# Use this to review the files in the temporary folder
############################################################
devWpConf = Object.create wpConf
devWpConf.devtool = "sourcemap"
devWpConf.debug = true
# create a single instance of the compiler to allow caching
devCompiler = webpack devWpConf
gulp.task "webpack:dev-build", (callback) ->
  # run webpack
  devCompiler.run (err, stats) ->
    throw new gutil.PluginError("webpack:build-dev", err)  if err
    gutil.log "[webpack:build-dev]", stats.toString(colors: true)
    callback()