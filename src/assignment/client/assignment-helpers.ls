Template.assignments-list.helpers do
  assignments: ->
    Assignments.find!

Template.assignment.helpers do
  assignment: (id)->
    Assignments.find-one!
    # if id = Session.get 'currentAssignmentId'
    #   Assignments.find-one Session.get 'currentAssignmentId' # 记得离开这个页面要清除
    # else #这样就可以共用编辑和新建的页面
    #   {}
    # Assignments.find-one! 

Template.assignment.rendered = -> # TODO：注意：这个是非业务方法，可否自动化生成？
  form = null
  try
    form = ($ @find 'form').first!
    # console.log "form.context is: ", form.context
    form?.parsley('validate') if form.context # Meteor会在这里执行两次，第一次时Parsley还没有完成form初始化
  catch error
    console.log error