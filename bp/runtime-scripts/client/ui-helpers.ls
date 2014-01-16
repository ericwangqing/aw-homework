@BP ||= {}
all-input-field-selector = 'input, select, textarea'

restrict-selector-to-view = (selector, view-selector)->
  (selector.split ',' .map -> it.trim! |> ("#{view-selector} " +) ).join ', '

class Abstract-Form
  (@view)->
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

  get-multi-ahead-render: (attr-name, doc, _config)->
    self = @
    ~>
      if _config and _config isnt '' and !_config.hash # 注意, Meteor会自动添加最后一个参数{hash: }，用来传递更多options
        value = doc[attr-name]
        eval 'config = ' + _config
        if config.is-meteor-users # for users-selector
          user-candidates = self.view.data-manager.get-meteor-users-data config
          data-config = 
            multiple: config.multiple
            data: user-candidates
        else
          if config.is-meteor-user # for default-current-user
            disabled = true # default-current-user 并非用户可选择的
            user = Meteor.user!
            data-config = 
              multiple: config.multiple
              data: [{id: user._id, text: user.profile.fullname}]
            value = [user._id]
          else # for options来自citedDoc的
            data-config = 
              multiple: config.multiple
              data: @view.data-manager.get-doc-data config
        multi-ahead = $ @rv "input[name='#{attr-name}']"
        multi-ahead.select2 data-config
        multi-ahead.select2 'val', value
        multi-ahead.select2 'enable', false if disabled
      else
        multi-ahead = $ @rv "select[name='#{attr-name}']"
        multi-ahead.select2 {}
        multi-ahead.select2 'val', doc[attr-name]

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
      # @collection.upsert {_id: @doc._id}, @doc # 注意！！，此处要改进，只
      console.log "collection-name: #{@view.names.meteor-collection-name}, doc: ", @doc
      Meteor.call 'bp-update-doc', @view.names.meteor-collection-name, @doc, -> # 此处不能直接在客户端用@collection.upsert，否则用户那些无权限查看的域，upsert后就消失了。
      alert 'submit successful!'
      window.location.href = e.current-target.href

  update-doc-value: !~>
    $ @rv 'form' .find all-input-field-selector .each (index, input)!~>
      attr-path-name = $ input .attr 'name'
      @update-by-json-path attr-path-name, @get-value input if attr-path-name
    @insert-auto-fields!

  get-value: (input)~>
    if $ input .has-class 'select2-hidden'
      $ input .select2 'val'
    else
      $ input .val!

  update-by-json-path: !(json-path, value)-> # TODO: 改为JSON Path实现，应对复杂表单
      # 目前仅仅是简单表单，input的name直接对应doc的attribute
      @doc[json-path] = value

  insert-auto-fields: !->
    for attr, auto-config of @view.data-manager.auto-insert-fields
      eval ("value = " + auto-config.expression)
      @doc[attr.camelize(false)] = value


class @BP.Table extends Abstract-Form
