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

## 学生只能够创建一个作业的限制，如何实现？

## dev模式：二级导航里面的为原始没有加show relation 限制的内容，但是从page过去时，要同样限制