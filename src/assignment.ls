class @Assignments-list extends BP.List-view
  create-data-manager: !-> @data-manager = new Data-manager @
  # create-faces: !->
  #   @faces-manager = new Faces-manager @
  #   @faces = @faces-manager.create-faces!

  add-links: (list)!->
    super ...
    homework-detail = BP.View.registry['homework']
    @links.create-homework = view: homework-detail, face: homework-detail.faces.create
    @links.update-homework = view: homework-detail, face: homework-detail.faces.update


  add-to-template-rendered: -> 
    self = @
    [!-> $ 'a.bp-go-create, a.bp-go-update' .click  (e)!->
      self.save-assignment-id-in-transferred-state e
    ]

  save-assignment-id-in-transferred-state: _.once (e)!->
    if @is-create-or-update-homework $ e.current-target
      alert "clicked"
      assignment-id = $ e.current-target .closest '.current-doc-id' .attr 'bp-doc-id'
      assignment-collection = BP.Collection.registry['Assignments']
      assignment = assignment-collection.find-one _id: assignment-id
      @data-manager.set-transferred-state 'assignment', assignment

  is-create-or-update-homework: (a)->
    a.attr 'href' .index-of 'homework' >= 0

class Data-manager extends BP.List-data-manager
  publish: !->
    dm = @    
    homework-collection = BP.Collection.registry['Homeworks']
    Meteor.publish dm.meteor-pub-name, (id)->
      assignment-cursor = dm.collection.find!
      homework-cursor = homework-collection.find!
      [assignment-cursor, homework-cursor]

  subscribe: !->
    super ...
    dm = @
    homework-collection = BP.Collection.registry['Homeworks']
    Template['assignments-list'].helpers 'homework': ->
      # console.log "in helper this is: ", @
      homework = homework-collection.find-one assignment-id: @_id

      # assignments = dm.collection.find!fetch!
      # for assignment in assignments
      #   assignment.homework = homework-collection.find assignment-id: assignment._id
      # assignments


# class Faces-manager extends BP.List-faces-manager

#   retrieve-as-main-view: ->
#     if @current-appearance-name.index-of 'assignment-id' >= 0
#       @collection.find-one assignment-id: @assignment-id
#     else
#       super ...

#   subscribe-data: (params)->
#     if params['assignment-id']
#       Meteor.subscribe @pub-sub.name, type = 'by-assignment-id', @assignment-id = params['assignment-id']
#     else
#       Meteor.subscribe @pub-sub.name, type = 'by-id', @doc-id = params['assignment-id']

#   publish-data: !->
#     view = @
#     Meteor.publish view.pub-sub.name, (type, id)->
#       cursor = view.colloection.find if type is 'by-assignment-id' then assignment-id: id else _id: id

# class @Assignments-list extends BP.List-view
#   publish-data: !->
#     view = @
#     Meteor.publish view.pub-sub.name, (type, id)->
#       cursor = view.colloection.find if type is 'by-assignment-id' then assignment-id: id else _id: id
  # get-path: (link-name, doc-or-doc-id)->
  #   switch link-name
  #     return 
  #   return '#' if link-name in ['createHomework', 'updateHomework']
  #   super ...


  # publish-data: !->
  #   view = @
  #   Meteor.publish 'agile-assignments-with-homework-id', ->
  #     homework-collection = BP.Collection.registry['Homeworks']

  # add-link: (detail)->
  #   super ...
  #   homework-detail = BP.View.registry['homework']
  #   create-homework: view: homework-detail, appearance: homework-detail.appearances.update-by-assignment-id

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