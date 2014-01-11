ABSTRACT-METHOD = !-> throw new Meteor.Error "This is a abstract method, you should implemented it first."

class @BP.Abstract-faces-manager
  (@view)->

  create-faces: -> ABSTRACT-METHOD!

  get-path: (pattern, doc)->
    path-pattern = if typeof pattern is 'function' then pattern! else pattern

  get-path-name: (face-name)->
    @view.name + '-' + face-name

  get-action-by-face: (face)->
    _.keys face .0 

# ------------------------ Detail -----------------------------
class @BP.Detail-faces-manager extends BP.Abstract-faces-manager
  create-faces: ->
    @id-place-holder = ':' + @view.doc-name + '_id'
    faces = 
      create    : "/#{@view.name}/create"
      update    : "/#{@view.name}/#{@id-place-holder}/update"   
      view      : "/#{@view.name}/#{@id-place-holder}/view"     # view没有操作按钮，有关联关系
      reference : "/#{@view.name}/#{@id-place-holder}/view"     # reference没有操作按钮，也没有关联关系

  get-path: (pattern, doc-or-id)-> 
    path-pattern = super ...
    if not doc-or-id then null else
      id = if typeof doc-or-id is 'string' then doc-or-id else doc-or-id._id
      path-pattern?.replace @id-place-holder, id

# ------------------------ List -----------------------------
class @BP.List-faces-manager extends BP.Abstract-faces-manager
  create-faces: -> 
    list      : "/#{@view.name}/list"
    view      : "/#{@view.name}/view"
    reference : "/#{@view.name}/reference"