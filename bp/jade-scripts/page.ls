## used both at developing time by jade and runtime by meteor
class Page
  @registry = {}
  @create-pages = (pages)->
    [@resume page for page in pages]

  @resume = (page-config)->
    page = new Page page-config
    page.faces = []
    page.path-name = page.template-name
    @@registry[page.namespace] ||= {}
    @@registry[page.namespace][page.name] = page
    [page.add-component-view view-config for view-config in page-config.views]
    page.init!

  ({@namespace, @name, @is-main-nav})->
    @template-name = [@namespace, @name].join '-'
    @views = []

  add-view: (namespace, doc-name, view-name, face-name, query)->
    @views.push {namespace, doc-name, view-name, face-name, query}

  add-component-view: (view-config)!->
    vc = view-config
    component = BP.Component.registry[vc.namespace][vc.doc-name]
    @faces.push {view: component[vc.view-name], vc.face-name}

  init: !->
    @route!
    BP.Component.main-nav-paths.push {@name, path: @path-name} # TODO: 厘清main-nav和second-nav

  route: !->
    self = @
    Router.map !->
      @route self.path-name, do
        path: self.get-path-pattern!
        template: self.template-name
        before: !->
          if not self.is-permit!
            alert "没有权限访问"
            @redirect 'default' # TODO: 改为last page
          else
            self.set-views-current-faces!
            self.store-data-in-state!
        wait-on: ->
          self.subscribe @params


  get-path-pattern: ->
    pattern = "/#{@path-name}"
    for face in @faces
      pattern += face.view.faces[face.face-name]
    pattern

  is-permit: ->
    for face in @faces
      return flase if !face.view.is-permit face.view.data-manager.doc, face.face-name
    true

  set-views-current-faces: !->
    [face.view.current-face-name = face.face-name for face in @faces]
    
  store-data-in-state: !->
    # debugger
    [face.view.data-manager.store-data-in-state! for face in @faces]

  subscribe: (params)!->
   [face.view.data-manager.subscribe params for face in @faces] 


if module? then module.exports = Page else BP.Page = Page # 让Jade和Meteor都可以使用