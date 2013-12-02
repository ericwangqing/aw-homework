if module
  require! [fs, './navigation'.View]

BP ||= {}
BP.View ||= View

class _Router
  (@bpc)->
    @route!

  route: !->
    self = @
    view = @bpc.view
    Router.map !->
      for action, pattern of view.patterns
        @route (view.name + '-' + action), do
          path: pattern
          template: view.template-name
          before: ->
            self.bpc.init! # 页面顶层的bpc在这里初始化，内含的各个bpc通过'bp-load-bpc'helper，在Meteor渲染页面时初始化
            view.update-state action, params
            # if id = @params._id or action is 'create'
            #   self.bpc.set-state action: action, current-id: id
            #   self.bpc.update-pre-next id
          wait-on: -> [
            Meteor.subscribe self.names.meteor-collection-name
          ]




if module then module.exports = _Router else BP.Router = _Router # 让Jade和Meteor都可以使用
