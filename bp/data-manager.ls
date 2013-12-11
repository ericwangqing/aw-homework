ABSTRACT-METHOD = !-> throw new Meteor.Error "This is a abstract method, you should implemented it first."

# doc: 业务逻辑中，由用户权限和流程权限决定的筛选在服务端完成（Meteor Method），而由用户体验形成的筛选在客户端完成，也即是在template中声明的query，用在这里。
class @BP.Abstract-data-manager
  @_state = @state-transferred-across-views = new BP.State '_transfer-state' if Meteor.is-client
  
  (@view)->
    @state = @view.state
    @collection = BP.Collection.get view.names.meteor-collection-name

  get-transferred-state: (attr)-> @@state-transferred-across-views.get attr

  set-transferred-state: (attr, value)-> @@state-transferred-across-views.set attr, value

  publish: !->
    dm = @
    Meteor.publish dm.meteor-pub-name, (id)-> 
      eval "query = " + dm.query-str
      cursor = dm.collection.find query

  subscribe:           (params)->   ABSTRACT-METHOD! # return a (or an array of) Meteor wait object(s) for iron router
  store-data-in-state:        !->   ABSTRACT-METHOD!
  meteor-template-retreiver:   ->   ABSTRACT-METHOD! 


class @BP.List-data-manager extends BP.Abstract-data-manager
  (view)->
    @meteor-pub-name = view.names.list-data-publish-name
    @query-str = "{}"
    super ...

  subscribe: (params)->
    Meteor.subscribe @meteor-pub-name

  store-data-in-state: !->
    @doc-ids = @collection.find! .fetch! .map -> it._id # 性能：改进查询，或者用Meteor Method，改进性能。
    @set-transferred-state 'doc-ids', @doc-ids

  meteor-template-retreiver: -> # doc: 不同于detail，list仅仅在state里面存储doc ids，查询直接用Meteor cursor
    @docs = @collection.find!

class @BP.Detail-data-manager extends BP.Abstract-data-manager
  (view)->
    @meteor-pub-name = view.names.detail-data-publish-name
    @query-str = "{_id: id}"
    @auto-insert-fields = {} # for bp-auto-insert helper
    super ...

  subscribe: (params)->
    Meteor.subscribe @meteor-pub-name, @doc-id = params[@view.name + '_id'] # 注意：wait-on实际上在before之前执行！！，所以在这里给@dod-id赋值，而不是在change-to-face里。

  store-data-in-state: !->
    @doc = @collection.find-one! or {} # incase doc not founded, show empty fields on page instead of thrown errors.
    @state.set 'doc', @doc 

  meteor-template-retreiver: ~> # doc: detail先将doc查询出，存在state中，然后Meteor的helper从state里面读取。这样方便点击pre、next时，不用经过router。
    @view.ui.doc = @state.get 'doc'

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

