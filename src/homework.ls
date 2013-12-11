class @Homework-list extends BP.List-view
  create-data-manager: !-> @data-manager = new List-data-manager @

  add-links: (list)!->
    super ...
    assignments-list = BP.View.registry['assignments-list']
    @links.go-assignments-list = view: assignments-list, face: assignments-list.faces.list

class List-data-manager extends BP.List-data-manager
  publish: !->
    dm = @
    assignment-collection = BP.Collection.registry['Assignments']
    Meteor.publish dm.meteor-pub-name, ->
      homework-cursor = dm.collection.find!
      assignment-cursor = assignment-collection.find!
      [homework-cursor, assignment-cursor]

  meteor-template-retreiver: ->
    super ...
    assignment-collection = BP.Collection.registry['Assignments']
    @docs = @docs.fetch!
    @docs.map ->
      assignment = assignment-collection.findOne _id: it.assignment-id
      it.assignment = assignment if assignment
    @docs

    
 

class @Homework-detail extends BP.Detail-view
  create-data-manager: !-> @data-manager = new Detail-data-manager @


class Detail-data-manager extends BP.Detail-data-manager
  # TODO: 先从published collection里面查，没有再到session里面取
  publish: !->
    dm = @    
    assignment-collection = BP.Collection.registry['Assignments']
    Meteor.publish dm.meteor-pub-name, (id)->
      homework-cursor = dm.collection.find {_id: id}
      assignment-cursor = assignment-collection.find!
      [homework-cursor, assignment-cursor]


  subscribe: (params)!->
    self = @
    super ...
    Template['homework'].helpers 'assignment': ->
      assignment-collection = BP.Collection.registry['Assignments']
      if self.doc and not _.is-empty self.doc
        assignment-collection.findOne _id: self.doc.assignment-id
      else
        self.get-transferred-state 'assignment'

