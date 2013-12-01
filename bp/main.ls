if module
  require! [fs, sugar, './Router']

BP ||= {}
BP.Router ||= Router

debugger
BP.Router.add-route-for-views views = {"assignments-list":{"docName":"assignment","name":"assignments-list","type":"list","path":{"destinationViewName":"assignments-list","type":"list","composedPaths":[]},"isMainNav":true,"composedViews":{},"entraces":[],"gotos":[]},"assignment":{"docName":"assignment","name":"assignment","type":"detail","path":{"destinationViewName":"assignment","type":"detail","composedPaths":[]},"isMainNav":false,"composedViews":{"ref-assignments-list":"assignments-list"},"entraces":[],"gotos":[]}}