class @Agile-assignment extends BP.List-view
  get-path: (link-name, doc-or-doc-id)->
    return '#' if link-name in ['createHomework', 'updateHomework']
    super ...

