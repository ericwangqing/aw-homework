# assignment-state = new BP.State 'assignment'
# homework-state = new BP.State 'test'
# BP.Component.add-main-nav 'do-homework'
# Router.map ->
#   @route 'do-homework', do
#     path: 'do-homework/:_aid'
#     template: 'do-homework'
#     before: ->
#       assignment-state.set action: 'view', current-id: @params._aid
#       homework-state.set action: 'create'
#     wait-on: -> [
#       Meteor.subscribe 'Assignments'
#       Meteor.subscribe 'Tests'
#     ]

