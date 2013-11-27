# BPH组件，Meteor Template需要的各种Helper
@BP ||= {}
do make-handlebars-understand-chinese-key = !->
  Handlebars.register-helper 'bs', (attr)-> # 克服Meteor Handlebars不能使用中文key，形如{{中文}}会出错的问题。改用{{bs '中文'}}
    @[attr]

class @BP.Template-Helper # abstract and Factory
  # Factory method
  @get-helper = (bpc, template-type)->
    if template-type is 'list'
      new List-Template-Helper bpc
    else if template-type is 'detail'
      new Detail-Template-Helper bpc

  (@bpc)->
    @collection = @bpc.collection
    @helpers = {}
    @events-handlers = {}
    @post-render-methods = []
    @permission = new BP.Permission!

  init: !-> 
    self = @
    @register-data-retriever!
    @register-permission-checker!
    @register-event-handlers!
    @register-path-helper!
    Template[@template-name].helpers @helpers
    Template[@template-name].events @events-handlers
    Template[@template-name].rendered = !->
      [method.call @ for method in self.post-render-methods]

  get-current-action: ->
    # current-action-obj = Session.get 'bp-current-actions'
    # find-current-action-on @doc-name, @doc?_id
    # 'create' # 暂时开发时用
    BP.State.get 'action'

  register-data-retriever: !-> 
    @helpers[@data-helper-name] = @data-retriever

  register-permission-checker: !->
    @helpers['bp-attribute-permit'] = @permission.attribute-permission-checker
    @helpers['bp-doc-permit'] = @permission.doc-permission-checker
    @helpers['bp-collection-permit'] = @permission.collection-permission-checker
    @helpers['bp-action-is'] = (action)~>
      action is @get-current-action!

  register-event-handlers: !-> # both list and detail page have delete
    @form.register-event-handlers @events-handlers
    # @events-handlers['click a.bp-delete'] = @form.delete-submit

  register-path-helper: !->
    @helpers['bp-path-for'] = @bpc.get-path

class List-Template-Helper extends BP.Template-Helper
  (bpc)->
    super bpc
    @template-name = bpc.names.list-template-name
    @data-helper-name = bpc.names.list-data-retriever-name
    @form = new BP.Table bpc
  
  data-retriever: ~> 
    @docs = @collection.find! .fetch!
    BP.State.set 'doc-ids', [doc._id for doc in @docs]
    @docs

class Detail-Template-Helper extends BP.Template-Helper
  (bpc)->
    super bpc
    @template-name = bpc.names.detail-template-name
    @data-helper-name = bpc.names.detail-data-retriever-name
    @form = new BP.Form bpc
    @add-ui-functionalities!

  data-retriever: ~> # TODO：这里查询待完善
    if (BP.State.get 'action') is 'update'
      @form.doc = @collection.find-one _id: (BP.State.get 'current-id')
      return @form.doc
    else
      @form.doc ={}

  add-ui-functionalities: !->
    @enable-pre-next-links!
    @enable-typeahead-fields!
    @enable-form-validation!

  enable-pre-next-links: !-> 
    @helpers['bp-pre-link'] = ~> 
      if pid = BP.State.get 'previous-id'
        @bpc.get-path 'update', pid # 只有update时有，create时没有 “上一条”、“下一条”
    @helpers['bp-next-link'] = ~> 
      if nid = BP.State.get 'next-id'
        @bpc.get-path 'update', nid

  enable-typeahead-fields: !->
    @helpers['bp-add-typeahead'] = @add-typeahead-to-input-field

  enable-form-validation: !->
    @post-render-methods.push @form.add-validation

  add-typeahead-to-input-field:  (attr, candidates)!~> # 模板中的ahead控件将调用它，以便render后，动态添加typeahead功能
    @post-render-methods.push @form.get-typeahead-render do
      config-name: @template-name + attr #一个页面可能有多个表单，一个表单有多个typeahead的域
      input-name: attr
      candidates: candidates

  