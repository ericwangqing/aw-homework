if Meteor? then _ = @_ else _ = require 'underscore' # 为测试用例在Meteor环境外加载underscore

class Permission
  @get-instance = ->
    @instance = new @ if not @instance 
    @instance

  ->
    #形如：homework: [], assignment: []
    @rules = {}

  add-rule: (unparsed-rule)->
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
      winner-rule = @find-winner-rule current-active-rules 
      winner-rule.check action, view-type
    else
      true

  get-active-rules-on-action: (doc-name, doc, action, view-type)->
    return [] if not @rules[doc-name]
    [rule for rule in @rules[doc-name] when rule.is-apply-on-current-user! and rule.is-apply-on-current-action view-type, doc, action]

  find-winner-rule: (rules)->
    # TODO: 设计实现类似CSS selector的机制。
    [..., last] = rules
    last

  # Template调用，检查当前用户是否有权限进行相应操作
  # update 
  check-attribute-action-permission: (doc-name, doc, attr-name, action)~> 
    current-active-rules = @get-active-rules-on-attribute-action doc-name, doc, attr-name, action
    if current-active-rules.length > 0
      winner-rule = @find-winner-rule current-active-rules 
      winner-rule.check-attribute-editable attr-name
    else
      true

  get-active-rules-on-attribute-action: (doc-name, doc, attr-name, action)->
    return [] if not @rules[doc-name]
    [rule for rule in @rules[doc-name] when rule.is-apply-on-current-user! and rule.is-apply-on-current-attribute-and-action doc, attr-name, action]

  add-permission-constrain-on-query: (origin-query)->
    result-query = origin-query


'''
下面是rule、unparsed-rule的数据结构，其对用户权限的控制方式，详见：http://my.ss.sysu.edu.cn/wiki/pages/viewpage.action?pageId=251133954
'''
rule = 
  doc-name:
    applied-on-users: []
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
  (@unparsed-rule)->
    return if not @unparsed-rule
    @doc-name = _.keys unparsed-rule .0
    @rule-content = @unparsed-rule[@doc-name]
    @query = unparsed-rule.query or {}
    @parse-users-and-roles!
    @parse-rule!

  is-apply-on-current-user: ->
    (Meteor.user!.profile.fullname in @applied-on-users) or @is-apply-on-current-user-by-role!

  is-apply-on-current-user-by-role: ->
    return false if not Meteor.user!.profile.roles
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
    throw new Error "BP only support 'update' action permission checker on attribute, and current action is: #{action}" if action isnt 'update'
    (@item.update? and @satisfy-query doc) or (@attributes[attr-name]? and @attributes[attr-name].edit?)


  satisfy-query: (doc)->
    # TODO: 检查doc是否符合rule的query
    true

  check: (action, view-type)->
    @[('check-on-' + view-type + '-view').camelize(false)] action

  # view | go-create | go-update | delete 
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

  # view | create | update | delete 
  check-on-detail-view: (action)->
    switch action
    case 'view'
      if @item.view? then @item.view else @collection.view
    case 'create' then @item.create
    case 'update' then @item.update
    case 'delelte' then @item.delete
    default true

  check-attribute-editable: (attr-name)->
    if @attributes[attr-name]? and  @attributes[attr-name].edit? then @attributes[attr-name].edit else @item.update


  parse-users-and-roles: ->
    return 'all' if not @rule-content.users # 未指定user时，应用到全体users
    tokens = @rule-content.users.split /\s+/
    @applied-on-users = tokens.filter ~> not (@is-role-token it)
    @applied-on-roles = tokens.filter @is-role-token .map @cut-off-prefix

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
    allows-or-denies ||= ''
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
    # @collection = _.clone @@default-rule.collection
    @collection = {}
    @add-allow-deny @collection, allow, deny

  parse-item-rule: (allow, deny)!->
    # @item = _.clone @@default-rule.item
    @item = {}
    @add-allow-deny @item, allow, deny

  parse-attributes-rule: (allow, deny)!->
    @attributes = {}
    attributes = (_.keys allow) ++ (_.keys deny)
    for attr in attributes
      # @attributes[attr] = _.clone @@default-rule.attribute
      @attributes[attr] = {}
      @add-allow-deny @attributes[attr], (allow[attr] or []), (deny[attr] or [])

  add-allow-deny: (sub-rule, allow, deny)!->
    [sub-rule[action] = true for action in allow]
    [sub-rule[action] = false for action in deny]
    # doc: 这里显然deny高于allow

@BP ||= {}
if module? then module.exports = {Permission, Rule} else @BP.Permission = Permission # 让Jade和Meteor都可以使用

