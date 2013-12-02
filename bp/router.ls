if module
  require! [fs, './navigation'.View]

BP ||= {}
BP.View ||= View

class _Router
  @add-route-for-views = (views)!->
    BP.View.resume-views views
    # console.log "resumed views: ", BP.View.registry
    BP.View.create-all-views-path-pattern!
    for name, view of BP.View.registry
      console.log "view: ", view
      new Router view .route!
    # BP.View.wire-views-goto!
  (@view)->

  route: !->
    self = @
    Router.map !->
      for action, pattern of self.view.patterns
        @route (self.view.name + '-' + action), do
          path: pattern
          template: @view.name
          before: ->
            params = @params
            self.create-bpc!
            self.bpc.update-state params
            # if id = @params._id or action is 'create'
            #   self.bpc.set-state action: action, current-id: id
            #   self.bpc.update-pre-next id
          wait-on: -> [
            Meteor.subscribe self.names.meteor-collection-name
          ]

  _get-route-name: (action)->
    @names[action + 'PathName']

  _get-path: (action, id)->
    @names[action + 'RoutePath'] id

  _get-template: (action)->
    if action is 'list' then @names.list-template-name else @names.detail-template-name




if module then module.exports = _Router else BP.Router = _Router # 让Jade和Meteor都可以使用
