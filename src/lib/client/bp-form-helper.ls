@BP ||= {}
all-input-field-selector = 'input, select, textarea'
class @BP.Form
  (@bpc)->
    @collection = @bpc.collection

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


  delete-submit: (e)!~>
    doc-id = $ e.current-target .attr 'bp-doc-id'
    @collection.remove {_id: doc-id}
    alert 'remove successful!'
    Router.go @bpc.get-path 'list'
