# 这里是约定的整个应用的入口
# ------------ 初始化BP组件 ---------------------------------
new BP.Component 'assignment' .init!
new BP.Component 'test' .init!

# ------------ 加载应用程序BP组件外的其它路由 ------------------

# if Meteor.is-client
#   Router.map ->
#     @route 'not-bp-component-path', do
#       path: '/to/not-bp/component/path'
#       template: 'not-bp-template'
    # yield-templates: