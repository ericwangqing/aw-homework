// Generated by LiveScript 1.2.0
(function(){
  var Page;
  Page = (function(){
    Page.displayName = 'Page';
    var prototype = Page.prototype, constructor = Page;
    Page.registry = {};
    Page.createPages = function(pages){
      var i$, len$, page, results$ = [];
      for (i$ = 0, len$ = pages.length; i$ < len$; ++i$) {
        page = pages[i$];
        results$.push(this.resume(page));
      }
      return results$;
    };
    Page.resume = function(pageConfig){
      var page, ref$, key$, i$, len$, viewConfig;
      page = new Page(pageConfig);
      page.faces = [];
      page.pathName = page.templateName;
      (ref$ = this.registry)[key$ = page.namespace] || (ref$[key$] = {});
      this.registry[page.namespace][page.name] = page;
      for (i$ = 0, len$ = (ref$ = pageConfig.views).length; i$ < len$; ++i$) {
        viewConfig = ref$[i$];
        page.addComponentView(viewConfig);
      }
      return page.init();
    };
    Page.pathFor = function(namespace, pageName, docName, doc){
      var page;
      page = Page.registry[namespace][pageName];
      return page.getPath(docName, doc);
    };
    function Page(arg$){
      this.namespace = arg$.namespace, this.name = arg$.name, this.isMainNav = arg$.isMainNav;
      this.templateName = [this.namespace, this.name].join('-');
      this.views = [];
    }
    prototype.addView = function(namespace, docName, viewName, faceName, query){
      return this.views.push({
        namespace: namespace,
        docName: docName,
        viewName: viewName,
        faceName: faceName,
        query: query
      });
    };
    prototype.addComponentView = function(viewConfig){
      var vc, component;
      vc = viewConfig;
      component = BP.Component.registry[vc.namespace][vc.docName];
      this.faces.push({
        view: component[vc.viewName],
        faceName: vc.faceName
      });
    };
    prototype.init = function(){
      var path;
      this.route();
      if (this.isMainNav) {
        BP.Component.mainNavPaths.push(path = {
          name: this.templateName,
          path: this.pathName
        });
      }
    };
    prototype.route = function(){
      var self;
      self = this;
      Router.map(function(){
        this.route(self.pathName, {
          path: self.getPathPattern(),
          template: self.templateName,
          before: function(){
            if (!self.isPermit()) {
              alert("没有权限访问");
              this.redirect('default');
            } else {
              self.setViewsCurrentFaces();
              self.storeDataInState();
            }
          },
          waitOn: function(){
            return self.subscribe(this.params);
          }
        });
      });
    };
    prototype.getPathPattern = function(){
      var pattern, i$, ref$, len$, face;
      pattern = "/" + this.pathName;
      for (i$ = 0, len$ = (ref$ = this.faces).length; i$ < len$; ++i$) {
        face = ref$[i$];
        pattern += face.view.faces[face.faceName];
      }
      return pattern;
    };
    prototype.getPath = function(docName, doc){
      var path, i$, ref$, len$, face, id;
      path = "/" + this.pathName;
      for (i$ = 0, len$ = (ref$ = this.faces).length; i$ < len$; ++i$) {
        face = ref$[i$];
        id = this.getFaceId(face, docName, doc);
        path += face.view.facesManager.getPath(face.view.faces[face.faceName], id);
      }
      return path;
    };
    prototype.getFaceId = function(face, docName, doc){
      var id;
      return id = face.view.docName === docName
        ? doc._id
        : doc[docName + 'Id'];
    };
    prototype.isPermit = function(){
      var i$, ref$, len$, face;
      for (i$ = 0, len$ = (ref$ = this.faces).length; i$ < len$; ++i$) {
        face = ref$[i$];
        if (!face.view.isPermit(face.view.dataManager.doc, face.faceName)) {
          return flase;
        }
      }
      return true;
    };
    prototype.setViewsCurrentFaces = function(){
      var i$, ref$, len$, face;
      for (i$ = 0, len$ = (ref$ = this.faces).length; i$ < len$; ++i$) {
        face = ref$[i$];
        face.view.currentFaceName = face.faceName;
      }
    };
    prototype.storeDataInState = function(){
      var i$, ref$, len$, face;
      for (i$ = 0, len$ = (ref$ = this.faces).length; i$ < len$; ++i$) {
        face = ref$[i$];
        face.view.dataManager.storeDataInState();
      }
    };
    prototype.subscribe = function(params){
      var i$, ref$, len$, face;
      for (i$ = 0, len$ = (ref$ = this.faces).length; i$ < len$; ++i$) {
        face = ref$[i$];
        face.view.dataManager.subscribe(params);
      }
    };
    return Page;
  }());
  if (typeof module != 'undefined' && module !== null) {
    module.exports = Page;
  } else {
    BP.Page = Page;
  }
}).call(this);