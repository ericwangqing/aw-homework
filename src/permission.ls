permission = BP.Permission.get-instance!

permission.add-page-rules do
  'teacher:assignments-list':
    users: 'R-学生'
    denies: 'access' ## 这里出现任意值，都是deny
  'teacher:assignment-homework':
    users: 'R-学生'
    denies: 'access'

  'student:assignments-list':
    users: 'R-老师'
    denies: 'access'

permission.add-data-rule assignment:
  users: 'R-学生'
  denies: 'c-edit'

permission.add-data-rule homework:
  users: 'R-老师'
  denies: 'i-create, i-delete, a-内容-edit'

permission.add-data-rule homework:
  users: 'R-学生'
  denies: 'a-分数-edit'

# permission.add-data-rule homework:
#   users: 'R-学生'
#   denies: 'i-create(items-own-by-current-user().length >= 1) i-edit(!item-own-by-current-user()) a-分数-edit'

## 学生只能够创建一个作业的限制，如何实现？

## dev模式：二级导航里面的为原始没有加show relation 限制的内容，但是从page过去时，要同样限制

## 只有Page才能够出现在Main Nav上，从Main Nav开始的情况，都是DEPLOYMENT

## Component List出现在sencond Nav上，从Component List开始的情况，都是DEVLOPMENT