path = require 'path'
temp = require 'temp'
fs = require 'fs-plus'

describe "Chmod", ->
  [workspaceElement, activationPromise, editor, editorElement] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('chmod')

    directory = temp.mkdirSync()
    atom.project.setPaths([directory])
    filePath = path.join(directory, 'atom-chmod')
    fs.writeFileSync(filePath, '')

    waitsForPromise ->
      atom.workspace.open(filePath).then (_editor) ->
        editor = _editor
        editorElement = atom.views.getView(editor)

  describe "when the atom-chmod:current-file event is triggered", ->
    it "hides and shows the modal panel", ->
      # Before the activation event the view is not on the DOM, and no panel
      # has been created
      expect(workspaceElement.querySelector('.chmod')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.commands.dispatch editorElement, 'chmod:current-file'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(workspaceElement.querySelector('.chmod')).toExist()

        chmodElement = workspaceElement.querySelector('.chmod')
        expect(chmodElement).toExist()

        chmodPanel = atom.workspace.panelForItem(chmodElement)
        expect(chmodPanel.isVisible()).toBe true
        atom.commands.dispatch(chmodElement.querySelector('atom-text-editor'), 'core:cancel')
        expect(chmodPanel.isVisible()).toBe false
