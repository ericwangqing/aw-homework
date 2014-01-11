## 注意：原来这里使用的是Meteor本身的Session，但是由于Meteor Session的reactive，会导致page中多个view的transfer-state陷入循环计算
## 因此，transfet-state用原生localStrage，component state用Session

@BP ||= {}
## 用以存放非reactive的状态，例如：页面之间的transfer-state
Local-session = 
  get: (key)->
    value = window.session-storage[key]
    # console.log "get value: ", value
    if typeof value is 'string' then JSON.parse value else value

  set: (key, value)->
    # console.log "set value: ", value
    window.session-storage[key] = JSON.stringify value

class @BP.State
  (namespace, is-reactive)->
    is-reactive = true if typeof is-reactive is 'undefined' # 默认reactive，也就是使用Meteor Session
    @Session = if is-reactive then window.Session else Local-session
    @namespace = 'bp-' + namespace
    @Session.set @namespace, {} if not @Session.get @namespace

  get: (attr)->
    attr = attr.camelize false
    (@Session.get @namespace)[attr]

  set: (obj-attr, value)!->
    state = @Session.get @namespace
    if typeof obj-attr is 'string'
      attr = obj-attr.camelize false
      state[attr] = value
    else
      state <<< obj-attr
    @Session.set @namespace, state


