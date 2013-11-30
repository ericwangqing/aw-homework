@BP ||= {}
top = @

# Bpc：B Plus Component
# 每个Bpc对应一种数据（doc），每种doc构成一个collection，有List和Detail两种templates
# list：列表该collection的doc，对应实现对doc的删除操作，并给出和去”添加“和去”修改“的链接（按钮）
# detail：展示一个doc的详情，对应修改、添加和评论操作
class @BP.Component 
  # Facade of other BP module
  # 这里meteor的加载顺序似乎有问题，所以用了函数封装下。按道理现在BPC在BPR的外层目录，应该在BPR之后加载，但是事实上却不是。故而hack。
  @bpcs = {} # hold all bpc for using
  @collection-paths = -> BP.Router.collections-lists-routes # 给布局模板自动生成主导航（main-nav）用。
  @custom-main-nav-paths = -> BP.Router.custom-main-nav-paths # 扩展点，应用程序在这里添加自己的一级导航
  @add-routes = -> BP.Router.route! # 给应用程序启动应用时初始化BP Router用
  @add-main-nav = (path)-> BP.Router.add-main-nav path

  if Meteor.is-client
    Handlebars.register-helper 'bp-register-view', @add-view-to-bpc = (doc-name, template-name, view-id)!~>
      bpc = @find-bpc-by-template-name doc-name
      bpc.initial-view template-name, view-id

    @find-bpc-by-template-name = (doc-name)!->
      for bpc in Object.values @bpcs
        return bpc if bpc.names.doc-name is doc-name  

  (doc-name)->
    @templates = {}
    create-names.apply @, & # names中有此BP Component用的各种名字，如collection、template、helper等等名称。这里贯彻BP的命名规范。
    create-collection.apply @
    # create-state.apply @
    create-list-helper.apply @
    create-detail-helper.apply @
    create-router.apply @
  # init: !->
    if Meteor.is-server
      @publish-data!
    if Meteor.is-client
      @list-helper.init!
      @detail-helper.init!
      @router.add-routes!
    @@bpcs[doc-name] = @

  add-template-view: (template-name, view-id)!->
    @templates[template-name] ||= {}
    @templates[template-name][view-id] ||= @current-view = new BP.View template-name, view-id

  initial-view: (template-name, view-id)!->
    @add-template-view template-name, view-id

  get-state: (attr)-> @current-view.state.get attr
  set-state: (attr, value)!-> @current-view.state.set attr, value
  update-pre-next: (doc-id)!-> @current-view.state.update-pre-next doc-id
  # get-template-views: (template-name)->
  #   for name, views of @templates
  #     return v
  #   Object.keys @templates, (template-name)->
  #       @templates if name is template-name


  get-path: (action, doc-or-doc-id)~> # 给Template用（通过BPC Facade暴露出去）
    id  = if typeof doc-or-doc-id is 'object' then doc-or-doc-id?._id else doc-or-doc-id
    @names[action + 'RoutePath'] id

  publish-data: !->
    # _defered-publish-data! # 延时pub，模拟网络缓慢、测试nProgress
    Meteor.publish @names.meteor-collection-name, ~> 
      cursor = top[@names.meteor-collection-name].find!

  _defered-publish-data: !-> 
    Future = Npm.require 'fibers/future'
    Meteor.publish @names.meteor-collection-name, ~> 
      future = new Future
      Meteor.set-timeout !~>
        # console.log ""
        cursor = top[@names.meteor-collection-name].find!
        future.return cursor
      , 200
      future.wait!

  # Facade of other BP modules

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
    view-path-name            :   _base-route-name    + '-view'
    view-route-path           :   (id) ->
                                      id ||= ':_id' # 前者用于生成链接（Template），后者用于匹配链接（Router）
                                      _base-route-path + "/#id/view"

create-collection = !->
  @collection = top[@names.meteor-collection-name] = new Meteor.Collection @names.mongo-collection-name

# create-state = !->
#   if Meteor.is-client
#     @state = new BP.State @names.doc-name

create-list-helper = !->
  if Meteor.is-client
    @list-helper = BP.Template-Helper.get-helper @, 'list' 
    # @initial-view @names.list-template-name

create-detail-helper = !->
  if Meteor.is-client
    @detail-helper = BP.Template-Helper.get-helper @, 'detail' 
    # @initial-view @names.detail-template-name


create-router = !->
  if Meteor.is-client
    @router = new BP.Router @
    # @router.add-routes!





       


