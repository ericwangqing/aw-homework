if Meteor? then _ = @_ else _ = require 'underscore' # 为测试用例在Meteor环境外加载underscore

'''
下面是rule、unparsed-rule的数据结构，其对用户权限的控制方式，详见：http://my.ss.sysu.edu.cn/wiki/pages/viewpage.action?pageId=251133954
'''
rule = 
  doc-name: 'assignment'
  query: '{$gt: {age: 10}}'
  applied-on-users: []
  collection: view: true, edit: true
  item: view: true, create: true, update: true, delete: true
  attributes:
    '要求': view: true, edit: true

unparsed-rule =
  assignment:
    query: '{$gt: {age: 10}}'
    users: '沈少伟 陈伟津 R-老师'
    allows: 'c-view, a-要求-edit'
    denies: 'i-create, a-截止时间-edit'

## Abstract Factory
class Rule 
  @ALL_USERS = @ALL_ROLES = @ALL = '__ALL__'
  @create-data-rule = (unparsed-rule)-> 
    Data-rule = if Meteor? then BP.Data-rule else require './data-rule'
    new Data-rule unparsed-rule

  @create-page-rule = (unparsed-rule)-> 
    Page-rule = if Meteor? then BP.Page-rule else require './page-rule'
    new Page-rule unparsed-rule

  (@unparsed-rule)->
    return if not @unparsed-rule
    @rule-content = _.values @unparsed-rule .0
    @query = @unparsed-rule.query or {} # TODO: query功能尚未实现
    @prepare-parsing!
    @parser.parse-users-and-roles @
    @parser.parse-rule @

  is-apply-on-current-user: (current-user-id)->
    return false if Meteor.is-server and not current-user-id  # 未登录
    return true if @applied-on-users is @@ALL_USERS
    current-user = if current-user-id then Meteor.users.find-one current-user-id else Meteor.user! # Meteor的publish中不能用Meteor.user!，只能用查询。
    if typeof @applied-on-users is 'string'
      not-user = @applied-on-users - 'NOT-'
      return not (current-user.profile.fullname is not-user)
    else
      (current-user.profile.fullname in @applied-on-users) or @is-apply-on-current-user-by-role current-user

  is-apply-on-current-user-by-role: (current-user)->
    return true if @applied-on-roles is @@ALL_ROLES
    return false if not roles = current-user.profile.roles
    roles = roles.split /,\s*/ if typeof roles is 'string'

    if typeof @applied-on-roles is 'string'
      not-role = @applied-on-roles - 'NOT-'
      return not (not-role in roles)
    else
      for role in roles
        return true if role in @applied-on-roles
      false

@BP ||= {}
if module? then module.exports = Rule else @BP.Rule = Rule # 让Jade和Meteor都可以使用

