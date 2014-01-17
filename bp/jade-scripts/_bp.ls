# !!! 注意，此文件不是运行时代码，是开发时代码。
## 给Jade用，根据template中的定义，动态编译出Views，以便BP Router加载。

require! [fs, 'jade', './Names', './Relation', './Page']
config = require './_bp-config'
_ = require 'underscore'

jade.filters <<< filters = require './_bp-filters'


module.exports =
  components: []
  relations: []
  pages: []
  variables: {}

  set-app: (@app-name, @config)!->  

  add-component: (namespace, doc-name, main-nav, class-name)->
    @init-variables(namespace, doc-name)
    @components.push {namespace, doc-name, main-nav, class-name}

  init-variables: (namespace, doc-name)!->
    config.init namespace, doc-name

  ## 声明式relation
  add-relation: (namespace, start, relation-description, end, type)!-> 
    @relations.push relation = {namespace, start, relation-description, end, type}
    relation = Relation.add-relation relation # 实例化后，给jade在compile模板时使用

  add-page: -> #: {@namespace, @name, @main-nav, @show-list-relations, @show-detail-relations}
    @pages.push page =  new Page @config <<< &.0

    page

  save-page: !->
    @_save-all-configuration!

  _save-all-configuration: !->
    app-name = if @app-name then "'#{@app-name}'" else undefined
    fs.write-file-sync 'bp/main.ls', 
      "BP.App-name = #{app-name}\n" +
      "BP.Component.create-components #{JSON.stringify @components}, #{JSON.stringify @relations}\n" +
      "BP.Page.create-pages #{JSON.stringify @pages}"

  value: (attr)->
    if (attr.index-of ':User') > 0 or (attr.index-of ':user') > 0 # 此时关联Meteor User，存储id，显示fullname
      attr-name = attr.split ':' .0
      result = "{{bs-user '#attr-name'}}"
    else if (attr.index-of '.') > 0
      [doc-name, attr] = attr.split '.' 
      result = "{{\#with #doc-name}} {{bs '#attr'}} {{/with}}"
    else
      result = "{{bs '#attr'}}" 
    # console.log "attr is: #attr, result is: ", result
    # result

  get-names: (namespace, doc-name)-> 
    @names = new Names namespace, doc-name  

  get-attr-name: (full-attr-name)->
    name = _.first full-attr-name.split ':' # 去掉修饰符
    name = _.last name.split '.' # 去掉cited-doc-name

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
    config.get-config namespace, doc-name .table
    # console.log "namespace: #namespace, doc-name: #doc-name, config: ", config
    # config

  add-item-link: -> config.add-item-link.apply config, &
  add-item-links: -> config.add-item-links.apply config, &
  add-list-link: -> config.add-list-link.apply config, &
  remove-link: -> config.remove-link.apply config, &

