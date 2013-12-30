 
# ********************************************************
# *                                                      *
# *        IT IS AUTO GENERATED DON'T EDIT               *
# *                                                      *
# ********************************************************

# if module?
#   require! [fs, sugar, './Component'] 

# BP ||= {}
# BP.Component ||= Component

# debugger
BP.Component.create-components-from-jade-views jade-views = {"assignments-list":{"docName":"assignment","componentName":"default","templateName":"assignments-list","type":"list","name":"assignments-list","isMainNav":true,"referredViews":{},"additionalLinks":[]},"assignment":{"docName":"assignment","componentName":"default","templateName":"assignment","type":"detail","name":"assignment","isMainNav":false,"referredViews":{},"additionalLinks":[]},"aw-assignments-list":{"docName":"assignment","componentName":"aw","templateName":"aw-assignments-list","type":"list","name":"aw-assignments-list","isMainNav":true,"referredViews":{},"cited":{"homework":{"query":"{assignmentId: doc._id}"}},"additionalLinks":[{"label":"开始写作业","path":"create-homework","to":"homework.detail.create","guard":"homework._id","icon":"go-create"},{"label":"更新作业","path":"update-homework","to":"homework.detail.update","context":"homework","guard":"homework._id","icon":"go-update"}]},"aw-assignment":{"docName":"assignment","componentName":"aw","templateName":"aw-assignment","type":"detail","name":"aw-assignment","isMainNav":false,"referredViews":{},"cited":{"homework":{"query":"{assignmentId: doc._id}"}},"additionalLinks":[]},"homeworks-list":{"docName":"homework","componentName":"default","templateName":"homeworks-list","type":"list","name":"homeworks-list","isMainNav":true,"referredViews":{},"cited":{"assignment":{"query":"{_id: doc.assignmentId}","attributes":["题目","要求","截止时间","testRefList"]}},"additionalLinks":[{"label":"看作业要求列表","path":"go-assignment-list","to":"assignment.list.list","guard":true,"icon":"go"}]},"homework":{"docName":"homework","componentName":"default","templateName":"homework","type":"detail","name":"homework","isMainNav":false,"referredViews":{},"cited":{"assignment":{"query":"{_id: doc.assignmentId}","attributes":["题目","要求","截止时间","testRefList"]}},"additionalLinks":[]}}