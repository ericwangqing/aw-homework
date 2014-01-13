@BP ||= {}

if Meteor? then _ = @_ else _ = require 'underscore' # 为测试用例在Meteor环境外加载underscore
Rule = if Meteor? then BP.Rule else require './_rule'   

class Rule-parser
  parse-users-and-roles: (rule)->
    @rule = rule
    return @rule.applied-on-users = Rule.ALL_USERS if not @rule.rule-content.users # 未指定user时，应用到全体users
    tokens = @rule.rule-content.users.split /\s+/
    @rule.applied-on-users = @compact-set-considering-not-modifier tokens.filter ~> not (@is-role-token it)
    @rule.applied-on-roles = @compact-set-considering-not-modifier tokens.filter @is-role-token .map @cut-off-role-prefix


  is-role-token: (token)->
    (token.index-of 'R-') == 0 or (token.index-of 'r-') == 0 or (token.index-of 'NOT-R-') == 0 or (token.index-of 'not-r-') == 0 

  cut-off-role-prefix: (token)~>
    if @has-not-prefix token
      token = 'NOT-' + token.substr 6, token.length 
    else
      token.substr 2, token.length

  has-not-prefix: (token)->
    (token.index-of 'NOT-') == 0 or (token.index-of 'not-') == 0 

  compact-set-considering-not-modifier: (items)->
    items-with-not-modifier = _.unique items.filter ~> @has-not-prefix it
    items-without-not-modifier = _.unique items.filter ~> not (@has-not-prefix it)
    return Rule.ALL if items-with-not-modifier.length > 1 # 例如：not-张三，not-李四，那么实际上任何情况都已经包含
    return items-without-not-modifier if items-with-not-modifier.length is 0
    not-item = items-with-not-modifier[0] - 'NOT-'
    if not-item in items-without-not-modifier then Rule.ALL else items-with-not-modifier[0]

class Data-rule-parser extends Rule-parser
  parse-rule: (@rule)->
    allows = {collection, item, attributes} = @gather-rule @rule.rule-content.allows
    denies = {collection, item, attributes} = @gather-rule @rule.rule-content.denies
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
    (tokens.filter -> (it.index-of prefix) == 0).map @cut-off-role-prefix

  extract-attributes-action: (tokens)->
    result = {}
    attribute-rules = @extract-action tokens, prefix = 'a-' 
    for attr-action in attribute-rules
      [attr, action] = attr-action.split '-'
      result[attr] ||= []
      result[attr].push action
    result

  parse-collection-rule: (allow, deny)!->
    @rule.collection = {}
    @add-allow-deny @rule.collection, allow, deny

  parse-item-rule: (allow, deny)!->
    @rule.item = {}
    @add-allow-deny @rule.item, allow, deny

  parse-attributes-rule: (allow, deny)!->
    @rule.attributes = {}
    attributes = (_.keys allow) ++ (_.keys deny)
    for attr in attributes
      # @attributes[attr] = _.clone @@default-rule.attribute
      @rule.attributes[attr] = {}
      @add-allow-deny @rule.attributes[attr], (allow[attr] or []), (deny[attr] or [])

  add-allow-deny: (sub-rule, allow, deny)!->
    [sub-rule[action] = true for action in allow]
    [sub-rule[action] = false for action in deny]
    # doc: 这里显然deny高于allow

class Page-rule-parser extends Rule-parser
  parse-rule: (@rule)->
    @rule.accessible = true if @rule.rule-content.allows?
    @rule.accessible = false if @rule.rule-content.denies?

if module? 
  module.exports = {Data-rule-parser, Page-rule-parser} 
else 
  @BP.Data-rule-parser = Data-rule-parser # 让Jade和Meteor都可以使用
  @BP.Page-rule-parser = Page-rule-parser # 让Jade和Meteor都可以使用