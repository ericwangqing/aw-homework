do show-main-nav-with-all-bp-components-and-custom-nav-paths = !->
  Template['bp-main-nav'].helpers 'main-nav-paths': ->
    BP.Component.main-nav-paths

do make-splash-click-fadeout = !->
  Template.splash.events do
    'click':  (e)!->
      $ '#splash' .add-class 'fadeout'
      # $ '.bp-form' .add-class 'fadein'

do make-loading-spinner = !->
  Template.loading.rendered = !->
    @spinner = new Spinner!spin @find "#loading"