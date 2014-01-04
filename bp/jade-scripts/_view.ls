## used both at developing time by jade and runtime by meteor
class View
  @registry = {}
  @get-view = (doc-name, namespace, template-name, type)->
    throw new Error "view: '#template-name' already exists" if @registry[template-name]
    @registry[template-name] = new View doc-name, namespace, template-name, type 

  (@doc-name, @namespace, @template-name, @type)->
    @name = @template-name
    @is-main-nav = false
    @referred-views = {}

@BP ||= {}
if module? then module.exports = {View} else @BP._View = View # 让Jade和Meteor都可以使用 