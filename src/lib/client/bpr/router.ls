@BP ||= {}
@BP.Router = class _Router 
  @collections-lists-routes = [] #用以main nav显示

  (@bpc)->
    @names = @bpc.names

  add-routes: !->
    @@collections-lists-routes.push @names.list-path-name
    ['list', 'create', 'update', 'delete'].map @_add-route, @

  _add-route: (action)!->
    self = @
    Router.map ->
      @route (self._get-route-name action), do
        path: self._get-path action
        template: self._get-template action
        before: ->
          Session.set 'bp', action: action, current-id: @params._id 
        wait-on: -> [
          Meteor.subscribe self.names.meteor-collection-name
        ]

  _get-route-name: (action)->
    @names[action + 'PathName']

  _get-path: (action, id)->
    @names[action + 'RoutePath'] id

  _get-template: (action)->
    if action is 'list' then @names.list-template-name else @names.detail-template-name

/* --------------------- Iron Router的配置和Component之外的Routes --------------- */
do config-and-static-route = !~>
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

  Router.map ->
    @route 'default', do
      path: '/'
      template: 'splash'
      # yield-templates:

