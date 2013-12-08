@BP ||= {}
# Adpater 本身没有状态，因此可以被多个有相同template的view共用：
# 1）状态保存在view的state里，通过view操作
class @BP.Template-adapter
  @get = (view)->
    switch view.type
    case 'list'   then new List-template-adpater   view
    case 'detail' then new Detail-template-adpater view
    default throw new Error "type: '#type' is not supported yet."

  (@view)->
    @template = Template[view.template-name] # Meteor的template实际上是一个加载template html之后，编译成的函数。也就是说只编译一次，因此不会出现变化。
    @permission = new BP.Permission! # permission与view无关，因此可以共用。
    @data-retriever-name = if @view.type is 'list' then @view.names.list-data-retriever-name else @view.names.detail-data-retriever-name
    @create-helpers!
    @create-renderers!
    @create-event-handlers!
    @template.helpers @helpers
    @template.events @events-handlers 
    @template.rendered = !~> 
      [method.call @ for method in @renderers]

  create-helpers: !->
    @helpers =
      "bp-attribute-permit"           :  @permission.attribute-permission-checker
      "bp-doc-permit"                 :  @permission.doc-permission-checker
      "bp-collection-permit"          :  @permission.collection-permission-checker
      "bp-action-is"                  :  @view.current-action-checker
      "bp-path-for"                   :  @view.get-path
      "#{@data-retriever-name}"       :  @view.data-retriever 

  create-renderers: !-> @renderers = []

  create-event-handlers: !-> @events-handlers = @view.ui.register-event-handlers!
    
# ----------------------- Detail ---------------------------------
class List-template-adpater extends BP.Template-adapter


class Detail-template-adpater extends BP.Template-adapter
  create-helpers: !->
    super ...
    @helpers <<<
      "bp-auto-insert"        : @add-auto-insert-field
      "bp-pre-link"           : @enable-nav-link("previous") 
      "bp-next-link"          : @enable-nav-link("next") 
      "bp-add-typeahead"      : @enable-add-typeahead-to-input-field! 

  add-auto-insert-field: !(attr, expression)~>
    console.log "attr: #attr, expression: #expression"
    @view.auto-insert-fields[attr] = attr: attr, expression: expression

  create-renderers: !->
    super ...
    @renderers.push @view.ui.show-hide-references # 需要在selector里面写入当前view-name
    @renderers.push @view.ui.add-validation

  enable-add-typeahead-to-input-field: -> 
    (attr, candidates)!~> # 模板中的ahead控件将调用它，以便render后，动态添加typeahead功能
      @renderers.push @view.ui.get-typeahead-render do
        config-name: @view.name + attr #一个页面可能有多个表单，一个表单有多个typeahead的域
        input-name: attr
        candidates: candidates

  enable-nav-link: (nav)->
    ~>
      @view.get-path action = nav, if nav is 'previous' then @view.previous-id else @view.next-id # 这里需要考虑组合view的情况，要得到整体的path，现在只是局部




/* ------------------------ Private Methods ------------------- */
