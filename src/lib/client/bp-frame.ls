do to-show-all-bp-components-on-main-nav = !->
  Template['bp-main-nav'].helpers 'collection-paths': ->
    BP.Component.collection-paths!

do make-splash-click-fadeout = !->
  Template.splash.events do
    'click':  (e)!->
      $ '#splash' .add-class 'fadeout'
      # $ '.bp-form' .add-class 'fadein'