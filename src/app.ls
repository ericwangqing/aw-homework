permission = BP.Permission.get-instance!
permission.add-rule assignment:
  users: '沈少伟 陈伟津 R-老师'
  allows: 'c-view, a-要求-edit'
  denies: 'i-create, a-截止时间-edit'
  
permission.add-rule homework:
  users: '陈伟津'
  denies: 'i-create'
  







# { 'assignment': { users: '沈少伟 陈伟津 R-老师', allows: 'c-view, a-要求-edit', denies: 'i-create, a-截止时间-edit'}}


