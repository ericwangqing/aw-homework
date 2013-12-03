# 注意此文件将同时为开发时和运行时使用。Jade用其来生成Views，并写出启动代码main.ls。
# 运行时，启动代码将进一步将Jade生成的View，初始化为BPC。
# 模板（template）实例化后成为视图（view）。B+的main-content区域，每次只显示一个顶层view。
# 每个view有唯一的默认路径可以进入。view间可以组合，组合后的path为path的叠加。
# view-name在一个页面的main-content区域之内是唯一的。需要多次加载一个template的view时，必须给他们不同view name。
class Path 
  (@destination-view-name, @type)->
    @composed-paths = []
    @patterns = {}
    @last-id = @last-action = null

  create-pattern: !-> # ['list', 'reference']
    if @type is 'list'
      @patterns['list'] = '/' + @destination-view-name
      @patterns['reference'] = '/' + @destination-view-name + '/reference'
    else if @type is 'detail' # ['create', 'update', 'view', 'reference']
      @id-place-holder = ':' + @destination-view-name + '_id'
      @patterns['create'] = '/' + @destination-view-name + '/create' 
      @patterns['update'] = '/' + @destination-view-name + '/' + @id-place-holder + '/update'
      @patterns['view'] = '/' + @destination-view-name + '/' + @id-place-holder + '/view'
      @patterns['reference'] = '/' + @destination-view-name + '/' + @id-place-holder + '/reference'
    else
      throw new Error "this '#@type' is not supported yet."

    if @composed-paths.length > 0 # 目前只支持reference视图
      for name, pattern of @patterns
        @patterns[name] = pattern + [path.patterns['reference'] for path in @composed-paths]

  get-path: (action, id)-> 
    @last-id = id || @last-id if @type is 'detail' # 如果没有id，detail使用之前的id
    @last-action = if action and @patterns[action] then action else @last-action # 当出现未登记的action时，保存上次的action，也就是页面不变。例如：删除列表时，上次的action是list，而这次的delelte并未登记，此时沿用list，也就是说回到列表。
    path = @patterns[@last-action].replace @id-place-holder, id


# view是template被B+加载、实例化以后的产物。
class View
  @registry = {}
  @get-view = (doc-name, view-name, template-name, type)->
    @registry[view-name] = new View doc-name, view-name, template-name, type if not @registry[view-name]
    @registry[view-name]

  @resume-views = !(views)->
    for view-name, view of views
      View.registry[view-name] = @resume-view view
    @create-all-views-path-pattern!
    @wire-views-links!

  @resume-view = (view)->
    view.path = new Path! <<< view.path
    resumed-view = new View! <<< view
    resumed-view.state = new BP.State view.name if Meteor.is-client
    resumed-view


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

  @wire-views-links = !->
    doc-view-pairs = {}
    for view-name, view of @registry
      doc-view-pairs[view.doc-name] ||= {}
      doc-view-pairs[view.doc-name].list = view if view.type is 'list'
      doc-view-pairs[view.doc-name].detail = view if view.type is 'detail'

    for doc-name, pairs of doc-view-pairs
      {list, detail} = pairs
      list.links = do
        create: view: detail, action: 'create'
        update: view: detail, action: 'update' 
        view: view: detail, action: 'view'
        'delete': view: list, action: 'list'
        submit: view: list, action: 'list'

      detail.links = do
        previous: view: detail, action: null # 保持和当前的action一致
        next: view: detail, action: null
        'delete': view: list, action: 'list'
        submit: view: list, action: 'list'

  is-all-resolved = (composed-views)->
    for view-name, composed-view-or-name of composed-views
      continue if typeof composed-view-or-name is 'object' # already resolved
      return false if not @@registry[composed-view-or-name] # not resolved
      composed-views[view-name] = @@registry[composed-view-or-name].clone-as-composed view-name
    true


  (@doc-name, @name, @template-name, @type)->
    @path = new Path @name, @type
    @is-main-nav = false
    @composed-views = {}
    @links = {} # 注意：link的对象始终是顶层view
    @state = null # state将在BPC加载时，通过resume-view实例化

  add-composed-view: (view-name, composed-view-name)!-> #defer to resolve
    @composed-views[view-name] = composed-view-name 

  clone-as-composed: (new-view-name)->
    new-view = @@resume-view JSON.parse JSON.stringify @
    new-view.name = new-view-name
    new-view.is-main-nav = false # composed view不能直接导航
    new-view.state = new BP.State new-view-name if Meteor.is-client
    new-view.path.destination-view-name = new-view-name
    new-view.path.create-pattern!
    new-view

  get-link-path: (action, id)->  
    return null if _.is-empty @links # 此时是组合进来的，是reference，不要渲染其上的link
    link-to-view = @links[action].view
    link-to-view.path.get-path @links[action].action, id

  update-state: (action, params)->
    if @type is 'detail'
      @state.set action: action, current-id: id = params[@name + '_id']
      @state.update-pre-next id
    else if @type is 'list'
      @state.set action: action
    else
      throw new Error "unsupported type: '#@type'."
    for view-name, view of @composed-views
      view.update-state 'reference', params # 目前暂时只支持reference

if module? then module.exports = {View} else @BP.View = View # 让Jade和Meteor都可以使用

