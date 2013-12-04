if Meteor.is-client
  homework = 'old homework'
  counter = 0
  previous-callee = null
  Template.once.helpers 'homework': ->
    counter++
    console.log "counter: #counter"
    console.log "previous-callee: ", previous-callee
    console.log "arguments.callee: ", arguments.callee
    console.log "are they same? ", previous-callee is arguments.callee
    previous-callee := arguments.callee

    homework

  Handlebars.registerHelper 'change-view', !->
    homework := 'new homework'
    Template.once.helpers 'homework': ->
      counter++
      console.log "counter: #counter"
      console.log "previous-callee: ", previous-callee
      console.log "arguments.callee: ", arguments.callee
      console.log "are they same? ", previous-callee is arguments.callee
      previous-callee := arguments.callee

      # a = {}
      # [a['a'+i] = i for i in [1 to 4]]
      # (name, value) <-! _.each a
      # console.log "name: #name, value: #value"

      homework + homework

# class BP._Template # helpers, renderers, event-handlers, component
#   @registry = {}
#   @get = (name)-> @registry[name] ||= new BP._Template!# Factory Method

# class @OOO extends BP._Template

