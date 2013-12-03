@BP ||= {}
@BP.Router = class _Router 
  (@bpc)->
    @route!

  route: !->
    self = @
    view = @bpc.view
    Router.map !->
      for action, pattern of view.path.patterns
        path-name = view.name + '-' + action
        BP.Component.main-nav-paths.push {name: view.name, path: path-name} if view.is-main-nav and action is 'list'
        let action # 这里注意，要用闭包，否则都成了最后一个循环中的aciton
          @route path-name, do
            path: pattern
            template: view.template-name
            before: ->
              self.bpc.init! # 页面顶层的bpc在这里初始化，内含的各个bpc通过'bp-load-bpc'helper，在Meteor渲染页面时初始化
              view.update-state action, @params
              # if id = @params._id or action is 'create'
              #   self.bpc.set-state action: action, current-id: id
              #   self.bpc.update-pre-next id
            wait-on: -> [
              Meteor.subscribe self.bpc.names.meteor-collection-name
            ]

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

