if Meteor.is-client
  # 初始化bp

  Handlebars.register-helper 'bs', (attr)-> # 克服Meteor Handlebars不能使用中文key，形如{{中文}}会出错的问题。改用{{bs '中文'}}
    @[attr]

  class Bp-Helper # abstract and Factory
    
    # Factory method
    @get-helper = (doc-name, template-type, template-name)->
      if template-type is 'list'
        new Bp-List-Helper doc-name, template-name
      else if template-type is 'detail'
        new Bp-Detail-Helper doc-name, template-name

    # 每个Bp-Helper对应一种doc，每种doc构成一个collection，有List和Detail两种templates
    # collection name是doc name的复数大写形式，如：Assignments
    # @param template-type: list | detail
    # list：列表该collection的doc，对应实现对doc的删除操作，并给出和去”添加“和去”修改“的链接（按钮）
    # detail：展示一个doc的详情，对应修改、添加和评论操作
    (@doc-name)->
      @collection = eval @doc-name.pluralize!capitalize!
      @helpers = {}
      # @permission-checkers = {}
      @events-handlers = {}
      @post-render-methods = []

    init: !->
      @register-data-retriever!
      @register-permission-checker!
      @register-event-handlers!
      # @register-post-render-methods!
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

  class Bp-List-Helper extends Bp-Helper
    # list型的template name默认为"doc-name的复数-list"，如：assignments-list
    (doc-name, template-name)->
      super doc-name
      @template-name = if template-name then template-name else @doc-name.pluralize! + '-list'
      # template上通过这个名字的helper，获取数据。约定为"doc-name的复数"
      @data-helper-name = @doc-name.pluralize!
    
    data-retriever: (query = {})~> 
      @collection.find query


  class Bp-Detail-Helper extends Bp-Helper
    # detail型的template name默认与doc-name一致
    (doc-name, template-name)->
      super doc-name
      @template-name = if template-name then template-name else @doc-name
      # template上通过这个名字的helper，获取数据。约定为"doc-name"
      @data-helper-name = @doc-name
      @helpers['bp-add-typeahead'] = @add-typeahead-to-input-field
      @post-render-methods.push @add-form-validation
      @post-render-methods.push @add-form-validation

    data-retriever: (query = {})~> # TODO：这里查询待完善
      @doc = @collection.find-one!

    tab-focuse-with-div-control-highlight-and-input-focused: (e)->
      control = $ e.current-target 
      control.add-class 'focus'
      control.find 'input, textarea' .focus! 

    tab-blur-with-div-control-highlight-and-input-focused: (e)->
      control = $ e.current-target 
      control.parents!remove-class 'focus'
      # control.find 'input, textarea' .focus! 


    add-typeahead-to-input-field: !(attr, candidates)~>
      let item = name: @template-name + attr, attr: attr # 这里要用闭包，多次的attr不一样
        @post-render-methods.push ->
          $ "input[name='#{item.attr}']" .typeahead do
            name:  item.name
            local: [str.trim! for str in candidates.split ',']

    add-form-validation: !->
      # Meteor.defer -> # 这里需要改进，因为parsley的加载问题，用ut
        # Meteor.defer ->
          # Meteor.defer ->
      # _until-obj-available '$.fn.parsley', ~>
      try
        form = $ 'form' .first!
        # console.log "form.context is: ", form.context
        form.parsley() # if form.context # Meteor会在这里执行两次，第一次时Parsley还没有完成form初始化
      catch error
        console.log error

    register-event-handlers: !->
      @events-handlers['focus div.controls'] = @tab-focuse-with-div-control-highlight-and-input-focused
      @events-handlers['blur div.controls input, div.controls textarea'] = @tab-blur-with-div-control-highlight-and-input-focused




  # 注意，这个方法会一直在每次event quene里尝试，直到找到obj，所以，慎用！
  # until-obj-available-timer = null
  # _until-obj-available = (obj-str, fn, args)->
  #   clear-timeout until-obj-available-timer if until-obj-available-timer
  #   console.log "****** obj-str ....", obj-str
  #   obj = eval obj-str
  #   # console.log "****** obj ....", obj
  #   if obj
  #         Meteor.defer -> fn.apply obj, args
  #   else
  #     console.log "****** wait ...."
  #     until-obj-available-timer = set-timeout  ->
  #       BP.until-obj-available obj-str, fn, args



create-bp-pages-for-doc = !(doc-name)->
  collection-name = doc-name.pluralize!
  @[collection-name.capitalize!] = new Meteor.Collection collection-name
  if Meteor.is-client
    list-page =  Bp-Helper.get-helper doc-name, 'list'
    detail-page = Bp-Helper.get-helper doc-name, 'detail'
    
    # 注意：不知道有无可能在router的controller里面，再初始化这些，这样会提高初次加载的速度
    list-page.init!
    detail-page.init!

@BP ||= {}

BP.create-bp-pages-for-doc = -> # 确保this指向顶层对象
  create-bp-pages-for-doc.apply null, arguments

if Meteor.is-client
  BP.create-tempalte-manager = Bp-Helper.get-helper # 这里用manager命名，因为controller被iron-router用了


