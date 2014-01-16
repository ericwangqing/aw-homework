## used both at developing time by jade and runtime by meteor
@BP ||= {}

class Page
  ## 浏览器当前显示的Page，在router中设置。
  @current-page = @last-page = null 
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

    Handlebars.register-helper 'bp-is-shown-list-relation', ~> ## DEVELPOMENT MODE的时候，显示所有关联关系，OPERATION MODE时，在Page页面由当前Page决定，在View页面，由Last Page决定
      if BP.MODE is 'OPERATION' 
        if @current-page then @current-page.show-list-relations else @last-page.show-list-relations
      else
        true

    Handlebars.register-helper 'bp-is-shown-detail-relation', ~> ## DEVELPOMENT MODE的时候，显示所有关联关系，OPERATION MODE时，在Page页面由当前Page决定，在View页面，由Last Page决定
      if BP.MODE is 'OPERATION' 
        if @current-page then @current-page.show-detail-relations else @last-page.show-detail-relations
      else
        true

  @track-page = (new-page)!->
    @last-page = @current-page if @current-page isnt null ## null时表示当前直接加载了View，而不是Page
    @current-page = new-page

  @path-for = (namespace, page-name, doc-name, doc)~>
    page = @registry[namespace][page-name]
    page.get-path doc-name, doc

  @is-page-permit = (doc, action, namespace, page-name)->
    @permission ||= BP.Permission.get-instance!
    @permission.check-page-action-permission namespace, page-name, doc, action

  @get-joint-page-name = (namespace, name)-> "#namespace:#name"

  @parse-namespace-and-name-from-joint-page-name = (joint-page-name)-> 
    tokens = joint-page-name.split ':'
    {namespace: tokens.0, name: tokens[1 to -1].join ':'}

  ({@namespace, @name, @main-nav, @show-list-relations, @show-detail-relations})->
    @show-list-relations = true if @show-list-relations isnt false # 默认显示relation links
    @show-detail-relations = true if @show-detail-relations isnt false # 默认显示relation links
    @template-name = [@namespace, @name].join '-'
    @display-name = @main-nav or @template-name
    @views = []
    @

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
            BP.Page.track-page self # 追踪当前page
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