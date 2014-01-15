Meteor.startup ->
  if Assignments?.find!count! is 0
    console.log "insert data ...."
    Assignments.insert do
      '编号': 'HW-1'
      '题目': '工作流技术综述'
      '要求': '了解工作流技术的基本问题、发展历史、目前研究热点...'
      '截止时间': '2014-10-10'
      '老师': '王青'

    Assignments.insert do
      '编号': 'HW-2'
      '题目': '现代Web程序设计'
      '要求': '了解工作流技术的基本问题、发展历史、目前研究热点...'
      '截止时间': '2014-10-10'
      '老师': '王青'

    Assignments.insert do
      '编号': 'HW-3'
      '题目': 'Web程序设计'
      '要求': '了解工作流技术的基本问题、发展历史、目前研究热点...'
      '截止时间': '2014-10-10'
      '老师': '王青'

  if Meteor.users.find!count! is 0
    users =
      * username: 'wangqing'
        password: 'password'
        profile: fullname: '王青', roles: '老师'
      * username: 'linliang'
        password: 'password'
        profile: fullname: '林倞', roles: '老师'
      * username: 'shenshaowei'
        password: 'password'
        profile: fullname: '沈少伟', roles: '学生'
      * username: 'chenweijin'
        password: 'password'
        profile: fullname: '陈伟津', roles: '学生'

    [Accounts.create-user user for user in users]