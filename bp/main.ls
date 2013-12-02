 
if module
  require! [fs, sugar, './Component'] 

BP ||= {}
BP.Component ||= Component

debugger
BP.Component.create-bpc-for-views views = {"assignments-list":{"docName":"assignment","name":"assignments-list","templateName":"assignments-list","type":"list","path":{"destinationViewName":"assignments-list","type":"list","composedPaths":[],"patterns":{},"last":null},"isMainNav":true,"composedViews":{},"gotos":{},"state":null},"assignment":{"docName":"assignment","name":"assignment","templateName":"assignment","type":"detail","path":{"destinationViewName":"assignment","type":"detail","composedPaths":[],"patterns":{},"last":null},"isMainNav":false,"composedViews":{"ref-assignments-list":"assignments-list"},"gotos":{},"state":null}}