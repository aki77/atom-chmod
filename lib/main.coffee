fs = require 'fs-plus'
path = require 'path'
Promise = require 'bluebird'
InputDialog = require '@aki77/atom-input-dialog'
chmod = Promise.promisify(fs.chmod)
{CompositeDisposable} = require 'atom'

module.exports = AtomChmod =
  subscriptions: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-text-editor',
      'chmod:current-file': ({target}) =>
        return @dialog.close() if @dialog?
        filePath = target?.getModel?()?.getPath?()
        @input(filePath) if filePath and fs.isFileSync(filePath)

    @subscriptions.add atom.commands.add '.tree-view', 'chmod:selected-entry': ({currentTarget: target}) =>
      entry =  target?.querySelector('.selected .name')
      filePath = entry?.dataset.path
      return unless filePath
      @input(filePath)

  deactivate: ->
    @subscriptions.dispose()

  input: (filePath) ->
    stat = fs.statSync(filePath)
    currentMode = stat.mode.toString(8).substr(-3)

    @dialog = new InputDialog(
      elementClass: 'chmod'
      prompt: "Change mode of #{path.basename(filePath)}"
      defaultText: currentMode
      selectedRange: [[0, 0], [0, 3]]
      callback: (mode) ->
        chmod(filePath, parseInt(mode, 8)).catch((error) ->
          atom.notifications.addError('chmod error', detail: error)
        )
      detached: =>
        @dialog = null
      match: /[0-7]/
      validate: (mode) ->
        return 'invalid mode' unless mode.match(/^[0-7]{3}$/)
    )
    @dialog.attach()
