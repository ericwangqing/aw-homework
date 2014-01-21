permission = BP.Permission.get-instance!

permission.add-page-rules do
  'teacher:assignments-list':
    users: 'R-学生'
    denies: 'access' ## 这里出现任意值，都是deny
    
  'teacher:assignment-homework':
    users: 'NOT-R-老师'
    denies: 'access'

  'student:assignments-list':
    users: 'R-老师'
    denies: 'access'

permission.add-data-rule assignment:
  users: 'R-学生'
  denies: 'c-edit'

teacher-own = "(doc['老师'] == Meteor.userId())"
permission.add-data-rule assignment:
  users: 'R-老师'
  condition: "!#teacher-own"
  denies: "i-view"

for-student = "(doc['学生'] && _.indexOf(doc['学生'], Meteor.userId()) >= 0)"
permission.add-data-rule assignment:
  users: 'R-学生'
  condition: "!#for-student"
  denies: "i-view"

already-has-homework = "doc.homeworks.length >= 1"
permission.add-data-rule assignment:
  users: 'R-学生'
  condition: "#already-has-homework"
  denies: "i-create"

permission.add-data-rule homework:
  users: 'R-老师'
  denies: 'i-create, i-delete, a-内容-edit'

permission.add-data-rule homework:
  users: 'R-学生'
  constrains: per-user-own: '0, 1'
  denies: 'a-分数-edit'