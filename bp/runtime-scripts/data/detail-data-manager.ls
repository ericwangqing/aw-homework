class @BP.Detail-data-manager extends BP.Abstract-data-manager
  (view)->
    @meteor-pub-name = view.names.detail-data-publish-name
    @query = "{_id: id}"
    @main-data-helper-name = view.names.detail-data-retriever-name
    @auto-insert-fields = {} # for bp-auto-insert helper
    super ...

  subscribe: (params)->
    ready = Meteor.subscribe @meteor-pub-name, @doc-id = params[@view.faces-manager.id-name] # 注意：wait-on实际上在before之前执行！！，所以在这里给@dod-id赋值，而不是在change-to-face里。
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
    for {doc-name, query, is-multiple} in @cited-data
      helper-name = if is-multiple then doc-name.pluralize! else doc-name
      @data-helpers[helper-name] = @create-data-helper doc-name, is-multiple, query



  create-data-helper: (doc-name, is-multiple, query)->
    @_create-data-helper(doc-name, is-multiple, query, is-for-template = true)

  _create-data-helper: (doc-name, is-multiple, query, is-for-template)->
    self = @
    ->
      collection = BP.Collection.get-by-doc-name doc-name
      if not is-for-template or self.is-main-data-available!
        doc = self.doc
        eval "query = " + query if typeof query is 'string'
        if is-multiple
          collection.find query
        else
          collection.findOne query
      else
        self.get-transferred-state doc-name



  is-main-data-available: ->
    @doc and not _.is-empty @doc

  set-previous-and-next-ids: !-> # doc: 从list拿到列表的doc ids并更新pre 和 next
    @doc-ids = @get-transferred-state @view.doc-name + '-doc-ids'
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

  get-doc-data: ({source, attr, option, value, query, multiple})-> # source 为当前doc的某个relation，或者当前doc
    query ||= {}
    if @doc[source] 
      data-source = @doc[source]
    else
      # cursor-or-data = @data-helpers[source]! # 注意，这里不能直接用已有的data-helpers，这里的query要是全部
      data-helper = @_create-data-helper source, multiple, query, is-for-template = false
      data-source = if multiple then data-helper!fetch! else data-helper!
    
    data-source = [data-source] if not _.is-array data-source
    value  ||= '_id'
    option ||= value

    # TODO: 以下需要考虑重复值的情况
    results = []
    for data in data-source
      id = if value then data[value] else data
      text = if option then data[option] else data
      text ||= ''
      results.push {id, text}
    results