@BP ||= {}
top = @
if Meteor.is-client
  do enable-handlebar-switch-bpcs-in-its-rendering = !->
    Handlebars.register-helper 'bp-load-bpc', (view-name)-> BP.Component.bpcs[view-name].init!

# Bpc：B Plus Component
# 每个Bpc对应一个View
class @BP.Component 
  # Facade of other BP module
  @bpcs = {} # hold all bpc for using
  @main-nav-paths = []
  @create-bpc-for-views = (views)->
    BP.View.resume-views views 
    for view-name, view of BP.View.registry
      @create-bpc view

  @create-bpc = (view, is-composed=false)->
    if _.is-empty view.composed-views
      bpc = new List-Component view, is-composed if view.type is 'list'
      bpc = new Detail-Component view, is-composed if view.type is 'detail'
    else
      bpc = new Composite-Component view, is-composed
    bpc


  (@view, @is-composed)->
    create-names.call @, @view.doc-name # names中有此BP Component用的各种名字，如collection、template、helper等等名称。这里贯彻BP的命名规范。
    create-collection.apply @
    if Meteor.is-client
      create-router.apply @ if not @is-composed
      create-helper.apply @ 
      @@bpcs[@view.name] = @ 
      # @.init! # 注意：在这里初始化，而不是在router的before方法里，存在风险！因为这样一个页面有多个同名template时，运行时，用到的helper将会是最后一个出现的template的helper，也就会调用回它的state！


  init: !->
  # init: !->
    [comp.init! for comp in @composed-components] if @composed-components?
    @helper.init!


  get-state: (attr)-> @view.state.get attr
  set-state: (attr, value)!-> @view.state.set attr, value


  get-path: (action, doc-or-doc-id)~> # 给Template用（通过BPC Facade暴露出去）# view-name 为detail和list时，可以缺省
    id  = if typeof doc-or-doc-id is 'object' then doc-or-doc-id?._id else doc-or-doc-id
    @view.get-link-path action, id

  publish-data: !->
    # _defered-publish-data! # 延时pub，模拟网络缓慢、测试nProgress
    Meteor.publish @names.meteor-collection-name, ~> 
      cursor = top[@names.meteor-collection-name].find!

class List-Component extends BP.Component
  ->
    super ...
    
class Detail-Component extends BP.Component
  ->
    super ...

class Composite-Component extends BP.Component
  (view, is-composed)->
    @composed-components = [(@@create-bpc composed-view, true) for name, composed-view of view.composed-views]
    super ...


    
    
/* ------------------------ Private Methods ------------------- */
# 命名约定见：http://my.ss.sysu.edu.cn/wiki/pages/viewpage.action?pageId=243892266
create-names = !(doc-name)-> 
  @names = new BP.Names doc-name

create-collection = !->
  if not top[@names.meteor-collection-name]
    top[@names.meteor-collection-name] = new Meteor.Collection @names.mongo-collection-name
    @publish-data! if Meteor.is-server
  @collection = top[@names.meteor-collection-name]


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





       


