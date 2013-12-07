class @BP.View extends BP._View
  @doc-grouped-views = @_dgv = {}
  @transfer-state-between-views = new BP.State '_transfer-state' if Meteor.is-client

  @register-in-doc-grouped-views = (view)!->
    @_dgv[view.doc-name] ||= {}
    @_dgv[view.doc-name][view.type] = view

  @resume-views = !(jade-views)->
    for view-name, jade-view of jade-views
      @registry[view-name] = view = @resume-view jade-view
      @register-in-doc-grouped-views view
    # @create-referred-views!
    @wire-views-appearances! if Meteor.is-client

  @resume-view = (jade-view)->
    view = (@create-view-by-type jade-view.type) <<< jade-view
    view.init!
    view
    
  @create-view-by-type = (type)->
    if type is 'list' then new List-view! else new Detail-view!

  @create-referred-views = !->
    View = @
    (view, view-name)                             <-! _.each View.registry
    (reference-view-config, reference-view-name)  <-! _.each view.referred-views
    referred-view = View.create-referred-view reference-view-name, reference-view-config
    view.referred-views[reference-view-name] = referred-view # doc: referred views 不在 View#registry里面登记，通过bp-load-view的helper切换view，而不是Router切换。

  @create-referred-view = (name, config)->
    origin = @registry[config.referred-view-name]
    view = @create-view-by-type origin.type
    view.doc-name = origin.doc-name
    view.template-name = origin.template-name
    view.name = name
    view.is-referred = true
    view.query = config.query
    view.init!
    @@register-in-template-grouped-views view
    view

  @wire-views-appearances = !->
    for doc-name, {list, detail} of @doc-grouped-views
      list.links =
        go-create : view: detail, appearance: detail.appearances.create
        go-update : view: detail, appearance: detail.appearances.update
        'delete'  : view: list,   appearance: list.appearances.list
      detail.links =
        create    : view: list,   appearance: list.appearances.list
        update    : view: list,   appearance: list.appearances.list
        'delete'  : view: list,   appearance: list.appearances.list
        'next'    : view: detail, appearance: -> detail.appearances[detail.current-appearance-name] # 保持当前的appearance，仅仅更换id
        'previous': view: detail, appearance: -> detail.appearances[detail.current-appearance-name]

  init: ->
    @names = new BP.Names @doc-name
    @collection = BP.Collection.get @names.meteor-collection-name
    @create-pub-sub!
    if Meteor.is-client
      @links = {}
      @state = new BP.State @name
      @create-view-appearances! 
      @create-ui!


  publish-data: !->
    debugger
    view = @
    Meteor.publish view.pub-sub.name, (id)-> 
      eval "query = " + view.pub-sub.query
      cursor = view.collection.find query

    (referred-view, view-name) <-! _.each view.referred-views
    Meteor.publish referred-view.pub-sub.name, (id)->
      eval "query = " + referred-view.pub-sub.query
      cursor = collection.find query


      # Meteor.subscribe @pub-sub.name, @doc-id = params[@name + '_id'], !~>  # main view
      #   @retrieve-as-main-view!
      # (referred-view, view-name) <-! _.each @referred-views
      # Meteor.subscribe referred-view.pub-sub.name, !->
      #   referred-view.collection = BP.Collection.registry[referred-view.names.meteor-collection-name]
      #   referred-view.retrieve-as-referred-view!
  get-path: (link-name, doc-or-doc-id)~>
    {view, appearance} = @links[link-name]
    view.get-appearance-path appearance, doc-or-doc-id


  change-to-appearance: (appearance-name, params)->
    @current-appearance-name = appearance-name
    # @state.set current-id: (params[@name + '_id'] or params.id)

  get-current-action: ~> @current-appearance-name

  current-action-checker: (action-name)~> action-name is @current-appearance-name

class List-view extends BP.View
  create-pub-sub: !->
    @pub-sub = 
      name: @names.meteor-collection-name
      query: "{}"

  create-view-appearances: !->
    @appearances = 
      list      : "/#{@name}/list"
      view      : "/#{@name}/view"
      reference : "/#{@name}/reference"

  get-appearance-path: (appearance)-> 
    path-pattern = if typeof appearance is 'function' then appearance! else appearance
    path-pattern

  data-retriever: ~> # doc: 业务逻辑中，由用户权限和流程权限决定的筛选在服务端完成（Meteor Method），而由用户体验形成的筛选在客户端完成，也即是在template中声明的query，用在这里。
    @doc-ids = @collection.find (@query or {}) .fetch! .map -> it._id
    @@transfer-state-between-views.set 'doc-ids', @doc-ids
    @docs = @collection.find (@query or {})

  subscribe-data: (params)->
    Meteor.subscribe @pub-sub.name

  create-ui: !->
    @ui = new BP.Table @

class Detail-view extends BP.View
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
    
if module? then module.exports = {View} else @BP.View = View # 让Jade和Meteor都可以使用


