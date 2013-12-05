# used both at developing time by jade and runtime by meteor
class View
  @registry = {}
  @get-view = (doc-name, view-name, template-name, type)->
    throw new Error "view: '#view-name' already exists" if @registry[view-name]
    @registry[view-name] = new View doc-name, view-name, template-name, type 

  (@doc-name, @name, @template-name)->
    @is-main-nav = false
    @composed-views = {}
    # @links = {} # 注意：link的对象始终是顶层view
    # @state = null  # state将在BPC加载时，通过resume-view实例化

/* ------------------------ Private Methods ------------------- */


# class @BP.State
#   update: (params)->
#     @get-transferred-state!

#   get-transferred-state: !->

if module? then module.exports = {View} else @BP._View = View # 让Jade和Meteor都可以使用