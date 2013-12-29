if Meteor? then _ = @_ else _ = require 'underscore' # 为测试用例在Meteor环境外加载underscore

class Rule-parser
  parse-users-and-roles: (rule)->
    @rule = rule
    return 'all' if not @rule.rule-content.users # 未指定user时，应用到全体users
    tokens = @rule.rule-content.users.split /\s+/
    @rule.applied-on-users = tokens.filter ~> not (@is-role-token it)
    @rule.applied-on-roles = tokens.filter @is-role-token .map @cut-off-prefix

  is-role-token: (token)->
    (token.index-of 'R-') == 0 or (token.index-of 'r-') == 0

  cut-off-prefix: (token)->
    token.substr 2, token.length

  parse-rule: (rule)->
    @rule = rule
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

@BP ||= {}
if module? then module.exports = Rule-parser else @BP.Rule-parser = Rule-parser # 让Jade和Meteor都可以使用

