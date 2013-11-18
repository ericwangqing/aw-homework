# !!! 重大改变：process仅仅定义对data的操作，在permission-def中来定义角色权限
# !!! 重大思考：充分利用JavaScript的动态性，在工程时 Sperate Concerns，在运行时，Wave Logic
A-process-def = #定义角色、权限
  workflow: 'wfid1'
  context: {assignment-id: null, current-task-data: null}
  tasks:
    * step: "Assign"
      is-first-step: true
      actors: ['Role:Teacher'] # 无前缀Role:的可以是用户id
      viewers: ['Role:Student'] # 能够在这个阶段浏览到data的用户
      # Actors默认对操作数据有全部权限，除非有规则deny
      # Viewers默认对数据只有view权限，但可以Allow新权限

      # template: 'assign' # 如果缺失，将根据对operation的data和action-type类型，自动使用默认的CRUD模板之一
      # template: ['assignmentCreate', 'homeworkList'] # 将自动组合
      # templates: ['assign1', 'homeworkList'] # 将自动组合
      # operate-data: 'xxxx' 
      operation: 
        collection: 'assignments' # 操作数据目前只能一个collection，对多个collection的操作 下一步定义
        action-type: 'create' # create | view-list | view-item | update | delete | comment | approve
        references: # 将整合到工作页面上的数据，只读。
          collection: 'homeworks'
          relation: {assignment-id: _id} # mongo查询
      allows: # 注意！！！或者改allow、deny为 invisiable | visible | editable | uneditable ？？
        # * student: 'deadline:update'
          ...
      denys:
        # 所有collection的_id域界面上均无，除非出现在allow里面
        # * student: 'deadline:update'
          ...
      call-aw-defer-with: {assignment-is-pubished: true} # 此时默认用此object作为context，调用aw的defer-act
      after: ->
        @assigment-id = @current-task-data._id # 所有的@（this）都是指context
    * step: 'Write'
      actors: ['Role:Student'] # 无前缀Role:的可以是用户id
      viewers: ['Role:Teacher'] # 能够在这个阶段浏览到data的用户
      operation: 
        collection: 'homeworks' # 操作数据目前只能一个collection，对多个collection的操作 下一步定义
        action-type: 
          name: 'create' # create | view-list | view-item | update | delete | comment | approve
          pre-defined: {assinment-id: @assignment-id, score: null} #直接<<<到create的对象就好，pre-defined的
          pre-defined-visibles: [] # predefined的东东，默认界面上都是invisble，可以在这里设置visible
          pre-defined-editables: [] # predefined的东东，默认界面上都是invisble，可以在这里设置visible
        references: # 将整合到工作页面上的数据，只读。
          collection: 'assignment'
          relation: {_id: assignment} # mongo查询
    * step: 'Score'
      actors: ['Role:Teacher']
      operation:
        collection: 'homeworks'
        action-type: 
          name: 'update'
          fields: 'score'
        references: # 将整合到工作页面上的数据，只读。
          collection: 'assignment'
          relation: {_id: assignment} # mongo查询

  name: 'AW Homework'
  context-update-triggers: ['daily-timer'] # 每日检查，更新context和context aware的steps
  steps: # AW不管角色，角色由客户系统自行负责
    * name: 'Assign'
      is-start-active: true
      can-end: -> @assignment-is-pubished
      next: 'Write' # 可以进一步配置为可进入批改
    * name: 'Write'
      can-end: -> Date.now! > @deadline
      next: 'Score'
    * name: 'Score'
      can-end: -> @score-step-ended #这里将条件给到客户系统来决定

B-workflow-def =
  name: 'AW Homework'
  context-update-triggers: ['daily-timer'] # 每日检查，更新context和context aware的steps
  steps: # AW不管角色，角色由客户系统自行负责
    * name: 'Assign'
      is-start-active: true
      can-end: -> @assignment-is-pubished
      next: 'Write' # 可以进一步配置为可进入批改
    * name: 'Write'
      can-end: -> Date.now! > @deadline
      next: 'Score'
    * name: 'Score'
      can-end: -> @score-step-ended #这里将条件给到客户系统来决定
      next: ['Rebutal', 'Rescore']
    * name 'Rebutal'
      can-end: -> Date.now! > @rebutal-deadline
    * name 'Rescore'
      can-end: -> Date.now! > @rebutal-deadline
