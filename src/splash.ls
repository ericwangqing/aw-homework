if Meteor.is-client
  Template.splash.events do
    'click':  (e)!->
      $ '#splash' .add-class 'fadeout'
      # $ '.bp-form' .add-class 'fadein'