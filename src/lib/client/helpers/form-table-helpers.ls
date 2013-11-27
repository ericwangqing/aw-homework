@BP ||= {}
all-input-field-selector = 'input, select, textarea'
class Abstract-Form
  (@bpc)->
    @collection = @bpc.collection 

  register-event-handlers: (events-handlers)!->
    events-handlers['click a.bp-delete'] = @delete-submit

  delete-submit: (e)!~>
    if confirm "真的要删除吗？"
      doc-id = $ e.current-target .attr 'bp-doc-id'
      @collection.remove {_id: doc-id}
      alert 'remove successful!'
      Router.go @bpc.get-path 'list'

class @BP.Form extends Abstract-Form
  -> super ...
  
  register-event-handlers: (events-handlers)!->
    super ...
    events-handlers['focus div.controls input, div.controls textarea'] = @tab-focuse-with-div-control-highlight
    events-handlers['blur div.controls input, div.controls textarea'] = @tab-blur-with-div-control-highlight
    events-handlers['click a.bp-create'] = events-handlers['click a.bp-update'] = @create-and-update-submit

  tab-focuse-with-div-control-highlight: (e)!->
    control = $ e.current-target 
    control.parents!add-class 'focus'

  tab-blur-with-div-control-highlight: (e)!->
    control = $ e.current-target 
    control.parents!remove-class 'focus'
    # control.find 'input, textarea' .focus! 

  get-typeahead-render: ({config-name, input-name, candidates})->
    ->
      $ "input[name='#{input-name}']" .typeahead do
        name:  config-name
        local: [str.trim! for str in candidates.split ',']

  add-validation: !-> 
      try
        form = $ 'form' .first!
        # console.log "form.context is: ", form.context
        form.parsley() # if form.context # Meteor会在这里执行两次，第一次时Parsley还没有完成form初始化
      catch error
        console.log error

  create-and-update-submit: !~> 
    if $ 'form' .parsley 'validate'
      @update-doc-value!
      @collection.upsert {_id: @doc._id}, @doc
      alert 'submit successful!'
      Router.go @bpc.get-path 'list'

  update-doc-value: !->
    $ 'form' .find all-input-field-selector .each (index, input)!~>
      @update-by-json-path ($ input .attr 'name'), ($ input .val!)

  update-by-json-path: !(json-path, value)-> # TODO: 改为JSON Path实现，应对复杂表单
    # 目前仅仅是简单表单，input的name直接对应doc的attribute
    @doc[json-path] = value


class @BP.Table extends Abstract-Form
  -> super ...
