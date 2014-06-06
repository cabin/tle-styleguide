angular.module('styleguide.viewport', [])

  # Track the viewport size, broadcasting a `viewportResized` event to all
  # non-isolated scopes on change.
  .service 'viewport', ($window, $rootScope) ->
    # Support IE.
    w = -> $window.innerWidth or $window.document.documentElement.clientWidth
    h = -> $window.innerHeight or $window.document.documentElement.clientHeight
    viewport = {}
    do update = ->
      viewport.width = w()
      viewport.height = h()
      $rootScope.$broadcast('viewportResized')
    angular.element($window).bind('resize', update)
    return viewport

  # Set the given element to be at least as tall as the viewport.
  .directive 'fillHeight', (viewport) ->
    link: (scope, elm, attrs) ->
      do update = ->
        elm.css(minHeight: "#{viewport.height}px")
      scope.$on('viewportResized', update)
