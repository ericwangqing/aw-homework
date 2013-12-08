class @BP.Detail-view extends BP.View
  ->
    super ...
    @auto-insert-fields = {}
    
  create-pub-sub: !->
    @pub-sub = if @is-referred then
      name: 'ref-' + @names.meteor-collection-name # referred 需要订阅一个集合，而不是一个doc
      query: @query
    else
      name: @names.doc-name
      query: "{_id: id}"

  create-view-appearances: !-> # doc: 目前reference只支持 detail类型。
    @id-place-holder = ':' + @name + '_id'
    @appearances = 
      create    : '/' + @name + '/create'
      update    : '/' + @name + '/' + @id-place-holder + '/update'   
      view      : '/' + @name + '/' + @id-place-holder + '/view'     
      reference : '/' + @name + '/' + @id-place-holder + '/reference' 

  get-appearance-path: (appearance, doc-or-doc-id)-> 
    return null if not doc-or-doc-id
    id = if typeof doc-or-doc-id is 'string' then doc-or-doc-id else doc-or-doc-id._id
    path-pattern = if typeof appearance is 'function' then appearance! else appearance
    path-pattern?.replace @id-place-holder, id

  data-retriever: ~>
    @ui.doc = @state.get 'doc'
    # @collection.find-one _id: @doc-id

  retreive-as-ref-view: ->
    @state.get 'doc'

  retrieve-as-main-view: ->
    doc = if @current-appearance-name is 'create' then {} else
      @collection.find-one _id: @doc-id

  retrieve-as-referred-view: ->
    docs = @collection.find @pub-sub.query .fetch!
    @state.set 'docs' docs
    doc = docs?[0] or {}

  subscribe-data: (params)->
    Meteor.subscribe @pub-sub.name, @doc-id = params[@name + '_id'] # 注意：wait-on实际上在before之前执行！！，所以在这里给@dod-id赋值，而不是在change-to-appearance里。

  change-to-appearance: (appearance-name, params)->
    BP.RRR = @ # 调试
    super ...
    @doc-ids = @@transfer-state-between-views.get 'doc-ids'
    if @doc-id and @doc-ids and not _.is-empty @doc-ids
      @update-previous-and-next-ids!
    doc = if @is-referred then @retreive-as-ref-view! else @retrieve-as-main-view! 
    @state.set 'doc' doc

  update-previous-and-next-ids: !->
    pre = next = null
    for id, index in @doc-ids
      break if id is @doc-id
      pre = id
    next = @doc-ids[index + 1] 
    @previous-id = pre
    @next-id = next

  create-ui: !->
    @ui = new BP.Form @


