
/* --------------------- Iron Router的配置和B+ Components之外的Routes --------------- */
do config-and-static-route = !~>
  Router.configure do
    layout-template: 'layout'
    loding-template: 'loading'
    not-found-template: 'not-found'

  filters = 
    is-logged-in: ->
      if not (Meteor.logging-in! or Meteor.user!)
        # throw new Meteor.Error "请先登录"
        alert "请先登录"
        # @render 'siginin'
        @redirect 'default'        

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

  Router.before filters.is-logged-in, except: ['default']
  Router.before filters.n-progress-hook, except: []
      # only: []

  Router.after  filters.reset-scroll, except: []
      # only: []

  Router.map ->
    @route 'default', do
      path: '/'
      template: 'splash'
      # yield-templates:

