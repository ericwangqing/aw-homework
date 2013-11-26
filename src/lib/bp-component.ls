@BP ||= {}
top = @

# Bpc：B Plus Component
# 每个Bpc对应一种数据（doc），每种doc构成一个collection，有List和Detail两种templates
# list：列表该collection的doc，对应实现对doc的删除操作，并给出和去”添加“和去”修改“的链接（按钮）
# detail：展示一个doc的详情，对应修改、添加和评论操作
# 命名约定见：http://my.ss.sysu.edu.cn/wiki/pages/viewpage.action?pageId=243892266
class @BP.Component # Facade of BP
  @bpcs = []
  # Facade of other BP module
  # 这里meteor的加载顺序似乎有问题，所以用了函数封装下
  @collection-paths = -> BP.Router.collections-lists-routes
  @add-routes = -> BP.Router.route!
  
  (doc-name)->
    create-names.apply @, &
    create-collection.apply @
    create-list-helper.apply @
    create-detail-helper.apply @
    create-router.apply @
    @@bpcs.push @

  init: !->
    if Meteor.is-server
      @publish-data!
    if Meteor.is-client
      @list-helper.init!
      @detail-helper.init!
      @router.add-routes!

  publish-data: !->
    # console.log "published-name: ", published-name
    Future = Npm.require 'fibers/future'
    Meteor.publish @names.meteor-collection-name, ~> 
      future = new Future
      Meteor.set-timeout !~>
        # console.log ""
        cursor = top[@names.meteor-collection-name].find!
        future.return cursor
      , 200
      future.wait!

/* ------------------------ Private Methods ------------------- */
create-names = !(doc-name)->
  @names = 
    doc-name: doc-name
    mongo-collection-name: doc-name.pluralize!
    meteor-collection-name: doc-name.pluralize!capitalize!
    list-template-name: doc-name.pluralize! + '-list'
    list-data-retriever-name: doc-name.pluralize!
    detail-template-name: doc-name
    detail-data-retriever-name: doc-name
    route-path: doc-name.pluralize! 
    collection-path-name: doc-name.pluralize! 
    doc-path-name: doc-name 

create-collection = !->
  @collection = top[@names.meteor-collection-name] = new Meteor.Collection @names.mongo-collection-name

create-list-helper = !->
  if Meteor.is-client
    @list-helper = BP.Helper.get-helper @names, @collection, 'list' 

create-detail-helper = !->
  if Meteor.is-client
    @detail-helper = BP.Helper.get-helper @names, @collection, 'detail' 

create-router = !->
  if Meteor.is-client
    @router = new BP.Router @names
    @list-helper.router = @detail-helper.router = @router




       


