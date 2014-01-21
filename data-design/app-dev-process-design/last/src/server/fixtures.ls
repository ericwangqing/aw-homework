Meteor.startup ->
  if Meteor.users.find!count! is 0
    users =
      * _id: 'wangqing'
        username: '王青'
        password: 'password'
        profile: fullname: '王青', roles: '老师'
      * _id: 'linliang'
        username: '林倞'
        password: 'password'
        profile: fullname: '林倞', roles: '老师'
      * _id: 'shenshaowei'
        username: '沈少伟'
        password: 'password'
        profile: fullname: '沈少伟', roles: '学生'
      * _id: 'chenweijin'
        username: '陈伟津'
        password: 'password'
        profile: fullname: '陈伟津', roles: '学生'

    [Accounts.create-user user for user in users]
    wangqing = Meteor.users.find-one {username: '王青'}
    linliang = Meteor.users.find-one {username: '林倞'}

  if Assignments?.find!count! is 0
    console.log "insert data ...."
    Assignments.insert do
      '编号': 'HW-1'
      '题目': '工作流技术综述'
      '要求': '了解工作流技术的基本问题、发展历史、目前研究热点...'
      '截止时间': '2014-10-10'
      '老师': wangqing._id

    Assignments.insert do
      '编号': 'HW-2'
      '题目': '现代Web程序设计'
      '要求': '了解工作流技术的基本问题、发展历史、目前研究热点...'
      '截止时间': '2014-10-10'
      '老师': wangqing._id

    Assignments.insert do
      '编号': 'HW-3'
      '题目': 'Web程序设计'
      '要求': '了解工作流技术的基本问题、发展历史、目前研究热点...'
      '截止时间': '2014-10-10'
      '老师': linliang._id