# 给Jade用，根据template中的定义，动态编译出Views，以便BP Router加载


require! [fs, './navigation'.View]

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
  require! [fs, sugar, './Router']

BP ||= {}
BP.Router ||= Router

debugger
BP.Router.add-route-for-views views = 
'''



