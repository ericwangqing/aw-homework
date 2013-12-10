class BP.List-view extends BP.View

  create-data-manager: !-> @data-manager = new BP.List-data-manager @

  create-faces: !-> 
    @faces-manager = new BP.List-faces-manager @ 
    @faces = @faces-manager.create-faces!

  create-ui: !->  @ui = new BP.Table @

  add-links: (detail)!-> @links =
    go-create : view: detail, face: detail.faces.create
    go-update : view: detail, face: detail.faces.update
    'delete'  : view: @,      face: @faces.list

