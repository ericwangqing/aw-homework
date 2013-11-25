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


for collection-name in BP.subscribed
  console.log "collection-name: ", collection-name
  Router.map ->
    @route collection-name, do
      path: '/'+ collection-name # TODO: refactor to a util function
      template: collection-name + '-list'
      wait-on: -> [
        Meteor.subscribe collection-name.capitalize!
      ]

    doc-name = collection-name.singularize!
    @route doc-name, do
      path: '/' + collection-name + '/:_id'
      template: doc-name
      wait-on: -> [
        Meteor.subscribe collection-name.capitalize!
      ]



Router.map ->
  @route 'default', do
    path: '/*'
    template: 'splash'
    # yield-templates:
