@BP ||= {}
top = @

# Bpc：B Plus Component
# 每个Bpc对应一种数据（doc），每种doc构成一个collection，有List和Detail两种templates
# list：列表该collection的doc，对应实现对doc的删除操作，并给出和去”添加“和去”修改“的链接（按钮）
# detail：展示一个doc的详情，对应修改、添加和评论操作
class @BP.Component 
  # Facade of other BP module
  # 这里meteor的加载顺序似乎有问题，所以用了函数封装下。按道理现在BPC在BPR的外层目录，应该在BPR之后加载，但是事实上却不是。故而hack。
  @collection-paths = -> BP.Router.collections-lists-routes # 给布局模板自动生成主导航（main-nav）用。
  @add-routes = -> BP.Router.route! # 给应用程序启动应用时初始化BP Router用
  
  (doc-name)->
    create-names.apply @, & # names中有此BP Component用的各种名字，如collection、template、helper等等名称。这里贯彻BP的命名规范。
    create-collection.apply @
    create-list-helper.apply @
    create-detail-helper.apply @
    create-router.apply @

  init: !->
    if Meteor.is-server
      @publish-data!
    if Meteor.is-client
      @list-helper.init!
      @detail-helper.init!
      @router.add-routes!

  get-path: (action, doc)~> # 给Template用（通过BPC Facade暴露出去）
    @names[action + 'RoutePath'] doc?._id

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
                                      id ||= ':_id'
                                      _base-route-path + "/#id"

create-collection = !->
  @collection = top[@names.meteor-collection-name] = new Meteor.Collection @names.mongo-collection-name

create-list-helper = !->
  if Meteor.is-client
    @list-helper = BP.Template-Helper.get-helper @, 'list' 

create-detail-helper = !->
  if Meteor.is-client
    @detail-helper = BP.Template-Helper.get-helper @, 'detail' 

create-router = !->
  if Meteor.is-client
    @router = new BP.Router @
    # @router.add-routes!





       


