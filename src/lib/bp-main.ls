# BP应用的入口
# ------------ 初始化BP组件 --------------
new BP.Component 'assignment' .init!

# ------------ 加载路由 ------------------
BP.BPR.route! if Meteor.is-client