class BP.List-data-manager extends BP.Abstract-data-manager
  (view)->
    @meteor-pub-name = view.names.list-data-publish-name
    @query = {} # 默认值，可在view被（page）引用时，重新设定
    @main-data-helper-name = view.names.list-data-retriever-name
    super ...

  subscribe: (params)->
    Meteor.subscribe @meteor-pub-name

  store-data-in-state: !->
    eval "this.query = " + @query if typeof @query is 'string'
    @doc-ids = @collection.find @query .fetch! .map -> it._id # 性能：改进查询，或者用Meteor Method，改进性能。
    @set-transferred-state @view.doc-name + '-doc-ids', @doc-ids

  meteor-template-main-data-helper: ~> # doc: list视图时，将cited的data装配到docs里面，便于用Meteor的each进行遍历
    eval "this.query = " + @query if typeof @query is 'string' # TODO: 重构，
    @docs = @collection.find @query .fetch!
    @docs.map (doc)~>
      for {doc-name, query, is-multiple} in @cited-data
        collection = BP.Collection.get-by-doc-name doc-name
        eval "query = " + query if typeof query is 'string'
        if is-multiple
          doc[doc-name.pluralize!] = collection.find query .fetch!
        else
          doc[doc-name] = collection.findOne query 
      doc

