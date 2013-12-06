class @BP.View extends BP._View
  @template-grouped-views = @_tgv = {}
  @doc-grouped-views = @_dgv = {}

  @resume-views = !(jade-views)->
    for view-name, jade-view of jade-views
      @registry[view-name] = _v = @resume-view jade-view
      @_tgv[_v.template-name] ||= {}
      @_tgv[_v.template-name][_v.name] = _v
      @_dgv[_v.doc-name] ||= {}
      @_dgv[_v.doc-name][_v.type] = _v
    @wire-views-appearances! if Meteor.is-client

  @resume-view = (jade-view)->
    view = (if jade-view.type is 'list' then new List-view! else new Detail-view!) <<< jade-view
    view.names = new BP.Names view.doc-name
    view.create-pub-sub!
    if Meteor.is-client
      view.links = {}
      view.state = new BP.State view.name
      view.create-view-appearances!
      view.create-ui!
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

  publish-data: (collection)!->
    Meteor.publish @pub-sub.name, (id)~> 
      eval "query = " + @pub-sub.query
      # debugger
      # console.log "view: #{@name}, pub-sub.name: #{@pub-sub.name}, query: ", query
      cursor = collection.find query

  subscribe-data: (collection)->
    @collection = collection
    Meteor.subscribe @pub-sub.name if @type is 'list'
    Meteor.subscribe @pub-sub.name, @get-state 'current-id' if @type is 'detail'

  get-path: (link-name, doc-or-doc-id)~> 
    id = if typeof doc-or-doc-id is 'string' then doc-or-doc-id else doc-or-doc-id._id
    {view, appearance} = @links[link-name]
    path-pattern = if typeof appearance is 'function' then appearance! else appearance
    path-pattern?.replace view.id-place-holder, id

  change-to-appearance: (appearance-name, params)->
    @current-appearance-name = appearance-name
    @state.set current-id: (params[@name + '_id'] or params.id)

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

  data-retriever: ~>
    @ui.collection = @collection
    @docs = @collection.find! .fetch!
    @state.set 'doc-ids', [doc._id for doc in @docs]
    @docs

  create-ui: !->
    @ui = new BP.Table @

class Detail-view extends BP.View
  create-pub-sub: !->
    @pub-sub =
      name: @names.doc-name
      query: "{_id: id}"

  create-view-appearances: !->
    @id-place-holder = ':' + @name + '_id'
    @appearances = 
      create    : '/' + @name + '/create'
      update    : '/' + @name + '/' + @id-place-holder + '/update'
      view      : '/' + @name + '/' + @id-place-holder + '/view'
      reference : '/' + @name + '/' + @id-place-holder + '/reference'

  data-retriever: ~>
    @ui.collection = @collection
    if @current-appearance-name in ['update', 'view']
      @ui.doc = @collection.find-one _id: (@state.get 'current-id')
    else # create
      @ui.doc ={}

  create-ui: !->
    @ui = new BP.Form @
/* ------------------------ Private Methods ------------------- */


# class @BP.State
#   update: (params)->
#     @get-transferred-state!

#   get-transferred-state: !->

if module? then module.exports = {View} else @BP.View = View # 让Jade和Meteor都可以使用


