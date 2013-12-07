@BP ||= {}

class @BP.State
  (@namespace)->
    Session.set 'bp', {} if not Session.get 'bp'

  get: (attr)->
    attr = attr.camelize false
    (Session.get 'bp')[@namespace]?[attr]

  set: (obj-attr, value)!->
    bp = (Session.get 'bp') || {} 
    bp[@namespace] ||= {}
    if typeof obj-attr is 'string'
      attr = obj-attr.camelize false
      bp[@namespace][attr] = value
    else
      bp[@namespace] <<< obj-attr
    Session.set 'bp', bp 


