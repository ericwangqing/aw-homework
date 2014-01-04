# !!! 注意，此文件不是运行时代码，是开发时代码。
## 给Jade用，根据template中的定义，动态编译出Views，以便BP Router加载。

require! [fs, 'jade', './_view'.View, './Names', './Relation']
_ = require 'underscore'

jade.filters <<< filters = require './_jade-filters'

module.exports =
  components: []
  relations: []

  add-component: (namespace, doc-name, is-main-nav, class-name)->
    @components.push {namespace, doc-name, is-main-nav, class-name}

  ## 声明式relation
  add-relation: (namespace, start, relation-description, end, type)!-> 
    @relations.push relation = {namespace, start, relation-description, end, type}
    relation = Relation.add-relation relation # 实例化后，给jade在compile模板时使用

  value: (attr)->
    if (attr.index-of '.') > 0
      [doc-name, attr] = attr.split '.' 
      result = "{{\#with #doc-name}} {{bs '#attr'}} {{/with}}"
    else
      result = "{{bs '#attr'}}"
    console.log "attr is: #attr, result is: ", result
    result

  get-names: (namespace, doc-name)-> 
    @names = new Names namespace, doc-name  

  get-attr-name: (full-attr-name)->
    _.last full-attr-name.split '.'

  save-view: !->
    fs.write-file-sync 'bp/main.ls', "BP.Component.create-components #{JSON.stringify @components}, #{JSON.stringify @relations}"

  ## 将jade渲染之后的template保存起来，以便在引用的时候，更名使用。避免直接用Handlebars的include {{> }}时，同名的template，实际上使用的是相同的helpers，拥有同样的状态。
  register-template: (templateName, templateStr)!->
    @template-registry ||= {}
    @template-registry[templateName] = templateStr

  show-template: (template-str)!->
    console.log template-str


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
      opposite-end = relation.get-opposite-end(doc-name)
      cited[opposite-end.doc-name] = 
        query: relation.get-query(doc-name)
        is-multiple: opposite-end.multiplicity isnt '1' 
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

_code = '''
BP.Component.create-components 
'''




