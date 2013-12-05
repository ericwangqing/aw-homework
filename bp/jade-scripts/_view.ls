# used both at developing time by jade and runtime by meteor
class View
  @registry = {}
  @get-view = (doc-name, view-name, template-name, type)->
    throw new Error "view: '#view-name' already exists" if @registry[view-name]
    @registry[view-name] = new View doc-name, view-name, template-name, type 

  (@doc-name, @name, @template-name, @type)->
    @is-main-nav = false
    @composed-views = {}

@BP ||= {}
if module? then module.exports = {View} else @BP._View = View # 让Jade和Meteor都可以使用