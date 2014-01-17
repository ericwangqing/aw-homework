// Generated by LiveScript 1.2.0
(function(){
  var fs, jade, Names, Relation, Page, config, _, filters;
  fs = require('fs');
  jade = require('jade');
  Names = require('./Names');
  Relation = require('./Relation');
  Page = require('./Page');
  config = require('./_bp-config');
  _ = require('underscore');
  import$(jade.filters, filters = require('./_bp-filters'));
  module.exports = {
    components: [],
    relations: [],
    pages: [],
    variables: {},
    setApp: function(appName, config){
      this.appName = appName;
      this.config = config;
    },
    addComponent: function(namespace, docName, mainNav, className){
      this.initVariables(namespace, docName);
      return this.components.push({
        namespace: namespace,
        docName: docName,
        mainNav: mainNav,
        className: className
      });
    },
    initVariables: function(namespace, docName){
      config.init(namespace, docName);
    },
    addRelation: function(namespace, start, relationDescription, end, type){
      var relation;
      this.relations.push(relation = {
        namespace: namespace,
        start: start,
        relationDescription: relationDescription,
        end: end,
        type: type
      });
      relation = Relation.addRelation(relation);
    },
    addPage: function(){
      var page;
      this.pages.push(page = new Page(import$(this.config, arguments[0])));
      return page;
    },
    savePage: function(){
      this._saveAllConfiguration();
    },
    _saveAllConfiguration: function(){
      var appName;
      appName = this.appName ? "'" + this.appName + "'" : undefined;
      fs.writeFileSync('bp/main.ls', ("BP.App-name = " + appName + "\n") + ("BP.Component.create-components " + JSON.stringify(this.components) + ", " + JSON.stringify(this.relations) + "\n") + ("BP.Page.create-pages " + JSON.stringify(this.pages)));
    },
    value: function(attr){
      var attrName, result, ref$, docName;
      if (attr.indexOf(':User') > 0 || attr.indexOf(':user') > 0) {
        attrName = attr.split(':')[0];
        return result = "{{bs-user '" + attrName + "'}}";
      } else if (attr.indexOf('.') > 0) {
        ref$ = attr.split('.'), docName = ref$[0], attr = ref$[1];
        return result = "{{#with " + docName + "}} {{bs '" + attr + "'}} {{/with}}";
      } else {
        return result = "{{bs '" + attr + "'}}";
      }
    },
    getNames: function(namespace, docName){
      return this.names = new Names(namespace, docName);
    },
    getAttrName: function(fullAttrName){
      var name;
      name = _.first(fullAttrName.split(':'));
      return name = _.last(name.split('.'));
    },
    getDocName: function(fullAttrName){
      return _.first(fullAttrName.split('.'));
    },
    saveComponent: function(){
      this._saveAllConfiguration();
    },
    registerTemplate: function(templateName, templateStr){
      this.templateRegistry || (this.templateRegistry = {});
      this.templateRegistry[templateName] = templateStr;
    },
    showTemplate: function(templateStr){
      console.log(templateStr);
    },
    getRelations: function(docName){
      return Relation.getRelationsByDocName(docName);
    },
    getViewTemplateName: function(namespace, docName, viewName){
      var names;
      names = this.getNames(namespace, docName);
      if (viewName === 'list') {
        return names.listTemplateName;
      } else {
        return names.detailTemplateName;
      }
    },
    getTableConfig: function(namespace, docName){
      return config.getConfig(namespace, docName).table;
    },
    addItemLink: function(){
      return config.addItemLink.apply(config, arguments);
    },
    addItemLinks: function(){
      return config.addItemLinks.apply(config, arguments);
    },
    addListLink: function(){
      return config.addListLink.apply(config, arguments);
    },
    removeLink: function(){
      return config.removeLink.apply(config, arguments);
    }
  };
  function import$(obj, src){
    var own = {}.hasOwnProperty;
    for (var key in src) if (own.call(src, key)) obj[key] = src[key];
    return obj;
  }
}).call(this);
