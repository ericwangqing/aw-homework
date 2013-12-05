# BPH组件，Meteor Template需要的各种Helper
@BP ||= {}
top = @
do make-handlebars-understand-chinese-key = !->
  Handlebars.register-helper 'bs', (attr)-> # 克服Meteor Handlebars不能使用中文key，形如{{中文}}会出错的问题。改用{{bs '中文'}}
    @[attr]

class @BP.Abstract-Registable
  @registry = {}
  @add = (name, instance)->
    throw new Error "Can't add, instance with '#name' already exist." if not @registry[name]
    @registry[name] = instance

  @get = (name, class-name, params)->
    @registry[name] if not class-name
    @registry[name] ||= eval "new #{class-name}(params)"