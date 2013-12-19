@BP ||= {}
all-input-field-selector = 'input, select, textarea'

restrict-selector-to-view = (selector, view-selector)->
  (selector.split ',' .map -> it.trim! |> ("#{view-selector} " +) ).join ', '

class Abstract-Form
  (view)->
    @view = view
    @collection = BP.Collection.get view.names.meteor-collection-name
    @view-selector = "div[bp-view-name='#{@view.name}']"
    @events-handlers = {}
    @rv = restrict-selector-to-view _, @view-selector

  register-event-handlers: ->
    @events-handlers['click ' + @rv 'a.bp-delete'] = @delete-submit
    @events-handlers
    
  delete-submit: (e)!~>
    e.prevent-default
    if confirm "真的要删除吗？"
      doc-id = $ e.current-target .attr 'bp-doc-id'
      @collection.remove {_id: doc-id} # 对collection的操作是否应该移回到component中？
      alert 'remove successful!'
      window.location.href = e.current-target.href

  show-hide-references: !~>
    $ @rv 'i.reference' .click (e)!-> # 可否考虑为全页面就设定一次呢？
      ref = $ e.current-target .attr 'bp-view-name'
      $ "div.reference[bp-view-name='#ref']" .toggle!

class @BP.Form extends Abstract-Form
  
  register-event-handlers: ->
    super ...
    @events-handlers['focus ' + @rv 'div.controls input, div.controls textarea'] = @tab-focuse-with-div-control-highlight
    @events-handlers['blur '  + @rv 'div.controls input, div.controls textarea'] = @tab-blur-with-div-control-highlight
    @events-handlers['click ' + @rv 'a.bp-create'] = @events-handlers['click ' + @rv 'a.bp-update'] = @create-and-update-submit
    @events-handlers

  tab-focuse-with-div-control-highlight: (e)!->
    control = $ e.current-target 
    control.parents!add-class 'focus'

  tab-blur-with-div-control-highlight: (e)!->
    control = $ e.current-target 
    control.parents!remove-class 'focus'
    # control.find 'input, textarea' .focus! 

  get-typeahead-render: ({config-name, input-name, candidates})->
    ~>
      $ @rv "input[name='#{input-name}']" .typeahead do
        name:  config-name
        local: [str.trim! for str in candidates.split ',']

  get-multi-ahead-render: (select-name, config)->
    ~>
      Meteor.defer ~>
        multi-ahead = $ @rv "select[name='#{select-name}']"
        $ @rv "select[name='#{select-name}']" .select2 (config or {})

  add-validation: !~> 
    try
      form = $ @rv 'form' .first!
      # console.log "form.context is: ", form.context
      form.parsley() # if form.context # Meteor会在这里执行两次，第一次时Parsley还没有完成form初始化
    catch error
      console.log error

  create-and-update-submit: (e)!~> 
    e.prevent-default!
    if $ @rv 'form' .parsley 'validate'
      @update-doc-value!
      @collection.upsert {_id: @doc._id}, @doc
      alert 'submit successful!'
      window.location.href = e.current-target.href

  update-doc-value: !~>
    $ @rv 'form' .find all-input-field-selector .each (index, input)!~>
      @update-by-json-path ($ input .attr 'name'), ($ input .val!)
    @insert-auto-fields!

  update-by-json-path: !(json-path, value)-> # TODO: 改为JSON Path实现，应对复杂表单
      # 目前仅仅是简单表单，input的name直接对应doc的attribute
      @doc[json-path] = value

  insert-auto-fields: !->
    for attr, auto-config of @view.data-manager.auto-insert-fields
      eval ("value = " + auto-config.expression)
      @doc[attr.camelize(false)] = value


class @BP.Table extends Abstract-Form
  # ------------- 下面改用Router的Before 来实现了 ----------------------
  # register-event-handlers: (events-handlers)!->
  #   super ...
  #   events-handlers['click a.bp-update'] = @record-previous-and-next-link-in-session # 去到detail时，需要渲染“上一条”、“下一条”

  # record-previous-and-next-link-in-session: (e)!->
  #   current-tr = $ e.current-target .closest 'tr'
  #   pre = current-tr.prev().find('a.bp-update').attr 'href'
  #   next = current-tr.next().find('a.bp-update').attr 'href'
  #   BP.State.set {pre-href: pre, next-href: next}
