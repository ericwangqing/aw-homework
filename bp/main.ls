 
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
BP.Component.create-components-from-jade-views jade-views = {"assignments-list":{"docName":"assignment","componentName":"default","templateName":"assignments-list","type":"list","name":"assignments-list","isMainNav":true,"referredViews":{},"cited":{"homework":{"query":"{assignmentId: doc._id}","isMultiple":true}},"additionalLinks":[{"icon":"go-create","path":"go-create-default.homework","to":"default.homework.detail.create","citedDoc":"homework","showName":"作业","citedViewType":"detail","label":"创建作业","guard":true},{"icon":"go-update","path":"go-update-default.homework","to":"default.homework.detail.update","citedDoc":"homework","showName":"作业","citedViewType":"detail","context":"homework","label":"更新{{bs '学生'}}","guard":"homeworks"}]},"assignment":{"docName":"assignment","componentName":"default","templateName":"assignment","type":"detail","name":"assignment","isMainNav":false,"referredViews":{},"cited":{"homework":{"query":"{assignmentId: doc._id}","isMultiple":true}},"additionalLinks":[]},"homeworks-list":{"docName":"homework","componentName":"default","templateName":"homeworks-list","type":"list","name":"homeworks-list","isMainNav":true,"referredViews":{},"cited":{"assignment":{"query":"{_id: doc.assignmentId}","isMultiple":false}},"additionalLinks":[{"icon":"go-update","path":"go-update-default.assignment","to":"default.assignment.detail.update","citedDoc":"assignment","showName":"作业要求","citedViewType":"detail","context":"assignment","label":"更新作业要求","guard":"assignment"}]},"homework":{"docName":"homework","componentName":"default","templateName":"homework","type":"detail","name":"homework","isMainNav":false,"referredViews":{},"cited":{"assignment":{"query":"{_id: doc.assignmentId}","isMultiple":false}},"additionalLinks":[]}}