class @Homework-list extends BP.List-view
  create-data-manager: !-> @data-manager = new List-data-manager @

class List-data-manager extends BP.List-data-manager
  ->
    @cited-data = [{doc-name: 'assignment', query: '{_id: doc.assignmentId}'}]
    super ...


class @Homework-detail extends BP.Detail-view
  create-data-manager: !-> @data-manager = new Detail-data-manager @


class Detail-data-manager extends BP.Detail-data-manager
  ->
    @cited-data = [{doc-name: 'assignment', query: '{_id: doc.assignmentId}'}]
    super ...
