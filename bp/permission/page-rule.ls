@BP ||= {}

if Meteor? then _ = @_ else _ = require 'underscore' # 为测试用例在Meteor环境外加载underscore
Rule = if Meteor? then BP.Rule else require './_rule'

class Page-rule extends Rule

  prepare-parsing: ->
    Page = if Meteor? then BP.Page else require '../jade-script/page'
    {@namespace, @name} =  Page.parse-namespace-and-name-from-joint-page-name(_.keys @unparsed-rule .0)
    Page-rule-parser = if Meteor? then BP.Page-rule-parser else (require './rule-parser').Page-rule-parser
    @parser = new Page-rule-parser!

  is-apply-on-current-action: (doc, action)->
    action is 'go' and typeof @accessible isnt 'undefined'

  check: (doc, action)->
    switch action
    case 'go' then @accessible
    default true

if module? then module.exports = Page-rule else @BP.Page-rule = Page-rule # 让Jade和Meteor都可以使用
