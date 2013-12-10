class BP.List-view extends BP.View

  create-data-manager: !-> @data-manager = new BP.List-data-manager @

  create-view-appearances: !->
    @appearances = 
      list      : "/#{@name}/list"
      view      : "/#{@name}/view"
      reference : "/#{@name}/reference"

  get-appearance-path: (appearance)-> 
    path-pattern = if typeof appearance is 'function' then appearance! else appearance
    path-pattern

  add-links: (detail)!-> @links =
    go-create : view: detail, appearance: detail.appearances.create
    go-update : view: detail, appearance: detail.appearances.update
    'delete'  : view: @,      appearance: @appearances.list


  create-ui: !->
    @ui = new BP.Table @
