if Meteor.is-client
  Handlebars.register-helper 'greeting', ->
    "AW-Homework "
  
  # Template.hello.my-test = ->
  #   Session.get 'my-test'

  # Template.hello.events 'click input': ->
  #   Session.set 'my-test', 100
    # alert "Great Work"

  Meteor.startup ->
    Session.set 'my-test', 11   
    
