(function(){
  if (Meteor.isClient) {
    Template.hello.greeting = function(){
      return "Welcome to AW-Homework";
    };
    Template.hello.events({
      'click input': function(){
        return alert("Great Work");
      }
    });
  }
}).call(this);
