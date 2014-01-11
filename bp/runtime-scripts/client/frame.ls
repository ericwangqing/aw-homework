do show-main-nav-with-all-bp-components-and-custom-nav-paths = !->
  Template['bp-main-nav'].helpers 'main-nav-paths': ->
    BP.Component.main-nav-paths

do make-splash-click-fadeout = !->
  Template.splash.events do
    'click':  (e)!->
      $ '#splash' .add-class 'fadeout'

    'webkitAnimationEnd': !->
      Router.go BP.Component.main-nav-paths.0.path

do make-loading-spinner = !->
  Template.loading.rendered = !->
    @spinner = new Spinner!spin @find "#loading"

do initial-layout-semantic-ui = !->
  Template.layout.rendered = _.once ->
    $ '.launch-second-nav.item' .click ->
      $ '.sidebar.menu' .sidebar 'toggle'