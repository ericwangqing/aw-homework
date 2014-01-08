ABSTRACT-METHOD = !-> throw new Meteor.Error "This is a abstract method, you should implemented it first."
@BP ||= {}
# 业务逻辑中，由用户权限和流程权限决定的筛选在服务端完成（Meteor Method），而由用户体验形成的筛选在客户端完成，也即是在template中声明的query，用在这里。
class BP.Abstract-data-manager
  @_state = @state-transferred-across-views = new BP.State '_transfer-state' if Meteor.is-client
  
  (@view)->
    @cited-data = []
    @state = new BP.State view.name if Meteor.is-client
    @collection = BP.Collection.get view.names.meteor-collection-name
    @set-cited-data! # {doc-name, query}, query仅用于在客户端查询数据，publish时不用
    @create-data-helpers! # {meteor-template-helper-name, helper-fn}

  set-cited-data: !->
    relations = BP.Relation.registry[@view.doc-name]
    for relation in relations
      related = relation.get-opposite-end(@view.doc-name)
      @cited-data.push {doc-name: related.doc-name, query: (relation.get-query related.doc-name), is-multiple: (related.multiplicity isnt '1')}
    # @cited-data = [{doc-name: relation.get-opposite-end(@doc-name).doc-name, query: relation.get-query }]
    # @cited-data = [cite <<< doc-name: doc-name for doc-name, cite of @view.cited]

  get-transferred-state: (attr)-> @@state-transferred-across-views.get attr

  set-transferred-state: (attr, value)-> @@state-transferred-across-views.set attr, value

  publish: !->
    cited-config = [{doc-name: cited.doc-name, query: {}} for cited in @cited-data]
    @publish-collections cited-config ++ {doc-name: @view.doc-name, @query}

  publish-collections: (config)!-> 
    dm = @
    permission = BP.Permission.get-instance!
    Meteor.publish dm.meteor-pub-name, (id)-> 
      ({doc-name, query}) <~ _.map config
      collection = BP.Collection.get-by-doc-name doc-name
      eval "query = " + query if typeof query is 'string'
      # 在这里实现权限控制里的view级控制。用户没有权限时，相应的数据（整条，或者某些属性）将不会publish。
      {query, projection} = permission.add-constrain-on-query @user-id, doc-name, query 
      collection.find query, projection

  create-data-helpers: !->
    @data-helpers = {}
    @data-helpers[@main-data-helper-name] = @meteor-template-main-data-helper

  #### return a (or an array of) Meteor wait object(s) for iron router
  subscribe:           (params)->   ABSTRACT-METHOD! 
  store-data-in-state:        !->   ABSTRACT-METHOD!
  meteor-template-main-data-helper:   ->   ABSTRACT-METHOD! 