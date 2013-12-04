class @BP.Template-adapter
  @get = (type, names, template)->
    switch type
    case 'list'   then new List-template-adpater   template, names[list-data-retriever-name]
    case 'detail' then new Detail-template-adpater template, names[detail-data-retriever-name]
    default throw new Error "type: '#type' is not supported yet."

  (@data-retriever-name, @template)->
    @view = null # 等待Iron-Router在before方法中通过component.change-to-view方法设定。
    @permission = new BP.Permission!

  wire-view: !->
    @view = view
    @ui = view.ui
    @data-retriever-name = @view-name + '-' + @data-retriever-name
    @create-helpers!
    @create-renderers!
    @create-event-handlers!
    @template.helpers @helpers
    @template.events @events-handlers
    @template.rendered = !->
      [method.call @ for method in self.post-render-methods]

  data-retriever: ~> @view.data-retriever.apply @view, &

  create-helpers: !->
    @helpers =
      "#{@view.name}-bp-attribute-permit"   :  @permission.attribute-permission-checker
      "#{@view.name}-bp-doc-permit"         :  @permission.doc-permission-checker
      "#{@view.name}-bp-collection-permit"  :  @permission.collection-permission-checker
      "#{@view.name}-bp-action-is"          :  @view.current-action-checker
      "#{@view.name}-bp-path-for"           :  @view.get-path
      "#{@data-retriever-name}"             :  @view.data-retriever 

  create-renderers: !-> @renderers = []

  create-event-handlers: !-> @events-handlers = @form.register-event-handlers!
    


# ----------------------- Detail ---------------------------------
class List-template-adpater extends BP.Template-adapter
  ->
  super ...


class Detail-template-adpater extends BP.Template-adapter
  ->
  super ...

  create-helpers: !->
    super ...
    @helpers <<<
      "#{@view.name}-bp-pre-link"           : ~> @_enable-nav-link("previous") 
      "#{@view.name}-bp-next-link"          : ~> @_enable-nav-link("next") 
      "#{@view.name}-bp-add-typeahead"      : @add-typeahead-to-input-field

  create-renderers: !->
    super ...
    @renderers.push @ui.show-hide-references # 需要在selector里面写入当前view-name
    @renderers.push @ui.add-validation

  add-typeahead-to-input-field:  (attr, candidates)!~> # 模板中的ahead控件将调用它，以便render后，动态添加typeahead功能
    @post-render-methods.push @ui.get-typeahead-render do
      config-name: @view.name + attr #一个页面可能有多个表单，一个表单有多个typeahead的域
      input-name: attr
      candidates: candidates

  _enable-nav-link: (nav)->
    if doc-id = @view.get-state nav + '-id'
      @view.get-path action = nav, doc-id # 这里需要考虑组合view的情况，要得到整体的path，现在只是局部




/* ------------------------ Private Methods ------------------- */

