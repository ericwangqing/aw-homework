# !!! 注意，此文件不是运行时代码，是开发时代码。
# 给Jade用，根据template中的定义，动态编译出Views，以便BP Router加载。


require! [fs, './view'.View, './Names']

module.exports =
  get-view: (doc-name, view-name, template-name, template-type)->
    View.get-view.apply View, &

  set-main-nav: (template-names)->
    template-names = template-names.split ',' if typeof template-names is 'string'
    for name in template-names
      name = name.trim!
      View.registry[name].is-main-nav = true

  save-view: (view)!->
    fs.write-file-sync 'bp/main.ls', code + (JSON.stringify View.registry)

  get-ref: (ref)->
    switch ref
    case 'detail' then @names.detail-template-name
    case 'list' then @names.list-template-name
    default ref

  get-names: (doc-name)-> 
    @names = new Names doc-name 




code = ''' 
# if module?
#   require! [fs, sugar, './Component'] 

# BP ||= {}
# BP.Component ||= Component

# debugger
BP.Component.create-bpc-for-views views = 
'''



