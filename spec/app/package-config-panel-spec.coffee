PackageConfigPanel = require 'package-config-panel'
packages = require 'packages'

describe "PackageConfigPanel", ->
  [panel, configObserver] = []

  beforeEach ->
    spyOn(packages, 'getAvailable').andCallFake (callback) ->
      available = [
        {
          name: 'p1'
          version: '3.2.1'
        }
        {
          name: 'p2'
          version: '1.2.3'
        }
      ]
      callback(null, available)

    configObserver = jasmine.createSpy("configObserver")
    observeSubscription = config.observe('core.disabledPackages', configObserver)
    config.set('core.disabledPackages', ['toml', 'wrap-guide'])
    configObserver.reset()
    panel = new PackageConfigPanel

  describe 'Installed tab', ->
    it "lists all installed packages, with an unchecked checkbox next to packages in the core.disabledPackages array", ->
      treeViewTr = panel.installed.packageTableBody.find("tr[name='tree-view']")
      expect(treeViewTr).toExist()
      expect(treeViewTr.find("input[type='checkbox']").attr('checked')).toBeTruthy()

      tomlTr = panel.installed.packageTableBody.find("tr[name='toml']")
      expect(tomlTr).toExist()
      expect(tomlTr.find("input[type='checkbox']").attr('checked')).toBeFalsy()

      wrapGuideTr = panel.installed.packageTableBody.find("tr[name='wrap-guide']")
      expect(wrapGuideTr).toExist()
      expect(wrapGuideTr.find("input[type='checkbox']").attr('checked')).toBeFalsy()

    describe "when the core.disabledPackages array changes", ->
      it "updates the checkboxes for newly disabled / enabled packages", ->
        config.set('core.disabledPackages', ['wrap-guide', 'tree-view'])
        expect(panel.find("tr[name='tree-view'] input[type='checkbox']").attr('checked')).toBeFalsy()
        expect(panel.find("tr[name='toml'] input[type='checkbox']").attr('checked')).toBeTruthy()
        expect(panel.find("tr[name='wrap-guide'] input[type='checkbox']").attr('checked')).toBeFalsy()

    describe "when a checkbox is unchecked", ->
      it "adds the package name to the disabled packages array", ->
        panel.find("tr[name='tree-view'] input[type='checkbox']").attr('checked', false).change()
        expect(configObserver).toHaveBeenCalledWith(['toml', 'wrap-guide', 'tree-view'])

    describe "when a checkbox is checked", ->
      it "removes the package name from the disabled packages array", ->
        panel.find("tr[name='toml'] input[type='checkbox']").attr('checked', true).change()
        expect(configObserver).toHaveBeenCalledWith(['wrap-guide'])

  describe 'Available tab', ->
    it 'lists all available packages', ->
      expect(panel.available.children('.panel').length).toBe 2
      expect(panel.available.children('.panel:first').view().name.text()).toBe 'p1'
      expect(panel.available.children('.panel:last').view().name.text()).toBe 'p2'
