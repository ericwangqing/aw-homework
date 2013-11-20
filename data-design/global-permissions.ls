# 全局权限，优先级低于process权限
# 采用和Meteor一样的权限逻辑，Deny高于Allow
# 默认Admin权限全开，User有所有数据的view权限
global-permissions =
  * description: 'Assignment数据在process外不可用'
    collections: 
      * name: 'assignments'
        action: 'all'
        deny: -> !@process
      ...

  * description: '学生只能看到自己有关的作业和作业布置'
    collections:
      * name: 'assignments'
        action: 'all'
        deny: -> Meteor.user-id not in @for-students
      * name: 'homeworks'
        action: 'all'
        deny: -> Meteor.user-id isnt @student
