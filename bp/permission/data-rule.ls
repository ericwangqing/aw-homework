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

if module? then module.exports = Data-rule else @BP.Data-rule = Data-rule # 让Jade和Meteor都可以使用

