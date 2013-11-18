A-workflow-def =
  _id: 'wfid1'
  name: 'AW Homework'
  context-update-triggers: ['daily-timer'] # 每日检查，更新context和context aware的steps
  steps: # AW不管角色，角色由客户系统自行负责
    * name: 'Assign'
      is-start-active: true
      can-end: -> @assignment-is-pubished
      next: 'Write' # 可以进一步配置为可进入批改
    * name: 'Write'
      can-end: -> Date.now! > @deadline
      next: 'Score'
    * name: 'Score'
      can-end: -> @score-step-ended #这里将条件给到客户系统来决定


Assignment= 
  _id: 'aid-1'
  teacher: '王青'
  title: '工作流技术综述'
  requirement: '了解工作流技术的基本问题、发展历史、目前研究热点...'
  for-students: ['沈少伟', '陈伟津']
  deadline: '2014-1-10'
  created-at-time: '2013-12-12'
  last-modified-at: '2013-12-12'
  state: 'published'

B-workflow-def =
  _id: 'wfid2'
  name: 'AW Homework'
  context-update-triggers: ['daily-timer'] # 每日检查，更新context和context aware的steps
  steps: # AW不管角色，角色由客户系统自行负责
    * name: 'Assign'
      is-start-active: true
      can-end: -> @assignment-is-pubished
      next: 'Write' # 可以进一步配置为可进入批改
    * name: 'Write'
      can-end: -> Date.now! > @deadline
      next: 'Score'
    * name: 'Score'
      can-end: -> @score-step-ended #这里将条件给到客户系统来决定
      next: ['Rebutal', 'Rescore']
    * name 'Rebutal'
      can-end: -> Date.now! > @rebutal-deadline
    * name 'Rescore'
      can-end: -> Date.now! > @rebutal-deadline

Homework = 
  _id: 'hid-1'
  assignment-id: 'aid-1'
  student: '沈少伟'
  content: '这个家伙很懒，还没留下什么....'
  score: null
  created-at-time: 'xxx'
  last-modified-at: 'xxx'
  state: 'writing'
  comments:
    * by: '王青'
      content: '抓紧时间啊...'
    ...
