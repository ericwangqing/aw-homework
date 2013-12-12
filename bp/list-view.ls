class BP.List-view extends BP.View

  create-data-manager: !-> 
    debugger
    @data-manager = new BP.List-data-manager @

  create-faces: !-> 
    @faces-manager = new BP.List-faces-manager @ 
    @faces = @faces-manager.create-faces!

  create-ui: !->  @ui = new BP.Table @

  add-links: (detail)!-> @links =
    go-create : view: detail, face: detail.faces.create
    go-update : view: detail, face: detail.faces.update
    'delete'  : view: @,      face: @faces.list

  add-to-template-rendered: -> 
    if @additional-links and not _.is-empty @additional-links
      @add-addtional-links-data-transfer!

  add-addtional-links-data-transfer: ->
    view = @
    [
      !-> $ 'a[class^="bp-"]' .filter ->
        view.is-link-to-cited-doc @
      .click (e)!->
        # alert('haha')
        view.save-data-for-additional-link-in-transferred-state e
    ]

  save-data-for-additional-link-in-transferred-state: _.once (e)!->
    clicked-link = $ e.current-target
    current-doc-id = clicked-link.closest '.current-doc-id' .attr 'bp-doc-id'
    current-doc = @data-manager.collection.find-one _id: current-doc-id
    @data-manager.set-transferred-state @names.doc-name, current-doc

  is-link-to-cited-doc: (link)->
    for {doc-name, query} in @data-manager.cited-data
      return true if ($ link .attr 'href' .index-of doc-name) >= 0
    false

