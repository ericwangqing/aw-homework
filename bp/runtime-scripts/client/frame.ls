do add-navs = !->
  Template['bp-main-nav'].helpers 'main-nav-paths': -> BP.Nav.main-nav-paths
  Template['bp-second-nav'].helpers 'second-nav-paths': -> BP.Nav.second-nav-paths

do make-splash-click-fadeout = !->
  Template.splash.events do
    'click':  (e)!->
      $ '#splash' .add-class 'fadeout'

    'webkitAnimationEnd': !->
      Router.go BP.Nav.main-nav-paths.0.path

do make-loading-spinner = !->
  Template.loading.rendered = !->
    @spinner = new Spinner!spin @find "#loading"

do initial-layout-semantic-ui = !->
  Template.layout.rendered = _.once ->
    $ '.launch-second-nav.item' .click ->
      $ '.sidebar.menu' .sidebar 'toggle'