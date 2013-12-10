top = @
# if Meteor.is-client
  # do enable-handlebar-switch-views-in-its-rendering = !->
  #   Handlebars.register-helper 'bp-load-view', (view-name)-> 
  #     component = BP.Component.view-name-component-map[view-name]
  #     view = component.views[view-name]
  #     component.adapter.load-view view

class @BP.Collection
  @registry = {}
  @get = (collection-name)->
    @registry[collection-name] ||= new Meteor.Collection collection-name
    top[collection-name] = @registry[collection-name] # 开发时暴露出来，便于插入数据和调试。

class @BP.Component
  @main-nav-paths = []

  @create-components-from-jade-views =  (jade-views, view-customizer-class-name, type)->
    # debugger
    BP.View.resume-views jade-views, view-customizer-class-name, type
    (view, view-name)  <~! _.each BP.View.registry
    component = new BP.Component view

  (@view)-> # template-name, template-adapter, views
    if Meteor.is-client
      @create-template-adpater!
      @add-main-navs!
      @view.route!

    if Meteor.is-server 
      # debugger
      @view.data-manager.publish!

  create-template-adpater: !->
    @adapter = BP.Template-adapter.get @view

  add-main-navs: !->
    if @view.is-main-nav
      for face-name, path-pattern of @view.faces
        if face-name is 'list'
          path-name = @view.faces-manager.get-path-name face-name
          @add-to-main-nav @view, path-name 

  add-to-main-nav: (view, path-name)!->
    @@main-nav-paths.push {name: view.name, path: path-name}


