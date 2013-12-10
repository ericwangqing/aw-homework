class @BP.Detail-view extends BP.View
  ->
    super ...
    @transferred-state = BP.Abstract-data-manager.state-transferred-across-views
    @auto-insert-fields = {}
    
  create-data-manager: !-> @data-manager = new BP.Detail-data-manager @

  create-faces: !-> 
    @faces-manager = new BP.Detail-faces-manager @ 
    @faces = @faces-manager.create-faces!

  add-links: (list)!-> @links =
    create    : view: list,   face: list.faces.list
    update    : view: list,   face: list.faces.list
    'delete'  : view: list,   face: list.faces.list
    'next'    : view: @,      face: ~> @faces[@current-face-name] # 保持当前的face，仅仅更换id
    'previous': view: @,      face: ~> @faces[@current-face-name]

  change-to-face: (face-name, params)->
    super ...
    @data-manager.set-previous-and-next-ids!

  create-ui: !->
    @ui = new BP.Form @


