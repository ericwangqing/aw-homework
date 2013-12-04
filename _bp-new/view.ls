@BP ||= {}
class @BP.View extends BP.Abstract-Registable
  @template-grouped-views = {}
  @get-view = (doc-name, view-name, template-name, type)->
    throw new Error "view: '#view-name' already exists" if @registry[view-name]
    @registry[view-name] = new View doc-name, view-name, template-name, type 

  @resume-views = !(jade-views)->
    for view-name, jade-view of jade-views
      @registry[view-name] = view = @resume-view jade-view
      @template-grouped-views[view.template-name] ||= {}
      @template-grouped-views[view.template-name][view.type] = view
    @wire-views-appearances!

  @resume-view = (jade-view)->
    view = (if jade-view.type is 'list' then new List-view! else new Detail-view!) <<< jade-view
    if Meteor.is-client
      view.names = new BP.Names view.doc-name
      view.state = new BP.State view.name
      view.create-pub-sub!
      view.create-view-appearances!
      view.create-ui!

  @wire-views-appearances = !->
    for template-name, {list, detail} of @template-grouped-views
      list.links =
        go-create: detail.appearances.create
        go-update: detail.appearances.update
        'delete' : list.appearances.list
      detail.links =
        create    : list.appearances.list
        update    : list.appearances.list
        'delete'  : list.appearances.list
        'next'    : detail.current-appearance
        'previous': detail.current-appearance

  (@doc-name, @name, @template-name)->
    @is-main-nav = false
    @composed-views = {}
    @links = {} # 注意：link的对象始终是顶层view
    @state = null  # state将在BPC加载时，通过resume-view实例化

  publish-data: (collection)!->
    Meteor.publish @pub-sub.name, ~> 
      cursor = @pub-sub.query collection
    @collection = collection
    Meteor.publish @pub-sub.name, ~> 
      cursor = collection.find @pub-sub.query

  subscribe-data: ->
    Meteor.subscribe @pub-sub.name if type is 'list'
    Meteor.subscribe @pub-sub.name, @get-state 'current-id' if type is 'list'

  get-path: (link-name, id)-> 
    path-pattern = destination-appearance = @links[link-name]
    path-pattern.replace @id-place-holder, id

  change-to-appearance: (appearance-name, params)->
    @current-appearance-name = appearance-name
    @state.set current-id: params._id or params.id

  get-current-action: -> @current-appearance-name

  current-action-checker: (action-name)-> action-name is @current-appearance-name

  get-state: @state.get

class List-view extends BP.View
  create-pub-sub: !->
    @pub-sub = 
      name: @names.mongo-collection-name
      query: {}

  create-view-appearances: !->
    @appearances = 
      list      : "/#@name/list"
      view      : "/#@name/view"
      reference : "/#@name/reference"

  data-retriever: ->
    @docs = @collection.find! .fetch!
    @bpc.set-state 'doc-ids', [doc._id for doc in @docs]
    @docs

  create-ui: !->
    @ui = new BP.Table!

class Detail-view extends BP.View
  create-pub-sub: !->
    @pub-sub =
      name: @names.doc-name
      query: {_id: id}

  create-view-appearances: !->
    @appearances = 
      create    : '/' + @name + '/create'
      update    : '/' + @name + '/' + @id-place-holder + '/update'
      view      : '/' + @name + '/' + @id-place-holder + '/view'
      reference : '/' + @name + '/' + @id-place-holder + '/reference'

  data-retriever: ->
    form = @ui
    form.collection = @collection
    if @current-appearance-name in ['update', 'view']
      form.doc = @collection.find-one _id: (@state.get 'current-id')
    else
      form.doc ={}

  create-ui: !->
    @ui = new BP.Form!
/* ------------------------ Private Methods ------------------- */


# class @BP.State
#   update: (params)->
#     @get-transferred-state!

#   get-transferred-state: !->



