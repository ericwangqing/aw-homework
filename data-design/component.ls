components = # grunt jade过程中解析出来的component定义，然后Meteor启动时，根据它进行初始化。
  component-class-name: 'xxxx' # 当这一属性存在时，b+将使用这个类，而不是默认的List-Component或Detail-Component类来实例化，这是最终极的定制手段
  assignment:
    cited: 
      homework:
        fields['_id']
        remote-foreign-key: 'assignment-id'
    additonal-views:
      additonal-assignment-list:
        type: 'list' # 将根据这个来初始化view、adpater和ui
        template-name: 'additonal-assignment-list'
        addtional-appearances:
          approve: '/addtional-assignment-list/approve'
          
        addtional-links:
          go-end: 'assignment.detail.update'
          
        removed-links: ['go-create', 'go-update', 'delete']

  homework:
    cited:
      assignment:
        fields: ['题目', '要求', '截止时间']
        # fields: {'题目': '作业题目', '要求': '要求', '截止时间': '截止时间'} # 当cited属性名和本身的属性名冲突时，要用这样的方式给出别名
        foreign-key: 'assignment-id' # 这个关系不出现在path、url上，运行时通过transferred-state传递

links =
  create-homework:
    at: 'row' # doc/view/appearnce/position #list 是 table | row, #detail 是 action | nav
    label: '写作业'
    'to': 'homework.detail.create'
    guard: "not assignment.homework"
    icon: 'go-create'
  update-homework:
    at: 'row' # doc/view/appearnce/position #list 是 table | row, #detail 是 action | nav
    label: '写作业'
    'to': 'homework.detail.update'
    guard: "assignment.homework"
    icon: 'go-update'