if module?
  _ = require 'underscore'

class Permission
  @get-instance = ->
    @instance = new @ if not @instance 
    @instance

  ->
    #形如：homework: [], assignment: []
    @rules = {}

  add-rule: (unparsed-rule)->
    new-rule = new Rule unparsed-rule
    @rules[new-rule.doc-name] ++= rule


  attribute-permission-checker: (doc, attr, action)~> # Template调用，检查当前用户是否有权限进行相应操作
    #TODO：接入Bp-Permission模块，提供权限功能
    # bp-Permssion.can-user-act-on Meteor.userId, @doc-name, attr, action
    # 下面是暂时的fake
    auto-generated-fields = <[createdAtTime lastModifiedAt _id state]>
    attr not in auto-generated-fields

  doc-permission-checker: (doc, action)~>
    #TODO：接入Bp-Permission模块，提供权限功能
    # bp-Permssion.can-user-act-on Meteor.userId, @doc-name, action
    # 下面是暂时的fake
    true

  collection-permission-checker: (action, collection-name)~>
    #TODO：接入Bp-Permission模块，提供权限功能
    # bp-Permssion.can-user-act-on Meteor.userId, @doc-name, doc-id, action
    # 下面是暂时的fake
    true

'''
下面是rule、unparsed-rule的数据结构，其对用户权限的控制方式，详见：http://my.ss.sysu.edu.cn/wiki/pages/viewpage.action?pageId=251133954
'''
rule = 
  doc-name:
    apply-on-users: []
    collection:
      view: true 
      edit: true
    item:
      # applying-condition: '{query: query}'
      view: true
      create: true
      update: true
      delete: true
    attribute:
      '要求':
        view: true 
        edit: true

unparsed-rule =
  assignment:
    users: '沈少伟 陈伟津 R-老师'
    allows: 'c-view, a-要求-edit'
    denies: 'i-create, a-截止时间-edit'


class Rule
  @default-rule =
    collection: view: true, edit: true
    item: view: true, create: true, update: true, delete: true
    attribute: view: true, edit: true

  (@unparsed-rule)->
    return if not @unparsed-rule
    @doc-name = _.keys unparsed-rule .0
    @rule-content = @unparsed-rule[@doc-name]
    @query = unparsed-rule.query or {}
    @parse-users-and-roles!
    @parse-rule!

  parse-users-and-roles: ->
    return 'all' if not @rule-content.users # 未指定user时，应用到全体users
    tokens = @rule-content.users.split /\s+/
    @apply-on-users = tokens.filter ~> not (@is-role-token it)
    @apply-on-roles = tokens.filter @is-role-token .map @cut-off-prefix

  is-role-token: (token)->
    (token.index-of 'R-') == 0 or (token.index-of 'r-') == 0

  cut-off-prefix: (token)->
    token.substr 2, token.length

  parse-rule: ->
    allows = {collection, item, attributes} = @gather-rule @rule-content.allows
    denies = {collection, item, attributes} = @gather-rule @rule-content.denies
    @parse-collection-rule allows.collection, denies.collection
    @parse-item-rule allows.item, denies.item
    @parse-attributes-rule allows.attributes, denies.attributes

  gather-rule: (allows-or-denies)->
    tokens = allows-or-denies.split /,\s*/
    result =
      collection: @extract-action tokens, prefix = 'c-'
      item: @extract-action tokens, prefix = 'i-'
      attributes: @extract-attributes-action tokens

  extract-action: (tokens, prefix)->
    (tokens.filter -> (it.index-of prefix) == 0).map @cut-off-prefix

  extract-attributes-action: (tokens)->
    result = {}
    attribute-rules = @extract-action tokens, prefix = 'a-'
    for attr-action in attribute-rules
      [attr, action] = attr-action.split '-'
      result[attr] ||= []
      result[attr].push action
    result

  parse-collection-rule: (allow, deny)!->
    @collection = _.clone @@default-rule.collection
    @add-allow-deny @collection, allow, deny

  parse-item-rule: (allow, deny)!->
    @item = _.clone @@default-rule.item
    @add-allow-deny @item, allow, deny

  parse-attributes-rule: (allow, deny)!->
    @attributes = {}
    attributes = (_.keys allow) ++ (_.keys deny)
    for attr in attributes
      @attributes[attr] = _.clone @@default-rule.attribute
      @add-allow-deny @attributes[attr], (allow[attr] or []), (deny[attr] or [])

  add-allow-deny: (sub-rule, allow, deny)!->
    [sub-rule[action] = true for action in allow when action in _.keys sub-rule]
    [sub-rule[action] = false for action in deny when action in _.keys sub-rule]
    # doc: 这里显然deny高于allow

@BP ||= {}
if module? then module.exports = {Permission, Rule} else @BP.Permission = Permission # 让Jade和Meteor都可以使用

