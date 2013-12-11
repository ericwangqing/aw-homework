# used both at developing time by jade and runtime by meteor
class Names
  (doc-name)-> 
    @ <<< do
      # -------------- doc和collection名称 ----------------------
      doc-name                    :   doc-name
      mongo-collection-name       :   doc-name.pluralize!
      meteor-collection-name      :   doc-name.pluralize!capitalize!

      # -------------- Template和其方法名称 ----------------------
      list-template-name          :   doc-name.pluralize!  + '-list'
      list-row-template-name      :   doc-name.pluralize!  + '-list-row'
      list-data-retriever-name    :   doc-name.pluralize!
      detail-template-name        :   doc-name
      detail-data-retriever-name  :   doc-name

    # -------------- Data Publish名称 --------------------------
      list-data-publish-name      :   doc-name.pluralize!capitalize!
      detail-data-publish-name    :   doc-name.capitalize!

    # -------------- Route名称和路径 --------------------------
    _base-route-name              =   doc-name.pluralize! 
    _base-route-path              =   '/' + doc-name.pluralize! 

    # @ <<< do
    #   list-path-name              :   _base-route-name
    #   list-route-path             :   -> _base-route-path
    #   create-path-name            :   _base-route-name    + '-create'
    #   create-route-path           :   -> _base-route-path + '/create'
    #   delete-path-name            :   _base-route-name    + '-delete'
    #   delete-route-path           :   -> _base-route-path + '/delete'
    #   update-path-name            :   _base-route-name    + '-update'
    #   update-route-path           :   (id) ->
    #                                     id ||= ':_id' # 前者用于生成链接（Template），后者用于匹配链接（Router）
    #                                     _base-route-path + "/#id/update"
    #   view-path-name              :   _base-route-name    + '-view'
    #   view-route-path             :   (id) ->
    #                                     id ||= ':_id' # 前者用于生成链接（Template），后者用于匹配链接（Router）
    #                                     _base-route-path + "/#id/view"


if module? then module.exports = Names else BP.Names = Names # 让Jade和Meteor都可以使用