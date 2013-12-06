top = @
if Meteor.is-client
  do enable-handlebar-switch-views-in-its-rendering = !->
    Handlebars.register-helper 'bp-load-view', (view-name)-> 
      component = BP.Component.view-name-component-map[view-name]
      view = component.views[view-name]
      component.adapter.load-view view

class Collection
  @registry = {}
  @get = (collection-name)->
    @registry[collection-name] ||= new Meteor.Collection collection-name

class @BP.Component
  @main-nav-paths = []
  @view-name-component-map = {} 

  @create-components-from-jade-views =  (jade-views)->
    BP.View.resume-views jade-views
    (views, template-name)  <~! _.each BP.View.template-grouped-views
    component = new BP.Component template-name, views
    [@view-name-component-map[view.name] = component for view-name, view of views] if Meteor.is-client


  (@template-name, @views)-> # template-name, template-adapter, views
    @doc-name = _.values @views .0.doc-name # 这里所有的views都是一个template的，当然对应一种doc
    @names = new BP.Names @doc-name
    create-meteor-collection.apply @

    if Meteor.is-client
      @type =_.values @views .0.type 
      @template = Template[@template-name] # grab Meteor template, 这里注意Meteor的template实际上是一个加载template html之后，编译成的函数。也就是说只编译一次，因此不会出现变化。
      initial-template-adpater-for-views.apply @
      @route!

    if Meteor.is-server 
      publish-data-for-views.apply @

  route: !->
    component = @
    <-! Router.map
    r = @
    (view, view-name)               <-! _.each component.views
    (path-pattern, appearance-name) <-! _.each view.appearances
    path-name = view-name + '-' + appearance-name
    BP.Component.main-nav-paths.push {name: view-name, path: path-name} if view.is-main-nav and appearance-name is 'list'
    r.route path-name, do
      path: path-pattern
      template: component.template-name
      before: ->
        component.adapter.load-view view
        view.change-to-appearance appearance-name
      wait-on: ->
        view.subscribe-data component.collection, @params

/* ------------------------ Private Methods ------------------- */
initial-template-adpater-for-views = !->
  @adapter = BP.Template-adapter.get @type, @names, @template # 'list', 'detail'
  # (view, view-name) <~! _.each @views
  # @adapter.load-view view


create-meteor-collection = !-> 
  collection-name = @names.meteor-collection-name
  @collection = Collection.get collection-name
  top[collection-name] = @collection # 注意！！！ 为了方便调试，在顶层（window）暴露出来，上线时去除。
  
publish-data-for-views = !->
  (view, view-name) <~! _.each @views
  view.publish-data @collection 

