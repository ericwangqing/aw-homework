@BP ||= {}
class @BP.Permission
  attribute-permission-checker: (doc, attr, action)~> # Template调用，检查当前用户是否有权限进行相应操作
    #TODO：接入Bp-Permission模块，提供权限功能
    # bp-Permssion.can-user-act-on Meteor.userId, @doc-name, attr, action
    # 下面是暂时的fake
    auto-generated-fields = <[createdAtTime lastModifiedAt _id state]>
    attr not in auto-generated-fields

  doc-permission-checker: (doc, action)~>
    #TODO：接入Bp-Permission模块，提供权限功能
    # bp-Permssion.can-user-act-on Meteor.userId, @doc-name, action
    # 下面是暂时的fake
    true

  collection-permission-checker: (action)~>
    #TODO：接入Bp-Permission模块，提供权限功能
    # bp-Permssion.can-user-act-on Meteor.userId, @doc-name, doc-id, action
    # 下面是暂时的fake
    true
