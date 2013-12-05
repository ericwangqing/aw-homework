top = @

class Collection extends BP.Abstract-Registable

class @BP.Component extends BP.Abstract-Registable
  @main-nav-paths = []

  @create-components-from-jade-views =  (jade-views)->
    BP.View.resume-views jade-views
    (views, template-name)  <-! _.each BP.View.template-grouped-views
    new BP.Component template-name, views

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
        # component.change-to-view view
        view.change-to-appearance appearance-name, @params
      wait-on: ->
        view.subscribe-data component.collection


  # change-to-view: (view)->
  #   @template-adapter.wire-view view

/* ------------------------ Private Methods ------------------- */
initial-template-adpater-for-views = !->
  @template-adapter = BP.Template-adapter.get @type, @names, @template # 'list', 'detail'
  (view, view-name) <~! _.each @views
  @template-adapter.ui = view.ui
  @template-adapter.wire-view view


create-meteor-collection = !-> 
  collection-name = @names.meteor-collection-name
  @collection = Collection.get collection-name, 'Meteor.Collection', collection-name
  top[collection-name] = @collection
  
publish-data-for-views = !->
  (view, view-name) <~! _.each @views
  view.publish-data @collection 

