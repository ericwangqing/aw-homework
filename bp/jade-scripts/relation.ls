## used both at developing time by jade and runtime by meteor
class Relation
  @registry = {}

  @add-relation = ({namespace, start, relation-description, end, type})!->
    relation = new Relation {namespace, start, relation-description, end, type}
    @_add-to-registry-of relation.start-point.doc-name, relation
    @_add-to-registry-of relation.end-point.doc-name, relation
    # console.log "Registry is: ", @registry

  @_add-to-registry-of = (doc-name, relation)!->
    @registry[doc-name] ||= []
    @registry[doc-name].push relation

  @get-relations-by-doc-name = (doc-name)->
    @registry[doc-name] or []

  ({@namespace, start, @relation-description, end, @type})!-> #type: compositon | aggregation
    @get-points start, end
    # console.log "******** relation created is: ", JSON.stringify @

  get-points: (start, end)->
    @start-point = (@get-names start) <<< type: 'start'
    @end-point = (@get-names end) <<< type: 'end'
    [@start-point.multiplicity, navigating-direction, @end-point.multiplicity] = @relation-description.split /\s+/
    @mark-ability-of-create-other-side!

  get-names: (point)->
    if typeof point is 'string'
      {docName: point, showName: point}
    else
      Object.clone point

  mark-ability-of-create-other-side: !->
    @start-point.can-create-other-side = true
    if @type is 'composition'
      @end-point.can-create-other-side = false
    else # 'aggregation'
      @end-point.can-create-other-side = true

  get-go-create-link: (current-end)->
    @get-link-by-action 'go-create', current-end

  get-go-update-link: (current-end)->
    @get-link-by-action 'go-update', current-end 

  get-current-end: (current-end)->
    if @start-point.doc-name is current-end then @start-point else @end-point

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
      path: [action, @namespace, doc-name].join '-' .camelize false
      to: {@namespace, doc-name, view, face}
      cited-doc: doc-name
      show-name: show-name
      cited-view-type: view
      context: doc-name

    @_alter-link-by-face destination-end, link, face, doc-name, show-name 
    # console.log "action: #action, current-end: #currentEnd, link: ", link
    # link


  _alter-link-by-face: (destination-end, link, face, doc-name, show-name)->
    switch face 
    case 'create' 
      link.label = '创建' + show-name
      link.guard = if destination-end.multiplicity is '1' then "!#{doc-name}._id" else true
      delete link.context
    case 'update' 
      link.label = if destination-end.multiplicity is '1' then "更新#{show-name}" else "更新{{bs '#{destination-end.show-attr}'}}"
      link.guard = if destination-end.multiplicity is '1' then "#{doc-name}" else "#{doc-name.pluralize!}"
    case 'view' 
      link.label = if destination-end.multiplicity is '1' then "更新#{show-name}" else "更新{{bs '#{destination-end.show-attr}'}}"
      if view is 'detail' 
        link.guard = if destination-end.multiplicity is '1' then "#{doc-name}" else "#{doc-name.pluralize!}"
      else 
        link.guard = 'true'  
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
      query = "{_id: doc.#{doc-name}Id}"
    else
      query = "{#{@startPoint.doc-name}Id: doc._id}"

if module? then module.exports = Relation else BP.Relation = Relation # 让Jade和Meteor都可以使用