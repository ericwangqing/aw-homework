@BP ||= {}
## Adpater 本身没有状态，因此可以被多个有相同template的view共用：
# 1）状态保存在view的state里，通过view操作
class @BP.Template-adapter
  @get = (view)->
    switch view.type
    case 'list'   then new List-template-adpater   view
    case 'detail' then new Detail-template-adpater view
    default throw new Error "type: '#type' is not supported yet."

  (@view)->
    @template = Template[view.template-name] # Meteor的template实际上是一个加载template html之后，编译成的函数。也就是说只编译一次，因此不会出现变化。
    @permission = BP.Permission.get-instance! # permission与view无关，因此可以共用。
    @data-retriever-name = if @view.type is 'list' then @view.names.list-data-retriever-name else @view.names.detail-data-retriever-name
    @create-helpers!
    @create-renderers!
    @create-event-handlers!
    @template.helpers @helpers
    @template.events @events-handlers 
    @template.rendered = !~> 
      [method.call @ for method in @renderers]

  create-helpers: !->
    self = @
    @helpers =
      "bs"                   :  @enable-bs!
      "bp-permit"            :  @view.is-permit
      "bp-attribute-permit"  :  @view.is-attribute-permit
      "bp-face-is"           :  @view.current-face-checker
      "bp-path-for"          :  ~> @view.get-path.apply @view, &
      'bp-links'             :  @enable-get-links-html-str-for-tooltipster! 

    @helpers <<< @view.data-manager.data-helpers
      # "#{@data-retriever-name}"       :  ~> @view.data-manager.meteor-template-main-data-helper.apply  @view.data-manager, &

  create-renderers: !-> 
    @renderers = [@enable-tooltips]
    @renderers ++= template-ui-post-render-methods if template-ui-post-render-methods = @view.add-to-template-rendered!

  create-event-handlers: !-> @events-handlers = @view.ui.register-event-handlers!

  ## 克服Meteor Handlebars不能使用中文key，形如{{中文}}会出错的问题。改用{{bs '中文'}}
  enable-bs: ->
    self = @
    (attr)-> 
      if value = @[attr]
        new Handlebars.Safe-string @[attr]
      else if not self.view.is-attribute-permit @, attr, 'view' # 注意！！还要考虑citedDoc的情况
        new Handlebars.Safe-string '<i class="bp-icon fa fa-eye-slash tooltip" title="没有权限查看"> </i>'
      else
        ''

  enable-tooltips: -> $ '.tooltip' .tooltipster interactive: true, theme: '.tooltipster-shadow'

  enable-get-links-html-str-for-tooltipster: -> 
    self = @
    (action, attr, name-attr)->
      name-attr = if typeof name-attr is 'string' then name-attr else 'title'
      result = ''
      if _.is-array docs = @[attr]
        for doc in docs
          if action is 'test'
            url = '#'
          else
            url = self.view.get-path action doc
          result += "<a href='#{url}'> #{doc[nameAttr]} </a>"
          console.log "************* result: ", doc
          console.log "************* name-attr: ", doc[nameAttr]
      new Handlebars.Safe-string result 
    
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
      "bp-add-multi-ahead"    : @enable-add-multi-ahead! 
      "bp-add-html-editor"    : @enable-html-editor-field! 

  create-renderers: !->
    super ...
    @renderers.push @view.ui.show-hide-references # 需要在selector里面写入当前view-name
    @renderers.push @view.ui.add-validation

  add-auto-insert-field: !(attr, expression)~>
    console.log "attr: #attr, expression: #expression"
    @view.data-manager.auto-insert-fields[attr] = attr: attr, expression: expression

  enable-nav-link: (nav)->
    ~>
      @view.get-path action = nav, if nav is 'previous' then @view.data-manager.previous-id else @view.data-manager.next-id # 这里需要考虑组合view的情况，要得到整体的path，现在只是局部

  enable-add-typeahead-to-input-field: -> 
    (attr, candidates)!~> # 模板中的ahead控件将调用它，以便render后，动态添加typeahead功能
      @renderers.push @view.ui.get-typeahead-render do
        config-name: @view.name + attr #一个页面可能有多个表单，一个表单有多个typeahead的域
        input-name: attr
        candidates: candidates

  enable-add-multi-ahead: ->
    (attr, config)!~> # 模板中的multi-ahead控件将调用它，以便render后，动态添加multi-ahead功能
      @renderers.push @view.ui.get-multi-ahead-render attr, config

  enable-html-editor-field: ->
    (editor-id, toolbar-id, placeholder)!~>
      Meteor.defer -> # 这里需要等parentNode就位，如果不defer，parentNode会undefined
        if $ "#" + editor-id .length
          new wysihtml5.Editor editor-id, 
            toolbar: toolbar-id
            parser-rules: wysihtml5-parser-rules
            stylesheets: '/lib/wysihtml5/wysihtml5.css'
            placeholder-text: placeholder




/* ------------------------ Private Methods ------------------- */

