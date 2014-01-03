# !!! 注意，此文件不是运行时代码，是开发时代码。
## 给Jade用，根据template中的定义，动态编译出Views，以便BP Router加载。

require! [fs, 'jade', './_view'.View, './Names', './Relation']
_ = require 'underscore'

jade.filters <<< filters = require './_jade-filters'

module.exports =

  get-view: (doc-name, component-name, template-name, template-type)->
    @view = View.get-view.apply View, &

  set-main-nav: (template-names)->
    template-names = template-names.split ',' if typeof template-names is 'string'
    for name in template-names
      name = name.trim!
      View.registry[name].is-main-nav = true

  value: (attr)->
    if (attr.index-of '.') > 0
      [doc-name, attr] = attr.split '.' 
      result = "{{\#with #doc-name}} {{bs '#attr'}} {{/with}}"
    else
      result = "{{bs '#attr'}}"
    console.log "attr is: #attr, result is: ", result
    result

  get-cited-doc-name: (attr, cited)->
    for doc-name, cite of cited
      return doc-name if cite.attributes and attr in cite.attributes 

  get-cited-doc: (attr, cited)->
    # console.log "attr: #attr, cited: ", cited
    for doc-name, cite of cited
      return doc-name if cite.attributes and attr in cite.attributes 
    null

  # set-custom-class-name: (class-name)-> @view.custom-class = class-name

  get-ref-name: (ref)->
    switch ref
    case 'detail' then @names.detail-template-name
    case 'list' then @names.list-template-name
    default ref

  get-names: (doc-name, component-name)-> 
    @names = new Names doc-name, component-name  

  get-attr-name: (full-attr-name)->
    _.last full-attr-name.split '.'

  save-view: !->
    fs.write-file-sync 'bp/main.ls', code + (JSON.stringify View.registry)

  ## 将jade渲染之后的template保存起来，以便在引用的时候，更名使用。避免直接用Handlebars的include {{> }}时，同名的template，实际上使用的是相同的helpers，拥有同样的状态。
  register-template: (templateName, templateStr)!->
    @template-registry ||= {}
    @template-registry[templateName] = templateStr

  show-template: (template-str)!->
    console.log template-str

  ## 声明式relation
  add-relation: (component-name, start, relation-description, end, type)!->
    Relation.add-relation component-name, start, relation-description, end, type

  get-relations: (doc-name)->
    Relation.get-relations-by-doc-name doc-name

  get-go-create-link: (current-end, relation)->
    relation.get-go-create-link current-end
  
  get-go-update-link: (current-end, relation)->
    relation.get-go-update-link current-end

  get-cited: (doc-name)->
    relations = Relation.get-relations-by-doc-name doc-name
    cited = {}
    for relation in relations
      cited[relation.getOppositeEnd(doc-name).doc-name] = query: relation.get-query(doc-name)
    cited




code = ''' 
# ********************************************************
# *                                                      *
# *        IT IS AUTO GENERATED DON'T EDIT               *
# *                                                      *
# ********************************************************

# if module?
#   require! [fs, sugar, './Component'] 

# BP ||= {}
# BP.Component ||= Component

# debugger
BP.Component.create-components-from-jade-views jade-views = 
'''



