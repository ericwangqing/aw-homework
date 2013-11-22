class Bp-Helper # abstract
  
  @get-instance = (doc-name, template-type, template-name)->
    if template-type is 'list'
      new Bp-List-Helper doc-name, template-name
    else if template-type is 'item'
      new Bp-Item-Helper doc-name, template-name

  # 每个Bp-Helper对应一种doc，每种doc构成一个collection，有List和Item两种templates
  # collection name是doc name的复数大写形式，如：Assignments
  # @param template-type: list | item
  # list：列表该collection的doc，对应实现对doc的删除操作，并给出和去”添加“和去”修改“的链接（按钮）
  # item：展示一个doc的详情，对应修改、添加和评论操作
  (@doc-name)->
    @collection = eval @doc-name.pluralize!capitalize!
    @helpers = {}
    # @permission-checkers = {}
    @post-render-methods = []

  init: !->
    @register-data-retriever!
    # @register-bp-permission-checker!
    # @register-post-render-methods!
    Template[@template-name].helpers @helpers
    Template[@template-name].rendered = !~>
      [method! for method in @post-render-methods]

  register-data-retriever: !->
    @helpers[@data-helper-name] = @data-retriever




class Bp-List-Helper extends Bp-Helper
  # list型的template name默认为"doc-name的复数-list"，如：assignments-list
  (doc-name, template-name)->
    super doc-name
    @template-name = if template-name then template-name else @doc-name.pluralize! + '-list'
    # template上通过这个名字的helper，获取数据。约定为"doc-name的复数"
    @data-helper-name = @doc-name.pluralize!
  
  data-retriever: (query = {})-> 
    @collection.find query




class Bp-Item-Helper extends Bp-Helper
  # item型的template name默认与doc-name一致
  (doc-name, template-name)->
    super doc-name
    @template-name = if template-name then template-name else @doc-name
    # template上通过这个名字的helper，获取数据。约定为"doc-name"
    @data-helper-name = @doc-name
    @helpers['bp-add-typeahead'] = @add-typeahead-to-input-field
    @post-render-methods.push @add-form-validation
    @post-render-methods.push @add-form-validation

  data-retriever: (query = {})-> # TODO：这里查询待完善
    @collection.find-one!

  add-typeahead-to-input-field: !(attr, candidates)~>
    let item = name: @template-name + attr, attr: attr # 这里要用闭包，多次的attr不一样
      @post-render-methods.push ->
        $ "input[name='#{item.attr}']" .typeahead do
          name:  item.name
          local: [str.trim! for str in candidates.split ',']

  add-form-validation: !->
    form = null
    try
      form = ($ @find 'form').first!
      # console.log "form.context is: ", form.context
      form?.parsley('validate') if form.context # Meteor会在这里执行两次，第一次时Parsley还没有完成form初始化
    catch error
      console.log error


@BP ||= {}
BP.create-tempalte-manager = Bp-Helper.get-instance # 这里用manager命名，因为controller被iron-router用了