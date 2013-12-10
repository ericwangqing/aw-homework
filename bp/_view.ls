# 本文件命名加下划线，因为需要让Meteor在list-view.ls和detail-view.ls之前加载。
class @BP.View extends BP._View
  @doc-grouped-views = @_dgv = {}

  @register-in-doc-grouped-views = (view)!->
    @_dgv[view.doc-name] ||= {}
    @_dgv[view.doc-name][view.type] = view

  @resume-views = !(jade-views, customized-view-class-name, type)->
    for view-name, jade-view of jade-views
      @registry[view-name] = view = @resume-view jade-view, customized-view-class-name, type
      @register-in-doc-grouped-views view
    # @create-referred-views!
    @wire-views-appearances! if Meteor.is-client

  @resume-view = (jade-view, customized-view-class-name, type)->
    view = (@create-view-by-type jade-view.type, customized-view-class-name, type) <<< jade-view
    view.init!
    @registry[view.name] = view
    
  @create-view-by-type = (type, customized-view-class-name, customized-type)->
    if customized-view-class-name and type is customized-type
      eval "view = new #{customized-view-class-name}();" 
    else
      view =  if type is 'list' then new BP.List-view! else new BP.Detail-view!
    view

  @wire-views-appearances = !->
    for doc-name, {list, detail} of @doc-grouped-views
      list.add-links detail
      detail.add-links list

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

