# Naming service is available here!
class Path

class Appearance

class Collection
  @registry
  @get

class Template # helpers, renderers, event-handlers, component
  @registry = {}
  @get = -> # Factory Method
  (@doc-name, @type, @views)->
    # @collection = BP.Collection.get 'doc-name'

class Component # template, views
  @registry = {}
  @get = -> # Factory Method

class View # form-helper/table-helper, data-retriever, state
  @registry = {}
  @get = -> # Factory Method
  (is-composed)->

class Appearance # path-patterns(route), permission-checkers

class List-Template

  views = [list-veiw-a, list-view-b, ref-list-view-c]

class List-View
  (view-name)->
    @state = new BP.State view-name # Router 根据pattern写入state
    appearances = 
      * name: 'list', path-pattern: "/#@view-name/list"
      * name: 'view', path-pattern: "/#@view-name/view", can-change-data: false
      * name: 'reference', path-pattern: "/#@view-name/reference", can-nav: false
    actions: 
      * name: 'go-create', is-data-changed: false, link-to: {view: detail, appearance: 'create'}
        name: 'delete', is-data-changed: true, link-to: {view: @, appearance: 'list'}
        
