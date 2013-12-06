class @BP.View extends BP._View
  @template-grouped-views = @_tgv = {}
  @doc-grouped-views = @_dgv = {}

  @register-in-template-grouped-views = (view)!->
    @_tgv[view.template-name] ||= {}
    @_tgv[view.template-name][view.name] = view

  @register-in-doc-grouped-views = (view)!->
    @_dgv[view.doc-name] ||= {}
    @_dgv[view.doc-name][view.type] = view

  @resume-views = !(jade-views)->
    for view-name, jade-view of jade-views
      @registry[view-name] = view = @resume-view jade-view
      @register-in-doc-grouped-views view
      @register-in-template-grouped-views view
    @create-referred-views!
    @wire-views-appearances! if Meteor.is-client

  @resume-view = (jade-view)->
    view = (@create-view-by-type jade-view.type) <<< jade-view
    view.init!
    
  @create-view-by-type = (type)->
    if type is 'list' then new List-view! else new Detail-view!

  @create-referred-views = !->
    (view, view-name)                             <-! _.each @registry
    (reference-view-name, reference-view-config)  <-! _.each view.referred-views
    referred-view = @create-referred-view reference-view-name, reference-view-config
    view.referred-views[reference-view-name] = referred-view # doc: referred views 不在 View#registry里面登记，通过bp-load-view的helper切换view，而不是Router切换。

  @create-referred-view = (name, config)->
    view = @create-view-by-type @registry[config.referred-view-name]
    view.name = name
    view.is-referred-view = true
    view.query = config.query
    view.init!
    view.get-referenced-doc-ids = ->
      @collection.find view.query, {_id: 1} .fetch!

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
    @create-pub-sub!
    if Meteor.is-client
      @links = {}
      @state = new BP.State @name
      @create-view-appearances! 
      @create-ui!
    @ 


  publish-data: (collection)!->
    Meteor.publish @pub-sub.name, (id)~> 
      eval "query = " + @pub-sub.query
      # debugger
      # console.log "view: #{@name}, pub-sub.name: #{@pub-sub.name}, query: ", query
      cursor = collection.find query

    (referred-view, view-name) <-! _.each @referred-views
    Meteor.publish referred-view.pub-sub.name, (id)~>
      eval "query = " + referred-view.pub-sub.query
      # debugger
      # console.log "view: #{@name}, pub-sub.name: #{@pub-sub.name}, query: ", query
      cursor = collection.find query


  subscribe-data: (collection, params)->
    @collection = collection
    Meteor.subscribe @pub-sub.name if @type is 'list'
    if @type is 'detail'
      Meteor.subscribe @pub-sub.name, @doc-id = params[@name + '_id'], !~>  # main view
        @retrieve-from-collection-for-main-view!
      (referred-view, view-name) <-! _.each @referred-views
      Meteor.subscribe referred-view.name

  get-path: (link-name, doc-or-doc-id)~> # doc: 当页面上有
    id = if typeof doc-or-doc-id is 'string' then doc-or-doc-id else doc-or-doc-id._id
    {view, appearance} = @links[link-name]
    path-pattern = if typeof appearance is 'function' then appearance! else appearance
    path-pattern?.replace view.id-place-holder, id

  change-to-appearance: (appearance-name, params)->
    @current-appearance-name = appearance-name
    # @state.set current-id: (params[@name + '_id'] or params.id)

  get-current-action: ~> @current-appearance-name

  current-action-checker: (action-name)~> action-name is @current-appearance-name

  get-state: (action-name)-> @state.get action-name

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

  data-retriever: ~> # doc: 业务逻辑中，由用户权限和流程权限决定的筛选在服务端完成（Meteor Method），而由用户体验形成的筛选在客户端完成，也即是在template中声明的query，用在这里。
    @ui.collection = @collection
    @docs = @collection.find(@query or {}) .fetch!
    @state.set 'doc-ids', [doc._id for doc in @docs]
    @docs

  create-ui: !->
    @ui = new BP.Table @

class Detail-view extends BP.View
  create-pub-sub: !->
    @pub-sub = if @is-referred-view then
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

  get-referenced-appearances-suffix: ->
    [view.appearances.reference for view-name, view of @referred-views].join '/'

  data-retriever: ~>
    @ui.doc = @state.get 'doc' # or @retrieve-from-collection-for-main-view!

  retrieve-from-collection-for-main-view: ->
    BP.RRR = @
    @ui.collection = @collection
    if @current-appearance-name in ['update', 'view']
      @ui.doc = @collection.find-one _id: @doc-id
    else # create
      @ui.doc ={}
    @state.set 'doc' @ui.doc

  create-ui: !->
    @ui = new BP.Form @
/* ------------------------ Private Methods ------------------- */


# class @BP.State
#   update: (params)->
#     @get-transferred-state!

#   get-transferred-state: !->

if module? then module.exports = {View} else @BP.View = View # 让Jade和Meteor都可以使用


