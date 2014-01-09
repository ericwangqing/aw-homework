## View是Component在Web page上的呈现。View使用Data-mananger获取数据。每个View有几种不同的face，face上有一些action（以button和link形式存在）。
# 本文件命名加下划线，因为需要让Meteor在list-view.ls和detail-view.ls之前加载。
class @BP.View
  @registry = {}
  ->
    @@registry[@name] = @
    @names = new BP.Names @namespace, @doc-name
    @permission = BP.Permission.get-instance!
    @create-faces! 
    @create-data-manager!
    if Meteor.is-client
      @links = {}
      @create-ui!
      @create-adapter!

  ## 得到已经添加好link关系的view的path，可以有两种不同参数的调用：
  ## 1）link-name, doc；得到当前view的link path
  ## 2）view-name, link-name, doc；得到name为view-name的view的link path
  get-path: (view, face, doc)-> # TODO：这里要重构
    # doc = doc?.fetch?!0 # 当doc是cursor时，取回doc
    view = @ if view is ''
    if face not in ['previous', 'next'] 
      if view is @ 
        view = @links[face].view
        face-pattern = @links[face].face
        # face = (_.invert view.faces)[face-pattern] # 从face（例如："/assignment/:assignment_id/update"）查回face-name (例如："list")
      else
        view = @@registry[view]
        face-pattern = view.faces[face]
    else
      face-pattern = view.faces[view.current-face-name]

    # docId = if view is @ and doc then doc._id else doc?[view.doc-name + 'Id']
    # face-name = (_.invert view.faces)[face] # 从face（例如："/assignment/:assignment_id/update"）查回face-name (例如："list")
    if face in ['previous', 'next'] or view.is-permit doc, face # previous, next不需要check permission
      view.faces-manager.get-path face-pattern, doc
    else
      null

  change-to-face: (face-name, params)->
    @data-manager.store-data-in-state!
    @current-face-name = face-name

  get-current-action: ~> action = @current-face-name

  current-face-checker: (action-name)~> action-name is @current-face-name

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
  add-to-template-rendered: -> 
    if not _.is-empty @data-manager.cited-data
      @add-relation-data-transfer!
