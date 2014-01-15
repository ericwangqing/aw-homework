permission = BP.Permission.get-instance!

permission.add-data-rule assignment:
  users: 'R-学生'
  denies: 'c-edit'

permission.add-data-rule homework:
  users: 'R-老师'
  denies: 'i-create, i-delete, a-内容-edit'

permission.add-data-rule homework:
  users: 'R-学生'
  denies: 'a-分数-edit'


