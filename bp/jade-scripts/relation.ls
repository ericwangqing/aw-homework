class Relation
  @registry = {}

  @add-relation = (namespace, start, relation-description, end, type)!->
    relation = new Relation namespace, start, relation-description, end, type
    @_add-to-registry-of relation.start-point.doc-name, relation
    @_add-to-registry-of relation.end-point.doc-name, relation
    console.log "Registry is: ", @registry

  @_add-to-registry-of = (doc-name, relation)!->
    @registry[doc-name] ||= []
    @registry[doc-name].push relation

  @get-relations-by-doc-name = (doc-name)->
    @registry[doc-name] or []


  (@namespace, start-point, @relation-description, end-point, @type)!->
    @start-point = @get-point start-point
    @end-point = @get-point end-point
    console.log "******** relation created is: ", @

  get-point: (config)->
    if typeof config is 'string'
      {docName: config, showName: config}
    else
      config

  get-go-create-link: (current-end)->
    @get-link-by-action 'go-create', current-end

  get-go-update-link: (current-end)->
    @get-link-by-action 'go-update', current-end 

  get-opposite-end: (current-end)->
    if @start-point.doc-name is current-end then @end-point else @start-point

  get-link-by-action: (action, current-end)->
    destination-end = @get-opposite-end current-end
    face = @strip-go-prefix action
    {doc-name, show-name} = destination-end
    full-doc-name = @namespace + '.' +  doc-name
    view = if face is 'list' then 'list' else 'detail'

    link =
      icon: action
      path: action + '-' + full-doc-name
      to: [full-doc-name, view, face].join '.' 
      cited-doc: doc-name
      cited-view-type: view
      context: doc-name

    switch face 
    case 'create' 
      link.label = '创建' + show-name
      link.guard = "!#{doc-name}._id" 
      delete link.context
    case 'update' 
      link.label = '更新' + show-name
      link.guard = "#{doc-name}"
    case 'view' 
      link.label = '查看' + show-name
      link.guard = if view is 'detail' then "#{doc-name}" else 'true'  
    default 
      link.label = face + ': ' + show-name
      link.guard = 'true'

    link


  strip-go-prefix: (action)->
    if (action.index-of 'go-') >= 0 then face = action - 'go-' else face = action
    face = 'list' if action is 'go'
    face

  get-query: (doc-name)->
    if doc-name is @startPoint.doc-name
      query = "{#{doc-name}Id: doc._id}"
    else
      query = "{_id: doc.#{@startPoint.doc-name}Id}"


if module? then module.exports = Relation else BP.Relation = Relation # 让Jade和Meteor都可以使用
