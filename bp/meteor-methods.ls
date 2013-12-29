Meteor.methods do
  'bp-update-doc': (collection-name, doc)->
    collection = BP.Collection.get collection-name
    old-doc = collection.find-one _id: doc._id
    new-doc = _.extend old-doc, doc # 注意！！这里暂时还咩有考虑动态域被移除的情况
    collection.upsert {_id: doc._id}, new-doc