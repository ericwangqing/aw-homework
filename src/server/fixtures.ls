Meteor.startup ->
  if Assignments?.find!count! is 0
    console.log "insert data ...."
    for i to 1
      Assignments.insert do
        '中文内容': '中文内容'
        email: 'eric@g.com'
        '题目': '工作流技术综述'
        '要求': '了解工作流技术的基本问题、发展历史、目前研究热点...'
        for-students: ['沈少伟', '陈伟津']
        '截止时间': '2014-10-10'
        created-at-time: '2013-12-12'
        last-modified-at: '2013-12-12'
        state: 'published'
        'bp-current-action': 'abc'

      Assignments.insert do
        '中文内容': '中文内容'
        email: 'eric@g.com'
        '题目': '现代Web程序设计'
        '要求': '了解工作流技术的基本问题、发展历史、目前研究热点...'
        for-students: ['沈少伟', '陈伟津']
        '截止时间': '2014-10-10'
        created-at-time: '2013-12-12'
        last-modified-at: '2013-12-12'
        state: 'published'
        'bp-current-action': 'abc'

  if Meteor.users.find!count! is 0
    users =
      * username: 'wangqing'
        password: 'password'
        profile: fullname: '王青'
      * username: 'shenshaowei'
        password: 'password'
        profile: fullname: '沈少伟'
      * username: 'chenweijin'
        password: 'password'
        profile: fullname: '陈伟津'

    [Accounts.create-user user for user in users]