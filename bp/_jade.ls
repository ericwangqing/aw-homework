# !!! 注意，此文件不是运行时代码，是开发时代码。
# 给Jade用，根据template中的定义，动态编译出Views，以便BP Router加载。


require! [fs, './client/view'.View]

module.exports =
  get-view: (doc-name, template-name, template-type)->
    View.get-view.apply View, &

  set-main-nav: (template-names)->
    for name in template-names
      View.registry[name].is-main-nav = true

  save-view: (view)!->
    fs.write-file-sync 'bp/main.ls', code + (JSON.stringify View.registry)


code = ''' 
if module
  require! [fs, sugar, './Component'] 

BP ||= {}
BP.Component ||= Component

debugger
BP.Component.create-bpc-for-views views = 
'''



