# 模板（template）实例化后成为视图（view）。B+的main-content区域，每次只显示一个顶层view。
# 每个view有唯一的默认路径可以进入。view间可以组合，组合后的path为path的叠加。
# view-name在一个页面的main-content区域之内是唯一的。需要多次加载一个template的view时，必须给他们不同view name。
class Path 
  (@destination-view-name, @type)->
    @composed-paths = []

  create-pattern: !->
    if @type is 'list'
      @pattern = '/' + @destination-view-name
    else if @type is 'detail'
      @id-place-holder = ':' + @destination-view-name + '-id'
      @pattern = '/' + @destination-view-name + '/' + @id-place-holder
    else
      throw new Error "this '#@type' is not supported yet."
    if @composed-paths.length > 0
      @pattern = @pattern + [path.pattern for path in @composed-paths].join ''

  get-path: (id)-> # 区分
    if id
      path = @pattern.replace @id-place-holder, id
    else
      path = @pattern

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

  (@doc-name, @name, @type)->
    @path = new Path @name, @type
    @is-main-nav = false
    @composed-views = {}
    # Path可以对应多种不同的entrace，分布在其它各个template中
    @entraces = [] # {from: view-name, action: action-name}
    # 每个Entrace对应在departure形成一个Goto
    @gotos = [] # {from: view-name, action: action-name}, 注意：goto的对象始终是顶层view

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

  add-goto: (goto)!->
    @gotos.push goto



if module then module.exports = {View} else BP.View = View # 让Jade和Meteor都可以使用

