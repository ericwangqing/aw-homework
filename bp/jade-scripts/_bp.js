// Generated by LiveScript 1.2.0
(function(){
  var fs, jade, Names, Relation, _, filters;
  fs = require('fs');
  jade = require('jade');
  Names = require('./Names');
  Relation = require('./Relation');
  _ = require('underscore');
  import$(jade.filters, filters = require('./_bp-filters'));
  module.exports = {
    components: [],
    relations: [],
    addComponent: function(namespace, docName, isMainNav, className){
      return this.components.push({
        namespace: namespace,
        docName: docName,
        isMainNav: isMainNav,
        className: className
      });
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
    value: function(attr){
      var ref$, docName, result;
      if (attr.indexOf('.') > 0) {
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
      return _.last(fullAttrName.split('.'));
    },
    getDocName: function(fullAttrName){
      return _.first(fullAttrName.split('.'));
    },
    saveComponent: function(){
      fs.writeFileSync('bp/main.ls', "BP.Component.create-components " + JSON.stringify(this.components) + ", " + JSON.stringify(this.relations));
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
    }
  };
  function import$(obj, src){
    var own = {}.hasOwnProperty;
    for (var key in src) if (own.call(src, key)) obj[key] = src[key];
    return obj;
  }
}).call(this);
