registry = {}

module.exports =
  init: (namespace, doc-name)->
    registry[namespace] ||= {}
    registry[namespace][doc-name] ||= table:
      view-row-links: []
      view-row-multiple-links: []
      view-table-links: []
      view-removed-links: []    
      page-added-row-links: []
      page-added-row-multiple-links: []
      page-added-table-links: []
      page-added-removed-links: []    

  get-config: (namespace, doc-name)->
    registry[namespace][doc-name]

  add-item-link: (namespace, doc-name, link)->
    @_add-link namespace, doc-name, 'row-links', link

  add-item-links: (namespace, doc-name, link)->
    @_add-link namespace, doc-name, 'row-multiple-links', link

  add-list-link: (namespace, doc-name, link)->
    @_add-link namespace, doc-name, 'table-links', link

  remove-link: (namespace, doc-name, linkName)->
    @_add-link namespace, doc-name, 'removed-links', linkName

  _add-link: (namespace, doc-name, config-item-name, link)->
    config-item-name = if @is-page-added link then 'pageAdded' + config-item-name.camelize! else 'view' + config-item-name.camelize!
    registry[namespace][doc-name].table[config-item-name].push link

  is-page-added: (link)->
    !!link.pageName
