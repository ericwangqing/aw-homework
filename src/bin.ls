if Meteor.is-client
  Template.hello.greeting = ->
    "Welcome to AW-Homework"

  Template.hello.events 'click input': ->
    alert "Great Work"


