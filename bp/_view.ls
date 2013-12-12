# 本文件命名加下划线，因为需要让Meteor在list-view.ls和detail-view.ls之前加载。
class @BP.View extends BP._View
  @doc-grouped-views = @_dgv = {}

  @register-in-doc-grouped-views = (view)!->
    @_dgv[view.doc-name] ||= {}
    @_dgv[view.doc-name][view.type] = view

  @resume-views = !(jade-views)->
    for view-name, jade-view of jade-views
      @registry[view-name] = view = @resume-view jade-view
      @register-in-doc-grouped-views view
    # @create-referred-views!
    @wire-view-links! if Meteor.is-client

  @resume-view = (jade-view)->
    view = (@create-view-by-type jade-view.custom-class, jade-view.type) <<< jade-view
    view.init!
    @registry[view.name] = view
    
  @create-view-by-type = (customized-view-class-name, type)->
    # view =  if type is 'list' then new BP.List-view! else new BP.Detail-view!
    if customized-view-class-name
      eval "view = new #{customized-view-class-name.camelize()}();"
    else
      view =  if type is 'list' then new BP.List-view! else new BP.Detail-view!
    view

  @wire-view-links = !->
    @wire-default-list-detail-views!
    @wire-additional-view-links!

  @wire-default-list-detail-views = !->
    for doc-name, {list, detail} of @doc-grouped-views
      list.add-links detail
      detail.add-links list

  @wire-additional-view-links = !->
    [@wire-addtional-links view for view-name, view of @registry]
      
  @wire-addtional-links = (view)!->
    for link in view.additional-links
      [doc-name, view-type, face-name] = link.to.split '.'
      to-view = @doc-grouped-views[doc-name][view-type]
      view.links[link.path.camelize(false)] = view: to-view, face: to-view.faces[face-name]

  init: ->
    @names = new BP.Names @doc-name
    if Meteor.is-client
      @links = {}
      @state = new BP.State @name
      @create-faces! 
      @create-ui!
    @create-data-manager!

  get-path: (link-name, doc)->
    {view, face} = @links[link-name]
    view.faces-manager.get-path face, doc

  change-to-face: (face-name, params)->
    @data-manager.store-data-in-state!
    @current-face-name = face-name

  get-current-action: ~> action = @current-face-name

  current-action-checker: (action-name)~> action-name is @current-face-name

  route: !->
    self = @
    (path-pattern, face-name) <~! _.each @faces
    path-name = @faces-manager.get-path-name face-name
    Router.map !->
      @route path-name, do
        path: path-pattern
        template: self.template-name
        before: !->
          self.change-to-face face-name, @params
        wait-on: -> # 注意：wait-on实际上在before之前执行！！
          self.data-manager.subscribe @params
  
  # ----------------------------- Hooks 留给客户化定制时，在这里插入各种渲染后的逻辑 ---------------
  add-to-template-rendered: (methods)!-> []# ABSTRACT-METHOD
  # add-to-template-row-meteor-rendered: (methods)!-> []# ABSTRACT-METHOD
