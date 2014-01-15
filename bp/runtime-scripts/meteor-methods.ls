Meteor.methods do
  'bp-update-doc': (collection-name, doc)->
    collection = BP.Collection.get collection-name
    if doc._id
      old-doc = collection.find-one _id: doc._id
      new-doc = _.extend old-doc, doc # 注意！！这里暂时还咩有考虑动态域被移除的情况
    else
      new-doc = doc # 这里是新建的情况
    collection.upsert {_id: doc._id}, new-doc

  # 'bp-get-users': (usernames, rolename)->
  #   result = []
  #   users = Meteor.users.find {$or:
  #     * username: usernames
  #     * 'profile.roles': $regex: ".*#{rolename}.*"
  #   } .fetch!

    # console.log "________ find users: ", users
    # users