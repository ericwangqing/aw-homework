## used both at developing time by jade and runtime by meteor

class Page
  ## 浏览器当前显示的Page，在router中设置。
  @current-page = null 
  @registry = {}
  @create-pages = (pages)->
    [@resume page for page in pages]
    @add-meteor-helpers! if Meteor.is-client

  @resume = (page-config)->
    page = new Page page-config
    page.faces = []
    page.path-name = page.template-name
    @registry[page.namespace] ||= {}
    @registry[page.namespace][page.name] = page
    [page.add-component-view view-config for view-config in page-config.views]
    page.init!

  @add-meteor-helpers = !->
    Handlebars.register-helper 'bp-is-page', (namespace, name)~>
      @current-page and namespace is @current-page.namespace and name is @current-page.name 

  @path-for = (namespace, page-name, doc-name, doc)~>
    page = @registry[namespace][page-name]
    page.get-path doc-name, doc

  ({@namespace, @name, @main-nav})->
    @template-name = [@namespace, @name].join '-'
    @display-name = @main-nav or @template-name
    @views = []

  add-view: (namespace, doc-name, view-name, face-name, query)->
    @views.push {namespace, doc-name, view-name, face-name, query}

  add-component-view: (view-config)!->
    vc = view-config
    component = BP.Component.registry[vc.namespace][vc.doc-name]
    view = component[vc.view-name]
    view.page-query = vc.query 
    @faces.push {view: view, vc.face-name}

  init: !->
    @route!
    BP.Nav.add-main-nav {name: @display-name, path: @path-name} if @main-nav
    BP.Nav.add-second-nav {name: @display-name, path: @path-name} if @second-nav

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
            BP.Page.current-page = self # 追踪当前page
            self.config-views @params
        wait-on: ->
          self.subscribe @params

  get-path-pattern: ->
    pattern = "/#{@path-name}"
    for face in @faces
      pattern += face.view.faces[face.face-name]
    pattern

  get-path: (doc-name, doc)->
    path = "/#{@path-name}"
    for face in @faces
      id = @get-face-id face, doc-name, doc
      path += face.view.faces-manager.get-path face.view.faces[face.face-name], id
    path

  get-face-id: (face, doc-name, doc)->
    id = if face.view.doc-name is doc-name then doc._id else doc[doc-name + 'Id']

  is-permit: ->
    for face in @faces
      return flase if !face.view.is-permit face.view.data-manager.doc, face.face-name
    true

  config-views: (params)!->
    @set-views-current-faces!
    @filter-list-views-data params
    @store-data-in-state!

  set-views-current-faces: !->
    [face.view.current-face-name = face.face-name for face in @faces]

  filter-list-views-data: (params)!->
    [face.view.data-manager.query = @apply-query-on-params face.view.page-query, params for face in @faces when face.view.type is 'list' and face.view.page-query]

  store-data-in-state: !->
    # debugger
    [face.view.data-manager.store-data-in-state! for face in @faces]

  apply-query-on-params: (query, params)->
    eval 'query = ' + query
    query

  subscribe: (params)!->
   [face.view.data-manager.subscribe params for face in @faces] 

if module? then module.exports = Page else BP.Page = Page # 让Jade和Meteor都可以使用