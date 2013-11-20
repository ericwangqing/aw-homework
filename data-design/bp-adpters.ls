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
