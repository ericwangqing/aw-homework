permission = BP.Permission.get-instance!
permission.add-rule assignment:
  users: '沈少伟 陈伟津 R-老师'
  allows: 'c-view'
  denies: 'i-create, a-要求-edit, a-截止时间-view'
  
# permission.add-rule assignment:
#   users: '陈伟津'
#   denies: 'a-截止时间-view'
  







# { 'assignment': { users: '沈少伟 陈伟津 R-老师', allows: 'c-view, a-要求-edit', denies: 'i-create, a-截止时间-edit'}}


