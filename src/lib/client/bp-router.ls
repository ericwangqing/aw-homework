@BP ||= {}
/* ------------------------ Private Methods ------------------- */
_route = !~>
  Router.configure do
    layout-template: 'layout'
    loding-template: 'loading'
    not-found-template: 'not-found'

  filters = 
    n-progress-hook: ->
      if @ready!
        N-progress.done!
      else
        N-progress.start!
        @stop!

    reset-scroll: ->
      scroll-to = window.current-scroll or 0
      $ 'body' .scroll-top scroll-to
      $ 'body' .css 'min-height' 0

  Router.before filters.n-progress-hook, except: []
      # only: []

  Router.after  filters.reset-scroll, except: []
      # only: []

  [route! for route in BP.Router.pending-routes]


  Router.map ->
    @route 'default', do
      path: '/*'
      template: 'splash'
      # yield-templates:
@BP.Router = class _Router 
  @pending-routes = [] # 确保bp之外的route能够按序进行，不至于出现在bp route之前
  @collections-lists-routes = [] #用以main nav显示
  @route = _route

  (names)->
    @base-path-name = names.collection-path-name
    @base-path = '/' + names.route-path
    @list-template = names.list-template-name
    @detail-template = names.detail-template-name   
    @collection = names.meteor-collection-name

  add-routes: !->
    @@collections-lists-routes.push @base-path-name
    ['list', 'create', 'update', 'delete'].map @add-route, @
      
  add-route: (action)!->
    self = @
    @@pending-routes.push -> 
      Router.map ->
        @route (self._get-route-name action), do
          path: self._get-path action
          template: self._get-template action
          before: ->
            Session.set 'bp', {action: action} 
          wait-on: -> [
            Meteor.subscribe self.collection
          ]

  get-path: (action, doc)~> # 给Template用
    @_get-path action, doc._id

  _get-route-name: (action)->
    @base-path-name + if action is 'list' then '' else '-' + action

  _get-path: (action, id)->
    id ||= ':_id'
    return @base-path                 if action is 'list'
    return @base-path + '/create'     if action is 'create' 
    return @base-path + "/#id"        if action is 'update'
    return @base-path + "/#id/delete" if action is 'delete'

  _get-template: (action)->
    if action is 'list' then @list-template else @detail-template
