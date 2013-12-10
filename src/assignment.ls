class @Homework-detail extends BP.Detail-view
  create-view-appearances: !->
    super ...
    update-by-assignment-id:    "/#{@name}/update-by-assignment-id/:assignment-id"
    view-by-assignment-id:      "/#{@name}/view-by-assignment-id/:assignment-id"
    reference-by-assignment-id: "/#{@name}/reference-by-assignment-id/:assignment-id"

  get-appearance-path: (appearance, doc)->
    return null if not doc
    if appearance.index-of ':assignment-id' >= 0
      appearance.replace ':assignment-id', doc.assignment-id
    else
      super ...

  retrieve-as-main-view: ->
    if @current-appearance-name.index-of 'assignment-id' >= 0
      @collection.find-one assignment-id: @assignment-id
    else
      super ...

  subscribe-data: (params)->
    if params['assignment-id']
      Meteor.subscribe @pub-sub.name, type = 'by-assignment-id', @assignment-id = params['assignment-id']
    else
      Meteor.subscribe @pub-sub.name, type = 'by-id', @doc-id = params['assignment-id']

  publish-data: !->
    view = @
    Meteor.publish view.pub-sub.name, (type, id)->
      cursor = view.colloection.find if type is 'by-assignment-id' then assignment-id: id else _id: id

class @Assignments-list extends BP.List-view
  # get-path: (link-name, doc-or-doc-id)->
  #   switch link-name
  #     return 
  #   return '#' if link-name in ['createHomework', 'updateHomework']
  #   super ...


  # publish-data: !->
  #   view = @
  #   Meteor.publish 'agile-assignments-with-homework-id', ->
  #     homework-collection = BP.Collection.registry['Homeworks']

  add-link: (detail)->
    super ...
    homework-detail = BP.View.registry['homework']
    create-homework: view: homework-detail, appearance: homework-detail.appearances.update-by-assignment-id

 # publish-data: !->
 #    debugger
 #    view = @
 #    Meteor.publish view.pub-sub.name, (id)-> 
 #      eval "query = " + view.pub-sub.query
 #      cursor = view.collection.find query

 #    (referred-view, view-name) <-! _.each view.referred-views
 #    Meteor.publish referred-view.pub-sub.name, (id)->
 #      eval "query = " + referred-view.pub-sub.query
 #      cursor = collection.find query
 
 #  subscribe-data: (params)->
 #    result = [] 
 #    result.push super params
 #    result.push Meteor.subscribe 

# class @Agile-assignment-view extends BP.Detail-view
#   