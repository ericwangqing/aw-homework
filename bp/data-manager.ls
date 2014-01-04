ABSTRACT-METHOD = !-> throw new Meteor.Error "This is a abstract method, you should implemented it first."

# 业务逻辑中，由用户权限和流程权限决定的筛选在服务端完成（Meteor Method），而由用户体验形成的筛选在客户端完成，也即是在template中声明的query，用在这里。
class @BP.Abstract-data-manager
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


class @BP.List-data-manager extends BP.Abstract-data-manager
  (view)->
    @meteor-pub-name = view.names.list-data-publish-name
    @query = "{}"
    @main-data-helper-name = view.names.list-data-retriever-name
    super ...

  subscribe: (params)->
    Meteor.subscribe @meteor-pub-name

  store-data-in-state: !->
    @doc-ids = @collection.find! .fetch! .map -> it._id # 性能：改进查询，或者用Meteor Method，改进性能。
    @set-transferred-state 'doc-ids', @doc-ids

  meteor-template-main-data-helper: ~> # doc: list视图时，将cited的data装配到docs里面，便于用Meteor的each进行遍历
    @docs = @collection.find!fetch!
    @docs.map (doc)~>
      for {doc-name, query, is-multiple} in @cited-data
        collection = BP.Collection.get-by-doc-name doc-name
        eval "query = " + query if typeof query is 'string'
        if is-multiple
          doc[doc-name.pluralize!] = collection.find query .fetch!
        else
          doc[doc-name] = collection.findOne query 
      doc


class @BP.Detail-data-manager extends BP.Abstract-data-manager
  (view)->
    @meteor-pub-name = view.names.detail-data-publish-name
    @query = "{_id: id}"
    @main-data-helper-name = view.names.detail-data-retriever-name
    @auto-insert-fields = {} # for bp-auto-insert helper
    super ...

  subscribe: (params)->
    ready = Meteor.subscribe @meteor-pub-name, @doc-id = params[@view.doc-name + '_id'] # 注意：wait-on实际上在before之前执行！！，所以在这里给@dod-id赋值，而不是在change-to-face里。
    # 这里拿回要渲染的doc，供router的before里，进行is-permit检查
    @doc = @collection.find-one! or {} # incase doc not founded, show empty fields on page instead of thrown errors.
    ready

  store-data-in-state: !->
    @state.set 'doc', @doc 

  create-data-helpers: !->
    super!
    @add-addtional-data-helpers!

  meteor-template-main-data-helper: ~> # doc: detail先将doc查询出，存在state中，然后Meteor的helper从state里面读取。这样方便点击pre、next时，不用经过router。
    @view.ui.doc = @state.get 'doc'

  add-addtional-data-helpers: !->
    for {doc-name, query} in @cited-data
      @data-helpers[doc-name] = @create-data-helper doc-name, query

  create-data-helper: (doc-name, query)->
    self = @
    ->
      collection = BP.Collection.get-by-doc-name doc-name
      if self.is-main-data-available!
        doc = self.doc
        eval "query = " + query if typeof query is 'string'
        collection.findOne query
      else
        self.get-transferred-state doc-name

  is-main-data-available: ->
    @doc and not _.is-empty @doc

  set-previous-and-next-ids: !-> # doc: 从list拿到列表的doc ids并更新pre 和 next
    @doc-ids = @get-transferred-state 'doc-ids'
    if @doc-id and @doc-ids and not _.is-empty @doc-ids
      @update-previous-and-next-ids!

  update-previous-and-next-ids: !-> # doc: 从list拿到列表的doc ids并更新pre 和 next
    pre = next = null
    for id, index in @doc-ids
      break if id is @doc-id
      pre = id
    next = @doc-ids[index + 1] 
    @previous-id = pre
    @next-id = next

