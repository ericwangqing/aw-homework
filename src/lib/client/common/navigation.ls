# 模板（template）实例化后成为视图（view）。B+的main-content区域，每次只显示一个顶层view。
# 每个view有唯一的默认路径可以进入。view间可以组合，组合后的path为path的叠加。
# view-name在一个页面的main-content区域之内是唯一的。需要多次加载一个template的view时，必须给他们不同view name。
class Path 
  @create-pattern = ->
    if @composed-paths
      @pattern = [path.pattern for path in @composed-paths].join ''
    else if @type is 'list'
      @pattern = '/' + @destination-view-name
    else if @type is 'detail'
      @id-place-holder = ':' + @destination-view-name + '-id'
      @pattern = '/' + @destination-view-name + '/' @id-place-holder


  ({@destination-view-name, @type, @composed-paths})->
    @@create-pattern!

  get-path: (id)-> # 区分
    if id
      path = @pattern.replace @id-place-holder, id
    else
      path = @pattern

# 每条Path可以对应多种不同的entrace，分布在其它各个template中
class Entrace
  (@from-view, @action)->

# 每个Entrace对应在departure形成一个Goto
class Goto
  (@to-view, @action)->

# view是template被B+加载、实例化以后的产物，in和out
class view
  (@view-name, @type, @composed-views)->
    @entraces: [] # Entrace
    @go-to: [] # Goto

  add-composed-view


if module then module.exports = Path else BP.Path = Path # 让Jade和Meteor都可以使用

