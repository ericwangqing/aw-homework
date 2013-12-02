# 模板（template）实例化后成为视图（view）。B+的main-content区域，每次只显示一个顶层view。
# 每个view有唯一的默认路径可以进入。view间可以组合，组合后的path为path的叠加。
# view-name在一个页面的main-content区域之内是唯一的。需要多次加载一个template的view时，必须给他们不同view name。
class Path 
  (@destination-view-name, @type)->
    @composed-paths = []
    @patterns = {}

  create-pattern: !-> # ['list', 'reference']
    if @type is 'list'
      @patterns['list'] = '/' + @destination-view-name
      @patterns['reference'] = '/' + @destination-view-name + '/reference'
    else if @type is 'detail' # ['create', 'update', 'view', 'reference']
      @id-place-holder = ':' + @destination-view-name + '-id'
      @patterns['create'] = '/' + @destination-view-name + '/create' 
      @patterns['update'] = '/' + @destination-view-name + '/' + @id-place-holder + '/update'
      @patterns['view'] = '/' + @destination-view-name + '/' + @id-place-holder + '/view'
      @patterns['reference'] = '/' + @destination-view-name + '/' + @id-place-holder + '/reference'
    else
      throw new Error "this '#@type' is not supported yet."

    if @composed-paths.length > 0 # 目前只支持reference视图
      for name, pattern of @patterns
        @patterns[name] = pattern + [path.patterns['reference'] for path in @composed-paths]

  get-path: (action, id)-> # 区分
    if id
      path = @patterns.replace @id-place-holder, id
    else
      path = @patterns

# view是template被B+加载、实例化以后的产物。
class View
  @registry = {}
  @get-view = (doc-name, view-name, type)->
    @registry[view-name] = new View doc-name, view-name, type if not @registry[view-name]
    @registry[view-name]

  @resume-views = !(views)->
    for view-name, view of views
      View.registry[view-name] = @resume-view view

  @resume-view = (view)->
    view.path = new Path! <<< view.path
    resumed-view = new View! <<< view


  @create-all-views-path-pattern = !->
    views = Object.values @registry
    total =  views.length
    resolved-views = []
    while resolved-views.length != total
      for view in views
        if view != null and (is-all-resolved view.composed-views)
          [view.path.composed-paths.push composed-view.path for composed-view in Object.values view.composed-views]
          view.path.create-pattern!
          resolved-views.push view
          view = null

  is-all-resolved = (composed-views)->
    for view-name, composed-view-or-name of composed-views
      continue if typeof composed-view-or-name is 'object' # already resolved
      return false if not @@registry[composed-view-or-name] # not resolved
      composed-views[view-name] = @@registry[composed-view-or-name].clone view-name
    true

  wire-views-goto = !->
    for view-name, view of @registry
      view.wire-goto!


  (@doc-name, @name, @type)->
    @path = new Path @name, @type
    @is-main-nav = false
    @composed-views = {}
    @gotos = {} # {goto: path, action: action-name}, 注意：goto的对象始终是顶层view

  add-composed-view: (view-name, composed-view-name)!-> #defer to resolve
    @composed-views[view-name] = composed-view-name 
      # console.log "this is ", @
      # return view if view = @@registry[view-name]
      # throw new Error "Template: #template-name can't be found." if not template-view = @@registry[template-name]
      # view = Object.clone template-view, deep = true
      # view.name = view-name
      # view

  clone: (new-view-name)->
    new-view = @@resume-view JSON.parse JSON.stringify @
    new-view.name = new-view-name
    new-view.path.destination-view-name = new-view-name
    new-view.path.create-pattern!
    new-view

  wire-goto: !-> # ['list', 'create', 'update', 'delete', 'view']
    if @type is 'detail' # 
      @leaving-actions = ['next', 'previous', 'submit', 'delete']
      @goto['next'] =
        helper-name: 'bp-'




if module then module.exports = {View} else BP.View = View # 让Jade和Meteor都可以使用

