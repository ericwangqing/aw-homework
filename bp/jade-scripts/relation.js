// Generated by LiveScript 1.2.0
(function(){
  var Relation, replace$ = ''.replace;
  Relation = (function(){
    Relation.displayName = 'Relation';
    var prototype = Relation.prototype, constructor = Relation;
    Relation.registry = {};
    Relation.addRelation = function(arg$){
      var namespace, start, relationDescription, end, type, relation;
      namespace = arg$.namespace, start = arg$.start, relationDescription = arg$.relationDescription, end = arg$.end, type = arg$.type;
      relation = new Relation({
        namespace: namespace,
        start: start,
        relationDescription: relationDescription,
        end: end,
        type: type
      });
      this._addToRegistryOf(relation.startPoint.docName, relation);
      this._addToRegistryOf(relation.endPoint.docName, relation);
    };
    Relation._addToRegistryOf = function(docName, relation){
      var ref$;
      (ref$ = this.registry)[docName] || (ref$[docName] = []);
      this.registry[docName].push(relation);
    };
    Relation.getRelationsByDocName = function(docName){
      return this.registry[docName] || [];
    };
    function Relation(arg$){
      var start, end;
      this.namespace = arg$.namespace, start = arg$.start, this.relationDescription = arg$.relationDescription, end = arg$.end, this.type = arg$.type;
      this.getPoints(start, end);
    }
    prototype.getPoints = function(start, end){
      var ref$, navigatingDirection;
      this.startPoint = (ref$ = this.getNames(start), ref$.type = 'start', ref$);
      this.endPoint = (ref$ = this.getNames(end), ref$.type = 'end', ref$);
      ref$ = this.relationDescription.split(/\s+/), this.startPoint.multiplicity = ref$[0], navigatingDirection = ref$[1], this.endPoint.multiplicity = ref$[2];
      return this.markAbilityOfCreateOtherSide();
    };
    prototype.getNames = function(point){
      if (typeof point === 'string') {
        return {
          docName: point,
          showName: point
        };
      } else {
        return Object.clone(point);
      }
    };
    prototype.markAbilityOfCreateOtherSide = function(){
      this.startPoint.canCreateOtherSide = true;
      if (this.type === 'composition') {
        this.endPoint.canCreateOtherSide = false;
      } else {
        this.endPoint.canCreateOtherSide = true;
      }
    };
    prototype.getGoCreateLink = function(currentEnd){
      return this.getLinkByAction('go-create', currentEnd);
    };
    prototype.getGoUpdateLink = function(currentEnd){
      return this.getLinkByAction('go-update', currentEnd);
    };
    prototype.getCurrentEnd = function(current){
      var currentDocName;
      currentDocName = typeof current === 'string'
        ? current
        : current.docName;
      if (this.startPoint.docName === currentDocName) {
        return this.startPoint;
      } else {
        return this.endPoint;
      }
    };
    prototype.getOppositeEnd = function(current){
      var currentDocName;
      currentDocName = typeof current === 'string'
        ? current
        : current.docName;
      if (this.startPoint.docName === currentDocName) {
        return this.endPoint;
      } else {
        return this.startPoint;
      }
    };
    prototype.getLinkByAction = function(action, currentEnd){
      var destinationEnd, face, docName, showName, fullDocName, view, link;
      destinationEnd = this.getOppositeEnd(currentEnd);
      face = this.stripGoPrefix(action);
      docName = destinationEnd.docName, showName = destinationEnd.showName;
      fullDocName = this.namespace + '.' + docName;
      view = face === 'list' ? 'list' : 'detail';
      link = {
        icon: action,
        face: face,
        path: [action, this.namespace, docName].join('-').camelize(false),
        to: {
          namespace: this.namespace,
          docName: docName,
          view: view,
          face: face
        },
        citedDoc: docName,
        showName: showName,
        citedViewType: view,
        context: docName
      };
      if (typeof module != 'undefined' && module !== null) {
        link = this._alterLinkByFace(destinationEnd, link, face, docName, showName);
      }
      return link;
    };
    prototype._alterLinkByFace = function(destinationEnd, link, face, docName, showName){
      var bp;
      bp = require('./_bp');
      switch (face) {
      case 'create':
        link.label = '创建' + showName;
        link.guard = destinationEnd.multiplicity === '1' ? "!" + docName + "._id" : true;
        delete link.context;
        break;
      case 'update':
        link.label = destinationEnd.multiplicity === '1'
          ? "更新" + showName
          : "更新" + bp.value(destinationEnd.showAttr);
        link.guard = destinationEnd.multiplicity === '1'
          ? docName + ""
          : docName.pluralize() + "";
        break;
      case 'view':
        link.label = destinationEnd.multiplicity === '1'
          ? "更新" + showName
          : "更新" + bp.value(destinationEnd.showAttr);
        if (view === 'detail') {
          link.guard = destinationEnd.multiplicity === '1'
            ? docName + ""
            : docName.pluralize() + "";
        } else {
          link.guard = 'true';
        }
        break;
      default:
        link.label = face + ': ' + showName;
        link.guard = 'true';
      }
      return link;
    };
    prototype.stripGoPrefix = function(action){
      var face;
      if (action.indexOf('go-') >= 0) {
        face = replace$.call(action, 'go-', '');
      } else {
        face = action;
      }
      if (action === 'go') {
        face = 'list';
      }
      return face;
    };
    prototype.getQuery = function(docName){
      var query;
      if (docName === this.startPoint.docName) {
        return query = "{_id: doc." + docName + "Id}";
      } else {
        return query = "{" + this.startPoint.docName + "Id: doc._id}";
      }
    };
    return Relation;
  }());
  if (typeof module != 'undefined' && module !== null) {
    module.exports = Relation;
  } else {
    BP.Relation = Relation;
  }
}).call(this);
