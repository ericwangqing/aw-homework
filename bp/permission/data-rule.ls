@BP ||= {}

if Meteor? then _ = @_ else _ = require 'underscore' # 为测试用例在Meteor环境外加载underscore
Rule = if Meteor? then BP.Rule else require './_rule'

class Data-rule extends Rule
  prepare-parsing: ->
    @doc-name = _.keys @unparsed-rule .0
    Data-rule-parser = if Meteor? then BP.Data-rule-parser else (require './rule-parser').Data-rule-parser
    @parser = new Data-rule-parser!

  is-apply-on-current-action: (view-type, doc, action)->
    @[('is-apply-on-current-' + view-type + '-action').camelize(false)] doc, action

  # view | go-create | go-update | delete 
  is-apply-on-current-list-action: (doc, action)->
    switch action
    case 'view' then @collection.view? or @item.view?
    case 'go-create' then @collection.edit? or @item.create?
    case 'go-update' then @collection.edit? or (@item.update? and @satisfy-query doc)
    case 'delete' then @collection.edit? or (@item.delete? and @satisfy-query doc)
    default false

  # view | create | update | delete 
  is-apply-on-current-detail-action: (doc, action)->
    switch action
    case 'view' then @collection.view? or (@item.view? and @satisfy-query doc)
    case 'create' then @collection.edit? or @item.create?
    case 'update' then @collection.edit? or (@item.update? and @satisfy-query doc)
    case 'delete' then @collection.edit? or (@item.delete? and @satisfy-query doc)
    default false

  is-apply-on-current-attribute-and-action: (doc, attr-name, action)-> # doc: 目前attribute只支持update，
    if action is 'update'
      (@item.update? and @satisfy-query doc) or (@attributes[attr-name]? and (@attributes[attr-name].edit? or @attributes[attr-name].view?))
    else if action is 'view'
      (@item.view? and @satisfy-query doc) or (@attributes[attr-name]? and @attributes[attr-name].view?)


  satisfy-query: (doc)->
    return true if !!doc
    collection = BP.Collection.get-by-doc-name @doc-name
    collection.find {$and: [@query, {_id: doc._id}]} .count! is 1

  check: (action, view-type, doc, data-manager)->
    condition = @[('check-on-' + view-type + '-view').camelize(false)] action, data-manager
    @evaluate condition, doc, data-manager

  check-on-list-view: (action)->
    switch action
    case 'view' 
      if @item.view? then @item.view else @collection.view
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
    case 'create' 
      if @item.create? then  @item.create else @collection.edit
    case 'update' 
      if @item.update? then  @item.update else @collection.edit
    case 'delelte'
      if @item.delete? then  @item.delete else @collection.edit
    default true

  check-attribute-editable: (attr-name, doc, data-manager)->
    rule = @attributes[attr-name]
    if rule? and  (rule.edit? or rule.view?) 
      if rule.edit is false or rule.view is false
        false
      else
        true  
    else 
      @evaluate @item.update, doc, data-manager

  check-attribute-viewable: (attr-name, doc, data-manager)->
    rule = @attributes[attr-name]
    condition = if rule? and rule.view? then rule.view else @item.view
    @evaluate condition, doc, data-manager

  evaluate: (item, doc, data-manager)->
    # if condition not in ['true', 'false', '!true', '!false'] then true else
    # doc = data-manager.doc
    # eval "var result = #item"
    result = item
    eval "satisfied = #{@condition}"
    if satisfied then result else !result
    # try
    #   eval "satisfied = #{@condition}"
    # catch
    #   satisfied = if result is true then false else true # true时是allow，flase时时deny。对于allow只有完全通过condition的才allow，异常不allow。对于deny只要不违反condition就deny，异常也deny。
    # finally
    #   if satisfied then result else !result

if module? then module.exports = Data-rule else @BP.Data-rule = Data-rule # 让Jade和Meteor都可以使用

