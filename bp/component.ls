@BP ||= {}
top = @

do enable-handlebar-switch-bpcs-in-its-rendering = !->
  Handlebars.register-helper 'bp-load-bpc', (view-name)-> BP.Component.bpcs[view-name].init!

# Bpc：B Plus Component
# 每个Bpc对应一个View
class @BP.Component 
  # Facade of other BP module
  @bpcs = {} # hold all bpc for using
  @main-nav-paths = []
  create-bpc-for-views = (views)->
    bpcs = {}
    BP.View.resume-views views
    for view-name, view of BP.View.registry
      if view.type is 'list'
        bpc = new BP.List-Component view
      else if view.type is 'detail'
        bpc = new BP.Detail-Component view
      else
        throw new Error "the '#view.type' type of bpc is not suppor yet."
      @bpcs[view-name] = bpcs[view-name] = bpc
    bpcs

  (@view)->
    @doc-name = @view.doc-name
    create-names.apply @, & # names中有此BP Component用的各种名字，如collection、template、helper等等名称。这里贯彻BP的命名规范。
    if Meteor.is-client
      create-router.apply @
      create-helper.apply @ 

  init: !->
    create-collection.apply @
  # init: !->
    if Meteor.is-server
      @publish-data!
    if Meteor.is-client
      @helper.init!


  get-state: (attr)-> @view.state.get attr
  set-state: (attr, value)!-> @view.state.set attr, value


  get-path: (action, doc-or-doc-id)~> # 给Template用（通过BPC Facade暴露出去）# view-name 为detail和list时，可以缺省
    id  = if typeof doc-or-doc-id is 'object' then doc-or-doc-id?._id else doc-or-doc-id
    @view.get-path action, id

  publish-data: !->
    # _defered-publish-data! # 延时pub，模拟网络缓慢、测试nProgress
    Meteor.publish @names.meteor-collection-name, ~> 
      cursor = top[@names.meteor-collection-name].find!

class List-Component extends BP.Component
  (@view)->
    super ...
    
class Detail-Component extends BP.Component
  (@view)->
    super ...

class Composite-Component extends BP.Component
  (@view)->
    @composed-components = @@create-bpc-for-views @view.composed-views
    super ...


    
    
/* ------------------------ Private Methods ------------------- */
# 命名约定见：http://my.ss.sysu.edu.cn/wiki/pages/viewpage.action?pageId=243892266
create-names = !(doc-name)->
  @names = 
    # -------------- doc和collection名称 ----------------------
    doc-name                    :   doc-name
    mongo-collection-name       :   doc-name.pluralize!
    meteor-collection-name      :   doc-name.pluralize!capitalize!

    # -------------- Template和其方法名称 ----------------------
    list-template-name          :   doc-name.pluralize!  + '-list'
    list-data-retriever-name    :   doc-name.pluralize!
    detail-template-name        :   doc-name
    detail-data-retriever-name  :   doc-name

    # -------------- Route名称和路径 --------------------------
  _base-route-name              =   doc-name.pluralize! 
  _base-route-path              =   '/' + doc-name.pluralize!
  @names <<< do
    list-path-name              :   _base-route-name
    list-route-path             :   -> _base-route-path
    create-path-name            :   _base-route-name    + '-create'
    create-route-path           :   -> _base-route-path + '/create'
    delete-path-name            :   _base-route-name    + '-delete'
    delete-route-path           :   -> _base-route-path + '/delete'
    update-path-name            :   _base-route-name    + '-update'
    update-route-path           :   (id) ->
                                      id ||= ':_id' # 前者用于生成链接（Template），后者用于匹配链接（Router）
                                      _base-route-path + "/#id/update"
    view-path-name              :   _base-route-name    + '-view'
    view-route-path             :   (id) ->
                                      id ||= ':_id' # 前者用于生成链接（Template），后者用于匹配链接（Router）
                                      _base-route-path + "/#id/view"

create-collection = !->
  @collection = top[@names.meteor-collection-name] = new Meteor.Collection @names.mongo-collection-name

# create-state = !->
#   if Meteor.is-client
#     @state = new BP.State @names.doc-name

create-helper = !->
  if @view.type is 'list'
    @helper = BP.Template-Helper.get-helper @, 'list' 
  else if @view.type is 'detail'
    @helper = BP.Template-Helper.get-helper @, 'detail' 

create-router = !->
  @router = new BP.Router @
    # @router.add-routes!





       


