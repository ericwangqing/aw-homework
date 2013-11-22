Template.assignments-list.helpers do
  assignments: ->
    Assignments.find!

Template.assignment.helpers do
  assignment: ->
    Assignments.find!fetch![0] 

Template.assignment.rendered = -> # TODO：注意：这个是非业务方法，可否自动化生成？
  form = null
  try
    form = ($ @find 'form').first!
    # console.log "form.context is: ", form.context
    form?.parsley('validate') if form.context # Meteor会在这里执行两次，第一次时Parsley还没有完成form初始化
  catch error
    console.log error