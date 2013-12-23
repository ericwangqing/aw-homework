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
    view = (@create-view-by-type jade-view.type) <<< jade-view
    view = (@create-view-by-type jade-view.type) <<< jade-view
    view.init!
    @registry[view.name] = view
    

  @create-view-by-type = (type)->
    if type is 'list' then new BP.List-view! else new BP.Detail-view!

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
    @permission = BP.Permission.get-instance!
    if Meteor.is-client
      @links = {}
      @state = new BP.State @name
      @create-faces! 
      @create-ui!
    @create-data-manager!

  get-path: (link-name, doc)->
    {view, face} = @links[link-name]
    face-name = (_.invert view.faces)[face] # 从face（例如："/assignment/:assignment_id/update"）查回face-name (例如："list")
    if link-name in ['previous', 'next'] or @is-permit doc, face-name # previous, next不需要check permission
      view.faces-manager.get-path face, doc
    else
      null

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
          # self.change-to-face face-name, @params
          if not self.is-permit self.data-manager.doc, face-name
            alert "你没有权限访问该页面"
            @redirect 'default'
          else
            self.change-to-face face-name, @params
        wait-on: -> # 注意：wait-on实际上在before之前执行！！
          self.data-manager.subscribe @params

  is-permit: (doc, face, cited-doc-name, cited-view-type)~> 
    doc-name = if typeof cited-doc-name is 'string' then cited-doc-name else @doc-name
    type = if typeof cited-view-type is 'string' then cited-view-type else @type
    action = if typeof face is 'string' then face else @faces-manager.get-action-by-face face
    if type is 'detail'
      @permission.check-detail-action-permission doc-name, doc, action
    else
      @permission.check-list-action-permission doc-name, doc, action

  is-attribute-permit:  (doc, attr, action, cited-doc-name)~>
    doc-name = if typeof cited-doc-name is 'string' then cited-doc-name else @doc-name # 有cited-doc-name的时候是ref
    @permission.check-attribute-action-permission doc-name, doc, attr, action


  # ----------------------------- Hooks 留给客户化定制时，在这里插入各种渲染后的逻辑 ---------------
  add-to-template-rendered: (methods)!-> []# ABSTRACT-METHOD
  # add-to-template-row-meteor-rendered: (methods)!-> []# ABSTRACT-METHOD
