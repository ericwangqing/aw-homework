require! '../bin/lib/permission'
Permission = permission.Permission
Rule = permission.Rule

describe 'parsing测试', (...)!->
  it '正确parsing', !->
    rule = new Rule assignment:
      users: '沈少伟 陈伟津 R-老师'
      allows: 'c-view, a-要求-edit'
      denies: 'i-create, a-截止时间-edit'

    console.log "rule: ", rule