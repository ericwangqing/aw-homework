@BP ||= {}

if Meteor? then _ = @_ else _ = require 'underscore' # 为测试用例在Meteor环境外加载underscore

class Permission
  @get-instance = ->
    @instance = new @ if not @instance 
    @instance

  ->
    @page-rules = {}
    #形如：homework: [], assignment: []
    @data-rules = {}

  add-data-rules: (unparsed-rules)!->
    [@add-data-rule {"#doc-name": rule} for doc-name, rule of unparsed-rules]

  add-data-rule: (unparsed-rule)!->
    Rule = if Meteor? then BP.Rule else require './_rule'
    new-rule = Rule.create-data-rule unparsed-rule
    @data-rules[new-rule.doc-name] ||= []
    @data-rules[new-rule.doc-name].push new-rule

  add-page-rules: (unparsed-rules)!->
    [@add-page-rule {"#joint-page-name": rule} for joint-page-name, rule of unparsed-rules]

  add-page-rule: (unparsed-rule)!->
    joint-page-name = _.keys unparsed-rule .0
    Rule = if Meteor? then BP.Rule else require './_rule'
    new-rule = Rule.create-page-rule unparsed-rule
    @page-rules[joint-page-name] ||= []
    @page-rules[joint-page-name].push new-rule

  check-page-action-permission: (namespace, page-name, doc, action)->
    return true if BP.MODE is 'DEVELOPMENT' 
    current-active-rules = @get-active-page-rules namespace, page-name, doc, action
    if current-active-rules.length > 0
      combined-rule = @combined-rules current-active-rules 
      combined-rule.check doc, action
    else
      true

  get-active-page-rules: (namespace, page-name, doc, action)->
    Page = if Meteor? then BP.Page else require '../jade-scripts/page'
    joint-page-name = BP.Page.get-joint-page-name namespace, page-name
    return [] if not @page-rules[joint-page-name]
    [rule for rule in @page-rules[joint-page-name] when rule.is-apply-on-current-user! and rule.is-apply-on-current-action doc, action]

  # Template和Router调用，检查当前用户是否有权限进行相应操作
  # view | go-create | go-update | delete 
  check-list-action-permission: (doc-name, doc, action)~>
    BP.MODE is 'DEVELOPMENT' or @check-action-permission doc-name, doc, action, 'list'

  # Template和Router调用，检查当前用户是否有权限进行相应操作
  # view | create | update | delete 
  check-detail-action-permission: (doc-name, doc, action)~> # 注意：这里为了便于helpers里通过同check-list-action-permission一样
    BP.MODE is 'DEVELOPMENT' or @check-action-permission doc-name, doc, action, 'detail'

  check-action-permission: (doc-name, doc, action, view-type)->
    return true if BP.MODE is 'DEVELOPMENT' 
    current-active-rules = @get-active-rules-on-action doc-name, doc, action, view-type
    if current-active-rules.length > 0
      combined-rule = @combined-rules current-active-rules 
      combined-rule.check action, view-type
    else
      true

  get-active-rules-on-action: (doc-name, doc, action, view-type)->
    return [] if not @data-rules[doc-name]
    [rule for rule in @data-rules[doc-name] when rule.is-apply-on-current-user! and rule.is-apply-on-current-action view-type, doc, action]

  combined-rules: (rules)->
    # TODO: 设计实现类似CSS selector的机制。
    [..., last] = rules
    last

  # Template调用，检查当前用户是否有权限进行相应操作
  # update 
  check-attribute-action-permission: (doc-name, doc, attr-name, action)~> 
    current-active-rules = @get-active-rules-on-attribute-action doc-name, doc, attr-name, action
    if current-active-rules.length > 0
      combined-rule = @combined-rules current-active-rules 
      combined-rule.check-attribute-editable attr-name if action is 'update'
      combined-rule.check-attribute-viewable attr-name if action is 'view'
    else
      true

  get-active-rules-on-attribute-action: (doc-name, doc, attr-name, action)->
    return [] if not @data-rules[doc-name]
    [rule for rule in @data-rules[doc-name] when rule.is-apply-on-current-user! and rule.is-apply-on-current-attribute-and-action doc, attr-name, action]

  add-constrain-on-query: (current-user-id, doc-name, origin-query)->
    # debugger
    current-active-rules = @get-active-rules-for-publish-data current-user-id, doc-name
    if current-active-rules.length > 0
      combined-rule = @combined-rules current-active-rules
      query = @get-query-from-rule origin-query, combined-rule
      projection = @get-projection-from-rule combined-rule
    else
      query = origin-query
      projection = {}

    result = {query, projection}
    # console.log "********************** constrained-query is: ", result
    result

  get-active-rules-for-publish-data: (current-user-id, doc-name)->
    return [] if not @data-rules[doc-name]
    [rule for rule in @data-rules[doc-name] when rule.is-apply-on-current-user current-user-id]

  get-query-from-rule: (origin-query, rule)->
    $and: [origin-query, (rule.query or {})]

  get-projection-from-rule: (rule)->
    projection = fields: {}
    for attr-name, constrain of rule.attributes
      projection.fields[attr-name] = 0 if constrain.view is false
    projection


if module? then module.exports = Permission else @BP.Permission = Permission # 让Jade和Meteor都可以使用

