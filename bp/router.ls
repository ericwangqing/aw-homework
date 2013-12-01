if module
  require! [fs, './navigation'.View]

BP ||= {}
BP.View ||= View

class Router
  @add-route-for-views = (views)!->
    BP.View.resume-views views
    # console.log "resumed views: ", BP.View.registry
    BP.View.create-all-views-path-pattern!
    # console.log "resolved results: ", BP.View.registry


if module then module.exports = Router else BP.Router = Router # 让Jade和Meteor都可以使用
