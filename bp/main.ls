 
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
BP.Component.create-components-from-jade-views jade-views = {"assignments-list":{"docName":"assignment","componentName":"default","templateName":"assignments-list","type":"list","name":"assignments-list","isMainNav":true,"referredViews":{},"cited":{"homework":{"query":"{assignmentId: doc._id}"}},"additionalLinks":[{"icon":"go-create","path":"go-create-default.homework","to":"default.homework.detail.create","citedDoc":"homework","citedViewType":"detail","label":"创建homework","guard":"homework._id"},{"icon":"go-update","path":"go-update-default.homework","to":"default.homework.detail.update","citedDoc":"homework","citedViewType":"detail","context":"homework","label":"更新homework","guard":"homework"}]},"assignment":{"docName":"assignment","componentName":"default","templateName":"assignment","type":"detail","name":"assignment","isMainNav":false,"referredViews":{},"cited":{"homework":{"query":"{assignmentId: doc._id}"}},"additionalLinks":[]},"homeworks-list":{"docName":"homework","componentName":"default","templateName":"homeworks-list","type":"list","name":"homeworks-list","isMainNav":true,"referredViews":{},"cited":{"assignment":{"query":"{_id: doc.assignmentId}"}},"additionalLinks":[{"icon":"go-update","path":"go-update-default.assignment","to":"default.assignment.detail.update","citedDoc":"assignment","citedViewType":"detail","context":"assignment","label":"更新assignment","guard":"assignment"}]},"homework":{"docName":"homework","componentName":"default","templateName":"homework","type":"detail","name":"homework","isMainNav":false,"referredViews":{},"cited":{"assignment":{"query":"{_id: doc.assignmentId}"}},"additionalLinks":[]}}