# class @Assignments-list extends BP.List-view
#   create-data-manager: !-> @data-manager = new Data-manager @

# class Data-manager extends BP.List-data-manager
#   ->
#     @cited-data = [{doc-name: 'homework', query: '{assignmentId: doc._id}'}]
#     super ...


