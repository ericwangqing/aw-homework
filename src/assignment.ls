# class @Homework-detail-view extends BP.Detail-view
#   create-view-appearances: !->
#     super ...
#     update-by-assignment-id:    "/#{@name}/update-by-assignment-id/:assignment-id"
#     view-by-assignment-id:      "/#{@name}/view-by-assignment-id/:assignment-id"
#     reference-by-assignment-id: "/#{@name}/reference-by-assignment-id/:assignment-id"


# class @Agile-assignments-list-view extends BP.List-view
#   # get-path: (link-name, doc-or-doc-id)->
#   #   switch link-name
#   #     return 
#   #   return '#' if link-name in ['createHomework', 'updateHomework']
#   #   super ...


#   # publish-data: !->
#   #   view = @
#   #   Meteor.publish 'agile-assignments-with-homework-id', ->
#   #     homework-collection = BP.Collection.registry['Homeworks']

#   add-link: (detail)->

#  # publish-data: !->
#  #    debugger
#  #    view = @
#  #    Meteor.publish view.pub-sub.name, (id)-> 
#  #      eval "query = " + view.pub-sub.query
#  #      cursor = view.collection.find query

#  #    (referred-view, view-name) <-! _.each view.referred-views
#  #    Meteor.publish referred-view.pub-sub.name, (id)->
#  #      eval "query = " + referred-view.pub-sub.query
#  #      cursor = collection.find query
 
#  #  subscribe-data: (params)->
#  #    result = [] 
#  #    result.push super params
#  #    result.push Meteor.subscribe 

# # class @Agile-assignment-view extends BP.Detail-view
# #   