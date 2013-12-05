@BP ||= {}
# Adpater 本身没有状态，因此可以被多个有相同template的view共用：
# 1）状态保存在view的state里，通过view操作
# 2）注册到Meteor的helper，加上了view.name的前缀，以便Meteor调用时，能够链接回正确的view
class @BP.Template-adapter
  @get = (type, names, template)->
    switch type
    case 'list'   then new List-template-adpater   template, names.list-data-retriever-name
    case 'detail' then new Detail-template-adpater template, names.detail-data-retriever-name
    default throw new Error "type: '#type' is not supported yet."

  (@template, @data-retriever-name)->
    @view = null # 等待Iron-Router在before方法中通过component.change-to-view方法设定。
    @permission = new BP.Permission! # permission与view无关，因此可以共用。

  wire-view: !(view)->
    @view = view
    @data-retriever = view.data-retriever
    @data-retriever-name = view.name + '-' + @data-retriever-name
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
      "#{@view.name}-bp-action-is"    :  @view.current-action-checker
      "#{@view.name}-bp-path-for"     :  @view.get-path
      "#{@data-retriever-name}"       :  @view.data-retriever 

  create-renderers: !-> @renderers = []

  create-event-handlers: !-> @events-handlers = @view.ui.register-event-handlers!
    
# ----------------------- Detail ---------------------------------
class List-template-adpater extends BP.Template-adapter


class Detail-template-adpater extends BP.Template-adapter

  create-helpers: !->
    super ...
    @helpers <<<
      "#{@view.name}-bp-pre-link"           : @_enable-nav-link("previous") 
      "#{@view.name}-bp-next-link"          : @_enable-nav-link("next") 
      "#{@view.name}-bp-add-typeahead"      : @_enable-add-typeahead-to-input-field! 

  create-renderers: !->
    super ...
    @renderers.push @view.ui.show-hide-references # 需要在selector里面写入当前view-name
    @renderers.push @view.ui.add-validation

  _enable-add-typeahead-to-input-field: -> 
    let self = @, view = @view
      (attr, candidates)!-> # 模板中的ahead控件将调用它，以便render后，动态添加typeahead功能
        self.renderers.push view.ui.get-typeahead-render do
          config-name: view.name + attr #一个页面可能有多个表单，一个表单有多个typeahead的域
          input-name: attr
          candidates: candidates

  _enable-nav-link: (nav)->
    let view = @view # 用闭包保证多个view，各自有自己的path
      ->
        if doc-id = view.get-state nav + '-id'
          view.get-path action = nav, doc-id # 这里需要考虑组合view的情况，要得到整体的path，现在只是局部




/* ------------------------ Private Methods ------------------- */

