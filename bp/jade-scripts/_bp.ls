# !!! 注意，此文件不是运行时代码，是开发时代码。
## 给Jade用，根据template中的定义，动态编译出Views，以便BP Router加载。

require! [fs, 'jade', './Names', './Relation', './Page']
_ = require 'underscore'

jade.filters <<< filters = require './_bp-filters'


module.exports =
  components: []
  relations: []
  pages: []
  variables: {}

  add-component: (namespace, doc-name, is-main-nav, class-name)->
    @init-variables(namespace, doc-name)
    @components.push {namespace, doc-name, is-main-nav, class-name}

  init-variables: (namespace, doc-name)!->
    @variables[namespace] ||= {}
    @variables[namespace][doc-name] ||= table:
      row-links: []
      row-multiple-links: []
      table-links: []
      removed-links: []    
    # console.log "init variables for: #namespace, #doc-name. @variables are: ", JSON.stringify @variables[namespace][doc-name]

  ## 声明式relation
  add-relation: (namespace, start, relation-description, end, type)!-> 
    @relations.push relation = {namespace, start, relation-description, end, type}
    relation = Relation.add-relation relation # 实例化后，给jade在compile模板时使用

  add-page: (namespace, name, is-main-nav)->
    @pages.push page = new Page {namespace, name, is-main-nav}
    page

  save-page: !->
    @_save-all-configuration!

  _save-all-configuration: !->
    fs.write-file-sync 'bp/main.ls', 
      "BP.Component.create-components #{JSON.stringify @components}, #{JSON.stringify @relations}\n" +
      "BP.Page.create-pages #{JSON.stringify @pages}"

  value: (attr)->
    if (attr.index-of '.') > 0
      [doc-name, attr] = attr.split '.' 
      result = "{{\#with #doc-name}} {{bs '#attr'}} {{/with}}"
    else
      result = "{{bs '#attr'}}" 
    # console.log "attr is: #attr, result is: ", result
    # result

  get-names: (namespace, doc-name)-> 
    @names = new Names namespace, doc-name  

  get-attr-name: (full-attr-name)->
    _.last full-attr-name.split '.'

  get-doc-name: (full-attr-name)->
    _.first full-attr-name.split '.'

  save-component: !->
    @_save-all-configuration!

  ## 将jade渲染之后的template保存起来，以便在引用的时候，更名使用。避免直接用Handlebars的include {{> }}时，同名的template，实际上使用的是相同的helpers，拥有同样的状态。
  register-template: (templateName, templateStr)!->
    @template-registry ||= {}
    @template-registry[templateName] = templateStr

  show-template: (template-str)!->
    console.log template-str

  get-relations: (doc-name)->
    Relation.get-relations-by-doc-name doc-name

  get-view-template-name: (namespace, doc-name, view-name)->
    names = @get-names(namespace, doc-name)
    if view-name is 'list' then names.list-template-name else names.detail-template-name

  get-table-config: (namespace, doc-name)->
    config = @variables[namespace][doc-name].table
    # console.log "namespace: #namespace, doc-name: #doc-name, config: ", config
    # config

  add-item-link: (namespace, doc-name, link)->
    @variables[namespace][doc-name].table.row-links.push link

  add-item-links: (namespace, doc-name, link)->
    @variables[namespace][doc-name].table.row-multiple-links.push link

  add-list-link: (namespace, doc-name, link)->
    @variables[namespace][doc-name].table.table-links.push link

  remove-link: (namespace, doc-name, linkName)->
    @variables[namespace][doc-name].table.removed-links.push linkName
    @variables[namespace][doc-name].table.removed-links.unique!
