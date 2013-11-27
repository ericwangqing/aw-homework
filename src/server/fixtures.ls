Meteor.startup ->
  if Assignments?.find!count! is 0
    Assignments.insert do
      # _id: '111111'
      teacher: '王青'
      '中文内容': '中文内容'
      email: 'eric@g.com'
      title: '工作流技术综述'
      requirement: '了解工作流技术的基本问题、发展历史、目前研究热点...'
      for-students: ['沈少伟', '陈伟津']
      deadline: '2014-1-10'
      created-at-time: '2013-12-12'
      last-modified-at: '2013-12-12'
      state: 'published'

    Assignments.insert do
      # _id: '111111'
      teacher: '王青'
      '中文内容': '中文内容'
      email: 'eric@g.com'
      title: '现代Web程序设计'
      requirement: '了解工作流技术的基本问题、发展历史、目前研究热点...'
      for-students: ['沈少伟', '陈伟津']
      deadline: '2014-1-10'
      created-at-time: '2013-12-12'
      last-modified-at: '2013-12-12'
      state: 'published'
