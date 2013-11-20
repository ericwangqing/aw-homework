Template.assignments-list.helpers do
  assignments: ->
    Assignments.find!

Template.assignment.helpers do
  assignment: ->
    Assignments.find!fetch![0] 