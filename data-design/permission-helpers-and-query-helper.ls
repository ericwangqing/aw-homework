permission-helper =
  bp-can-view-list: -> # ！！不在template helper中控制，后端控制查询，前端双保险，1）在get-path里，检查权限，无权限为null，也就不显示链接，2）在router before里检查，对不可显示的在router上指向缺少权限页面
  bp-can-view-detail: -> # ！！不在template helper中控制，后端控制查询，前端双保险，1）在get-path里，检查权限，无权限为null，也就不显示链接，2）在router before里检查，对不可显示的在router上指向缺少权限页面
  bp-can-view-attribute: -> # ！！不在template helper中控制，后端查询后，publish前进行projection，仅仅剩余有权限的字段
  bp-can-creat: (doc-name)-> # 同时控制 list上的go-create，和detail.create上的submit
  bp-can-update: (doc-name, doc)-> # 同时控制 list item(row)上的go-update，和detail.update上的submit
  bp-can-update-attribute: (doc-name, attr-name, doc)->
  bp-can-delete: (doc-name, doc)-> # 同时控制 list item(row)上的go-update，和detail.update上的submit

# iron-router是不是getPath返回null，整个链接就不出现？？

permission-query-helper =
  get-list-query: (doc-name, query-without-permission)-> # 过滤后，仅仅返回用户有显示全新的条目
    # return query take permission of the current user into consideration. Both selecting on rows and projecting on columns(attributes).