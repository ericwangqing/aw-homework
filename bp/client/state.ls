@BP ||= {}

class @BP.State
  (@namespace)->
    Session.set 'bp', {} if not Session.get 'bp'

  get: (attr)->
    attr = attr.camelize false
    (Session.get 'bp')[@namespace]?[attr]

  set: (obj-attr, value)!->
    bp = (Session.get 'bp') || {} 
    bp[@namespace] ||= {}
    if typeof obj-attr is 'string'
      attr = obj-attr.camelize false
      bp[@namespace][attr] = value
    else
      bp[@namespace] <<< obj-attr
    Session.set 'bp', bp

  update-pre-next: (current-id)!->
    pre = next = null
    if doc-ids = @get 'doc-ids' # 在List Template里查询数据后，会更新'doc-ids'
      for id, index in doc-ids
        break if id is current-id
        pre = id
      next = doc-ids[index + 1] 
    @set 'previous-id', pre
    @set 'next-id', next
 


