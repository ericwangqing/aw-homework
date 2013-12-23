if Meteor? then _ = @_ else _ = require 'underscore' # 为测试用例在Meteor环境外加载underscore

class Permission
  @get-instance = ->
    @instance = new @ if not @instance 
    @instance

  ->
    #形如：homework: [], assignment: []
    @rules = {}

  add-rule: (unparsed-rule)->
    Rule = if Meteor? then BP.Rule else require './rule'
    new-rule = new Rule unparsed-rule
    @rules[new-rule.doc-name] ||= []
    @rules[new-rule.doc-name].push new-rule

  # Template和Router调用，检查当前用户是否有权限进行相应操作
  # view | go-create | go-update | delete 
  check-list-action-permission: (doc-name, doc, action)~>
    @check-action-permission doc-name, doc, action, 'list'

  # Template和Router调用，检查当前用户是否有权限进行相应操作
  # view | create | update | delete 
  check-detail-action-permission: (doc-name, doc, action)~> # 注意：这里为了便于helpers里通过同check-list-action-permission一样
    @check-action-permission doc-name, doc, action, 'detail'

  check-action-permission: (doc-name, doc, action, view-type)->
    current-active-rules = @get-active-rules-on-action doc-name, doc, action, view-type
    if current-active-rules.length > 0
      combined-rule = @combined-rules current-active-rules 
      combined-rule.check action, view-type
    else
      true

  get-active-rules-on-action: (doc-name, doc, action, view-type)->
    return [] if not @rules[doc-name]
    [rule for rule in @rules[doc-name] when rule.is-apply-on-current-user! and rule.is-apply-on-current-action view-type, doc, action]

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
      combined-rule.check-attribute-editable attr-name
    else
      true

  get-active-rules-on-attribute-action: (doc-name, doc, attr-name, action)->
    return [] if not @rules[doc-name]
    [rule for rule in @rules[doc-name] when rule.is-apply-on-current-user! and rule.is-apply-on-current-attribute-and-action doc, attr-name, action]

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
    # result

  get-active-rules-for-publish-data: (current-user-id, doc-name)->
    return [] if not @rules[doc-name]
    [rule for rule in @rules[doc-name] when rule.is-apply-on-current-user current-user-id]

  get-query-from-rule: (origin-query, rule)->
    $and: [origin-query, (rule.query or {})]

  get-projection-from-rule: (rule)->
    projection = fields: {}
    for attr-name, constrain of rule.attributes
      projection.fields[attr-name] = 0 if constrain.view is false
    projection


@BP ||= {}
if module? then module.exports = Permission else @BP.Permission = Permission # 让Jade和Meteor都可以使用

