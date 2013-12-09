class BP.List-view extends BP.View
  create-pub-sub: !->
    @pub-sub = 
      name: @names.meteor-collection-name
      query: "{}"

  create-view-appearances: !->
    @appearances = 
      list      : "/#{@name}/list"
      view      : "/#{@name}/view"
      reference : "/#{@name}/reference"

  get-appearance-path: (appearance)-> 
    path-pattern = if typeof appearance is 'function' then appearance! else appearance
    path-pattern

  add-links: (detail)!-> @links =
    go-create : view: detail, appearance: detail.appearances.create
    go-update : view: detail, appearance: detail.appearances.update
    'delete'  : view: @,      appearance: @appearances.list

  data-retriever: ~> # doc: 业务逻辑中，由用户权限和流程权限决定的筛选在服务端完成（Meteor Method），而由用户体验形成的筛选在客户端完成，也即是在template中声明的query，用在这里。
    @doc-ids = @collection.find (@query or {}) .fetch! .map -> it._id
    @@transfer-state-between-views.set 'doc-ids', @doc-ids
    @docs = @collection.find (@query or {})

  subscribe-data: (params)->
    Meteor.subscribe @pub-sub.name

  create-ui: !->
    @ui = new BP.Table @
