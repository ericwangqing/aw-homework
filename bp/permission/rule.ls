if Meteor? then _ = @_ else _ = require 'underscore' # 为测试用例在Meteor环境外加载underscore

'''
下面是rule、unparsed-rule的数据结构，其对用户权限的控制方式，详见：http://my.ss.sysu.edu.cn/wiki/pages/viewpage.action?pageId=251133954
'''
rule = 
  doc-name:
    applied-on-users: []
    collection: view: true, edit: true
    item: view: true, create: true, update: true, delete: true
    attribute:
      '要求': view: true, edit: true

unparsed-rule =
  assignment:
    users: '沈少伟 陈伟津 R-老师'
    allows: 'c-view, a-要求-edit'
    denies: 'i-create, a-截止时间-edit'

class Rule
  (@unparsed-rule)->
    return if not @unparsed-rule
    @doc-name = _.keys unparsed-rule .0
    @rule-content = @unparsed-rule[@doc-name]
    @query = unparsed-rule.query or {}

    Rule-parser = if Meteor? then BP.Rule-parser else require './rule-parser'
    @parser = new Rule-parser!
    @parser.parse-users-and-roles @
    @parser.parse-rule @

  is-apply-on-current-user: (current-user-id)->
    return false if Meteor.is-server and not current-user-id  # 未登录
    current-user = if current-user-id then Meteor.users.find-one current-user-id else Meteor.user! # Meteor的publish中不能用Meteor.user!，只能用查询。
    (current-user.profile.fullname in @applied-on-users) or @is-apply-on-current-user-by-role current-user

  is-apply-on-current-user-by-role: (current-user)->
    return false if not roles = current-user.profile.roles
    roles = roles.split /,\s*/ if typeof roles is 'string'
    for role in roles
      return true if role in @applied-on-roles
    false

  is-apply-on-current-action: (view-type, doc, action)->
    @[('is-apply-on-current-' + view-type + '-action').camelize(false)] doc, action

  # view | go-create | go-update | delete 
  is-apply-on-current-list-action: (doc, action)->
    switch action
    case 'view' then @collection.view?
    case 'go-create' then @collection.edit? or @item.create?
    case 'go-update' then @collection.edit? or (@item.update? and @satisfy-query doc)
    case 'delete' then @collection.edit? or (@item.delete? and @satisfy-query doc)
    default false

  # view | create | update | delete 
  is-apply-on-current-detail-action: (doc, action)->
    switch action
    case 'view' then @collection.view? or (@item.view? and @satisfy-query doc)
    case 'create' then @item.create?
    case 'update' then @item.update? and @satisfy-query doc
    case 'delete' then @item.delete? and @satisfy-query doc
    default true

  is-apply-on-current-attribute-and-action: (doc, attr-name, action)-> # doc: 目前attribute只支持update，
    if action is 'update'
      (@item.update? and @satisfy-query doc) or (@attributes[attr-name]? and (@attributes[attr-name].edit? or @attributes[attr-name].view?))
    else if action is 'view'
      (@item.view? and @satisfy-query doc) or (@attributes[attr-name]? and @attributes[attr-name].view?)


  satisfy-query: (doc)->
    collection = BP.Collection.get-by-doc-name @doc-name
    collection.find {$and: [@query, {_id: doc._id}]} .count! is 1

  check: (action, view-type)->
    @[('check-on-' + view-type + '-view').camelize(false)] action

  check-on-list-view: (action)->
    switch action
    case 'view' then @collection.view
    case 'go-create' 
      if @item.create? then  @item.create else @collection.edit
    case 'go-update' 
      if @item.update? then  @item.update else @collection.edit
    case 'delete'   
      if @item.delete? then  @item.delete else @collection.edit
    default true

  check-on-detail-view: (action)->
    switch action
    case 'view'
      if @item.view? then @item.view else @collection.view
    case 'create' then @item.create
    case 'update' then @item.update
    case 'delelte' then @item.delete
    default true

  check-attribute-editable: (attr-name)->
    rule = @attributes[attr-name]
    if rule? and  (rule.edit? or rule.view?) 
      if rule.edit is false or rule.view is false
        false
      else
        true  
    else 
      @item.update

  check-attribute-viewable: (attr-name)->
    rule = @attributes[attr-name]
    if rule? and rule.view? then rule.view else @item.view

@BP ||= {}
if module? then module.exports = Rule else @BP.Rule = Rule # 让Jade和Meteor都可以使用

