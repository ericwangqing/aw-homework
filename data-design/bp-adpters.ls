# BPH Meteor Handlebars Block helper
'''
usage: {{#BPH data}} data {{/BPH}}
'''
Handlebars.register-helper 'BPH', -> 
  # 检查数据权限（与下面BPP合作，这里主要enforce disable）
  # 添加操作按钮


# BPP Meteor Publish Function Decorator
'''
usage: Meteor.publish 'homeworks', BPP origin-publish-function = ->
  # 正常的数据查询
'''
BPP = (origin-publish-function)->
  # 正常查询数据
  # 对查询回来的数据，根据当前的流程、用户权限进行过滤
  # 删除掉用户没有权限的数据项，和数据域（Projection）
  # 标识用户不能编辑的数据域
  decorated-publish-function

# BPM Meteor Method Decorator
'''
usage: Meteor.methods "update homeworks": BPM origin-method = (homeworks)->
  # 正常的method调用
'''
BPM = (origin-method)->
  # 正常方法调用
  # 如果必要调用工作流引擎，更新工作流
  # 更新process和task数据

# BPR Meteor iron-router
'''
usage: （待设计）正确将工作流中的数据导航到BP enable的模板上，并传递相应的pid
'''

bp-state = # 当前视图可见数据集、数据项及用户对其所能进行的操作
  # BP视图的位面，data | process
  view-type: 'data' # 表明当前位面，当前位面的数据用以供BPH定制页面，此外位面的数据仅仅视其存在性，给出链接
  data:
    * collection-name: 'homeworks'
      id: null #当action列表数据（list）时，或者创建数据项（create）时，此处为null
      action: 'create' # create | edit | list | look
    * collection-name: 'assignments'
      id: 'aid1'
      action: 'look'
  process: # 
    task-name: 'submit-homework' # 此处待进行task设计之后再进一步明确

    # * collection-name: 'homeworks'
    #   id: null #当action列表数据（list）时，或者创建数据项（create）时，此处为null
    #   action: 'create' # create | edit | list | look
    # * collection-name: 'assignments'
    #   id: 'aid1'
      action: 'look'
