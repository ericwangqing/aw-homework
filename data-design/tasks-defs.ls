# 定义process中各个step将对业务数据进行的操作
A-tasks-def = 
  _id: 'tdid1'
  context: {assignment-id: null, current-task-data: null} # 用以在各个task之间传递数据
  tasks:
    * step: "Assign"
      # 确定、生成模板用
      operation: 
        collection: 'assignments' # 操作数据目前只能一个collection，对多个collection的操作 下一步定义
        action-type: 'create' # create | view-list | view-item | update | delete | comment | approve
        references: # task中，必要的信息，将整合到工作页面上的数据，只读。
          collection: 'homeworks'
          relation: {assignment-id: _id} # mongo查询
      # Bp-method中将动态调用以下这部分的逻辑（Logic Weave）
      call-aw-defer-with: {deadline: @deadline} # 此时默认用此object作为context，调用aw的defer-act
      after: ->
        @assigment-id = @current-task-data._id # 所有的@（this）都是指context

    * step: 'Write'
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
      call-aw-defer-with: {} # 此时默认用此object作为context，调用aw的defer-act
      after: ->
        @assigment-id = @current-task-data._id # 所有的@（this）都是指context

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