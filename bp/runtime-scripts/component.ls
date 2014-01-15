## Component是BP数据（collection）展示和操作的基本单位。Component有list和detail两种view，对一种数据（doc）进行展示和操作。

top = @
class @BP.Collection
  @registry = {}
  @get = (collection-name)->
    @registry[collection-name] ||= new Meteor.Collection collection-name
    top[collection-name] = @registry[collection-name] # 开发时暴露出来，便于插入数据和调试。

  @get-by-doc-name = (doc-name)->
    collection-name = (new BP.Names 'default', doc-name).meteor-collection-name
    @get collection-name

@BP.Nav =
  main-nav-paths: []
  second-nav-paths: []
  add-main-nav: (link)-> @main-nav-paths.push link # link: {name: 'show-on-the-link', path: 'iron-router-path-name'}
  add-second-nav: (link)-> @second-nav-paths.push link 

class @BP.Component
  @registry = {}
  @main-nav-paths = []

  @create-components = (components, relations)!->
    [BP.Relation.add-relation relation for relation in relations]
    [new BP.Component component for component in components]
    [[component.init! for doc-name, component of components] for namespace, components of @registry]

  ({@namespace, @doc-name, @main-nav})-> # template-name, template-adapter, views
    @list = new BP.List-view @namespace, @doc-name
    @detail = new BP.Detail-view @namespace, @doc-name
    @@registry[@namespace] ||= {}
    @@registry[@namespace][@doc-name] = @

  init: !->
    @list.add-links @detail
    @detail.add-links @list
    @add-relations-links!

    if Meteor.is-client
      @add-to-main-nav! if @main-nav
      @add-to-second-nav!
      @list.route!
      @detail.route!

    if Meteor.is-server 
      # debugger
      @list.data-manager.publish!
      @detail.data-manager.publish!

  add-relations-links: !->
    relations = BP.Relation.registry[@doc-name] or []
    # debugger
    [@add-relation-links relation for relation in relations] 

  add-relation-links: (relation)!->
    current-end = relation.get-current-end @doc-name
    @add-action-link @list, 'go-create', relation
    @add-action-link @list, 'go-update', relation
    # TODO: other links

  add-action-link: (view, action, relation)!->
    link = relation.get-link-by-action action, @doc-name
    to-view = @@registry[@namespace][link.to.doc-name][link.to.view]
    view.links[link.path] = view: to-view, face: to-view.faces[link.to.face]

  add-to-main-nav: !->
    path-name = @list.faces-manager.get-path-name 'list'
    BP.Nav.add-main-nav {name: @list.name, path: path-name}

  add-to-second-nav: !->
    path-name = @list.faces-manager.get-path-name 'list'
    BP.Nav.add-second-nav {name: @list.name, path: path-name}