@BP ||= {}
class @BP.View
  # a template may have more than one views, which can be distinguished by view-index
  (template-name, view-id)->
    @name = template-name + '[' + view-id + ']'
    @state = new BP.State @name