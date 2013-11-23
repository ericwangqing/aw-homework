# 这里的helper不是应用程序用的，而是bp用的。将来将萃取到bp package里。
bp-state ||= do
  current-rendering-collection: null
  current-action: null
# bp在渲染doc的时候，需要知道其来自哪一个collection，方能确定其权限
Handlebars.register-helper 'bp-set-collection', !(collection-name, action-name)->
  # dfdsfd.dd
  action-name = 'edit' if not action-name # 注意！！！ 仅仅为开发使用，逻辑并不正确！！
  bp-state.current-rendering-collection = collection-name
  bp-state.current-action = action-name
  # console.log "bp-state.current-rendering-collection: #bp-state.current-rendering-collection"

Handlebars.register-helper 'bp-get-collection', !(collection-name)->
  bp-state.current-rendering-collection

Handlebars.register-helper 'bp-attribute-permit', (itemid, attr, action)->
  collection = bp-state.current-rendering-collection
  autos = <[createdAtTime lastModifiedAt _id state]>
  # references = ['forStudents']
  console.log "collection: #collection, _id: #itemid, attr: #attr, action: #action"
  attr not in autos
  # false

Handlebars.register-helper 'bp-action-is', (doc-id, action-name)->
  true if action-name is 'edit'


Handlebars.register-helper 'bp-collection-permit', (action)->
  # get-collection-name from bp-state.current-rendering-collection
  true



  # _id: 'aid-1'
  # teacher: '王青'
  # title: '工作流技术综述'
  # requirement: '了解工作流技术的基本问题、发展历史、目前研究热点...'
  # for-students: ['沈少伟', '陈伟津']
  # deadline: '2014-1-10'
  # created-at-time: '2013-12-12'
  # last-modified-at: '2013-12-12'
  # state: 'published'

