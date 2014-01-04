components = # array of components
relations = # array of relations

component = # grunt jade过程中解析出来的component定义，然后Meteor启动时，根据它进行初始化。
  component-class-name: 'xxxx' # 当这一属性存在时，b+将使用这个类，而不是默认的List-Component或Detail-Component类来实例化，这是最终极的定制手段
  doc-name: assignment
  namespace: # nampespace, component-name
  is-main-nav: true

relation = 
  namespace: 'xxx'
  from: 'assignment'
  to: 'homework'
  description: '1 -> *'
  type: 'composition


# debugger
BP.Component.create-components-from-jade-views jade-views = {
  "assignments-list": {
    "docName": "assignment",
    "componentName": "default",
    "templateName": "assignments-list",
    "type": "list",
    "name": "assignments-list",
    "isMainNav": true,
    "referredViews": {},
    "cited": {
      "homework": {
        "query": "{assignmentId: doc._id}",
        "isMultiple": true
      }
    },
    "additionalLinks": [
      {
        "icon": "go-create",
        "path": "go-create-default.homework",
        "to": "default.homework.detail.create",
        "citedDoc": "homework",
        "showName": "作业",
        "citedViewType": "detail",
        "label": "创建作业",
        "guard": true
      },
      {
        "icon": "go-update",
        "path": "go-update-default.homework",
        "to": "default.homework.detail.update",
        "citedDoc": "homework",
        "showName": "作业",
        "citedViewType": "detail",
        "context": "homework",
        "label": "更新{{bs '学生'}}",
        "guard": "homeworks"
      }
    ]
  },
  "assignment": {
    "docName": "assignment",
    "componentName": "default",
    "templateName": "assignment",
    "type": "detail",
    "name": "assignment",
    "isMainNav": false,
    "referredViews": {},
    "cited": {
      "homework": {
        "query": "{assignmentId: doc._id}",
        "isMultiple": true
      }
    },
    "additionalLinks": []
  },
  "homeworks-list": {
    "docName": "homework",
    "componentName": "default",
    "templateName": "homeworks-list",
    "type": "list",
    "name": "homeworks-list",
    "isMainNav": true,
    "referredViews": {},
    "cited": {
      "assignment": {
        "query": "{_id: doc.assignmentId}",
        "isMultiple": false
      }
    },
    "additionalLinks": [
      {
        "icon": "go-update",
        "path": "go-update-default.assignment",
        "to": "default.assignment.detail.update",
        "citedDoc": "assignment",
        "showName": "作业要求",
        "citedViewType": "detail",
        "context": "assignment",
        "label": "更新作业要求",
        "guard": "assignment"
      }
    ]
  },
  "homework": {
    "docName": "homework",
    "componentName": "default",
    "templateName": "homework",
    "type": "detail",
    "name": "homework",
    "isMainNav": false,
    "referredViews": {},
    "cited": {
      "assignment": {
        "query": "{_id: doc.assignmentId}",
        "isMultiple": false
      }
    },
    "additionalLinks": []
  }
}