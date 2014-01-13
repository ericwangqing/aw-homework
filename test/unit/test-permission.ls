Rule = require '../bin/lib/permission/_rule'

describe 'parsing测试', (...)!->
  it '正确parsing', !->
    rule = Rule.create-data-rule assignment:
      users: '沈少伟 陈伟津 R-老师'
      allows: 'c-view, a-要求-edit'
      denies: 'i-create, a-截止时间-edit'

    # console.log "rule: ", rule