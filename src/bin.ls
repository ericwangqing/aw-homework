if Meteor.is-client
  Template.hello.greeting = ->
    "Welcome to AW-Homework"
  
  Template.hello.my-test = ->
    Session.get 'my-test'

  Template.hello.events 'click input': ->
    Session.set 'my-test', 100
    # alert "Great Work"

  Meteor.startup ->
    Session.set 'my-test', 11
    # $ '.form' .my {
    #   data: x: 435
    #   ui:
    #     '#field':
    #       bind: 'x'
    #       check: /^[1-9]\d{1,2}$/
    #       error: "中文的提示哦"
    # }

