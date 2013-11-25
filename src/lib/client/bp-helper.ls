@BP ||= {}
do make-handlebars-understand-chinese-key = !->
  Handlebars.register-helper 'bs', (attr)-> # 克服Meteor Handlebars不能使用中文key，形如{{中文}}会出错的问题。改用{{bs '中文'}}
    @[attr]

class @BP.Helper # abstract and Factory
  # Factory method
  @get-helper = (names, collection, template-type)->
    if template-type is 'list'
      new List-Helper names, collection
    else if template-type is 'detail'
      new Detail-Helper names, collection

  (@collection)->
    @helpers = {}
    @events-handlers = {}
    @post-render-methods = []

  init: !->
    @register-data-retriever!
    @register-permission-checker!
    @register-event-handlers!
    Template[@template-name].helpers @helpers
    Template[@template-name].events @events-handlers
    Template[@template-name].rendered = !~>
      [method! for method in @post-render-methods]

  attribute-permission-checker: (attr, action)~> # Template调用，检查当前用户是否有权限进行相应操作
    #TODO：接入Bp-Permission模块，提供权限功能
    # bp-Permssion.can-user-act-on Meteor.userId, @doc-name, attr, action
    # 下面是暂时的fake
    auto-generated-fields = <[createdAtTime lastModifiedAt _id state]>
    attr not in auto-generated-fields

  doc-permission-checker: (action)~>
    #TODO：接入Bp-Permission模块，提供权限功能
    # bp-Permssion.can-user-act-on Meteor.userId, @doc-name, action
    # 下面是暂时的fake
    true

  get-current-action: ->
    # current-action-obj = Session.get 'bp-current-actions'
    # find-current-action-on @doc-name, @doc?_id
    'edit' # 暂时开发时用

  register-data-retriever: !->
    @helpers[@data-helper-name] = @data-retriever

  register-permission-checker: !->
    @helpers['bp-attribute-permit'] = @attribute-permission-checker
    @helpers['bp-collection-permit'] = @doc-permission-checker
    @helpers['bp-action-is'] = (action)~>
      action is @get-current-action!

  register-event-handlers: !-> # empty place holder

class List-Helper extends Helper
  (names, collection)->
    super collection
    @template-name = names.list-template-name
    @data-helper-name = names.list-data-retriever-name
  
  data-retriever: (query = {})~> 
    @doc = @collection.find!

class Detail-Helper extends Helper
  (names, collection)->
    super collection
    @template-name = names.detail-template-name
    @data-helper-name = names.detail-data-retriever-name
    @helpers['bp-add-typeahead'] = @add-typeahead-to-input-field
    @post-render-methods.push @add-form-validation

  data-retriever: (query = {})~> # TODO：这里查询待完善
    @doc = @collection.find-one!

  tab-focuse-with-div-control-highlight: (e)->
    control = $ e.current-target 
    control.parents!add-class 'focus'

  tab-blur-with-div-control-highlight: (e)->
    control = $ e.current-target 
    control.parents!remove-class 'focus'
    # control.find 'input, textarea' .focus! 

  add-typeahead-to-input-field:  (attr, candidates)!~> # 模板中的ahead控件将调用它，以便render后，动态添加typeahead功能
    let item = name: @template-name + attr, attr: attr # 这里要用闭包，多次的attr不一样
      @post-render-methods.push ->
        $ "input[name='#{item.attr}']" .typeahead do
          name:  item.name
          local: [str.trim! for str in candidates.split ',']

  add-form-validation: !->
    try
      form = $ 'form' .first!
      # console.log "form.context is: ", form.context
      form.parsley() # if form.context # Meteor会在这里执行两次，第一次时Parsley还没有完成form初始化
    catch error
      console.log error

  register-event-handlers: !->
    @events-handlers['focus div.controls input, div.controls textarea'] = @tab-focuse-with-div-control-highlight
    @events-handlers['blur div.controls input, div.controls textarea'] = @tab-blur-with-div-control-highlight




