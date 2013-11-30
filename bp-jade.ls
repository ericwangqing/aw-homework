require! 'fs'
bpcs = {}
module.exports =
  make-bpc: (doc-name)!->
    if not bpcs[doc-name]
      bpcs[doc-name] = true # 每个doc只对应于一个BPC
      code = @complie {doc-name: doc-name}
      fs.append-file-sync 'src/main.ls', code
  complie: (context)->
    @compile-bp-initial-code.call context, context
  compile-bp-initial-code: ->
    "new BP.Component '#{@docName}'\n"