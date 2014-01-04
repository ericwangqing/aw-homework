## used both at developing time by jade and runtime by meteor
class Names
  (namespace, doc-name)-> 
    @component-prefix            =   if namespace is 'default' then '' else namespace + '-'
      # -------------- doc和collection名称 ----------------------
    @doc-name                    =   doc-name
    @mongo-collection-name       =   doc-name.pluralize!
    @meteor-collection-name      =   doc-name.pluralize!capitalize!

      # -------------- Template和其方法名称 ----------------------
    @list-template-name          =   @component-prefix + doc-name.pluralize!  + '-list'
    @list-row-template-name      =   @component-prefix + doc-name.pluralize!  + '-list-row'
    @list-data-retriever-name    =   @component-prefix + doc-name.pluralize!
    @detail-template-name        =   @component-prefix + doc-name
    @detail-data-retriever-name  =   @component-prefix + doc-name

    # -------------- Data Publish名称 --------------------------
    @list-data-publish-name      =   @component-prefix + doc-name.pluralize!capitalize!
    @detail-data-publish-name    =   @component-prefix + doc-name.capitalize!



@BP ||= {}

if module? then module.exports = Names else BP.Names = Names # 让Jade和Meteor都可以使用