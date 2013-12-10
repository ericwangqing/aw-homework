class @BP.Detail-view extends BP.View
  ->
    super ...
    @transferred-state = BP.Abstract-data-manager.state-transferred-across-views
    @auto-insert-fields = {}
    
  create-data-manager: !-> @data-manager = new BP.Detail-data-manager @

  create-view-appearances: !-> # doc: 目前reference只支持 detail类型。
    @id-place-holder = ':' + @name + '_id'
    @appearances = 
      create    : '/' + @name + '/create'
      update    : '/' + @name + '/' + @id-place-holder + '/update'   
      view      : '/' + @name + '/' + @id-place-holder + '/view'     
      reference : '/' + @name + '/' + @id-place-holder + '/reference' 

  get-appearance-path: (appearance, doc)-> 
    return null if not doc
    path-pattern = if typeof appearance is 'function' then appearance! else appearance
    path-pattern?.replace @id-place-holder, doc._id

  add-links: (list)!-> @links =
    create    : view: list,   appearance: list.appearances.list
    update    : view: list,   appearance: list.appearances.list
    'delete'  : view: list,   appearance: list.appearances.list
    'next'    : view: @,      appearance: ~> @appearances[@current-appearance-name] # 保持当前的appearance，仅仅更换id
    'previous': view: @,      appearance: ~> @appearances[@current-appearance-name]



  change-to-appearance: (appearance-name, params)->
    BP.RRR = @ # 调试
    super ...
    @doc-ids = @transferred-state.get 'doc-ids'
    if @doc-id and @doc-ids and not _.is-empty @doc-ids
      @update-previous-and-next-ids!

  update-previous-and-next-ids: !->
    pre = next = null
    for id, index in @doc-ids
      break if id is @doc-id
      pre = id
    next = @doc-ids[index + 1] 
    @previous-id = pre
    @next-id = next

  create-ui: !->
    @ui = new BP.Form @


