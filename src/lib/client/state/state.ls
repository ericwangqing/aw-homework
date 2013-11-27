@BP ||= {}
@BP.State = do
  get: (attr)->
    attr = attr.camelize false
    (Session.get 'bp')[attr]

  set: (obj-attr, value)!->
    bp = (Session.get 'bp') || {}
    if typeof obj-attr is 'string'
      attr = obj-attr.camelize false
      bp[attr] = value
    else
      bp <<< obj-attr
    Session.set 'bp', bp

  get-previous-doc-id: (current-id)->
    previous-id = null
    for id in  BP.State.get 'doc-ids'
      break if id is current-id
      previous-id = id
    previous-id

  update-pre-next: (current-id)!->
    pre = next = null
    if doc-ids = @get 'doc-ids' # 在List Template里查询数据后，会更新'doc-ids'
      for id, index in doc-ids
        break if id is current-id
        pre = id
      next = doc-ids[index + 1] 
    @set 'previous-id', pre
    @set 'next-id', next



