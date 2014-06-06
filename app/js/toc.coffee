ANIMATION_NAME = 'slide'
HOVER_DELAY = 250  # TODO: test this; not sure it's actually an improvement

angular.module('styleguide.toc', ['styleguide.viewport'])

  # Calculate the window-relative y offset of the given element.
  .factory 'yOffset', ->
    (element) ->
      return 0 unless element
      # Grab the first match if this is a wrapped element.
      element = element[0] if (element.bind and element.find)
      offset = element.offsetTop
      node = element
      while node.offsetParent and node.offsetParent isnt document.body
        node = node.offsetParent
        offset += node.offsetTop
      offset

  # Collect h[1-4] elements into a scope, which is shared by the below
  # `tableOfContents` directive.
  .directive 'tocContainer', ($window, viewport, yOffset) ->
    # Flatten scope.items into a list of {offset, item} objects.
    findScrollTargets = (items) ->
      scrollTargets = []
      angular.forEach items, (item) ->
        scrollTargets.push
          offset: yOffset(item.element) - viewport.height / 3
          item: item
        [].push.apply(scrollTargets, findScrollTargets(item.children))
      return scrollTargets

    # Maintain the list of table of contents items, including which item(s) are
    # currently scrolled into view.
    controller: ($scope, $location) ->
      # A nested array of items.
      $scope.items = []

      # activeItem maps heading level numbers to the currently-active item in
      # items of that level.
      $scope.activeItem = {}

      # A set of y-offsets mapping to scope.items.
      yOffsets = []
      yOffsetsByLevel = []
      updateOffsets = ->
        tmp = _.chain(findScrollTargets($scope.items))
          .sortBy((t) -> t.offset)
        yOffsets = tmp.value()
        yOffsetsByLevel = tmp.groupBy((t) -> t.item.level).value()

      # Set `scope.activeItem` and the document location based on the current
      # scroll position.
      updateActiveItem = (offset) =>
        return if transitioning
        y = if angular.isDefined(offset)
          offset
        else
          $window.scrollY or $window.document.documentElement.scrollTop  # IE

        # Set active item at each level.
        $scope.activeItem = {}
        angular.forEach yOffsetsByLevel, (offsets, level) ->
          angular.forEach offsets, (x, i) ->
            if x.offset <= y < (yOffsetsByLevel[i + 1]?.offset or Infinity)
              $scope.activeItem[level] = x.item

        # Find closest offset for setting the URL path.
        path = null
        angular.forEach yOffsets, (x, i) ->
          if x.offset <= y < (yOffsets[i + 1]?.offset or Infinity)
            path = x.item.anchor
        @pathUpdate = "/#{path or ''}"
        $location.path(@pathUpdate).replace()

      # Allow for temporarily suspending update of active items.
      transitioning = false
      @transitionTo = (offset) ->
        updateActiveItem(offset)
        transitioning = true
        return -> transitioning = false

      angular.element($window).bind('load', updateOffsets)
      $scope.$watch('items', updateOffsets)
      $scope.$on('viewportResized', updateOffsets)
      angular.element($window).bind 'scroll', ->
        $scope.$apply -> updateActiveItem()

      return this

    # Parse the element's children for appropriate headers and set scope.items.
    link: (scope, elm, attrs) ->
      anchors = {}
      makeAnchor = (text) ->
        root = anchor = text.toLowerCase().replace(/[^a-zA-Z]+/g, '-')
        index = 0
        # Anchors must be unique.
        while anchor of anchors
          anchor = [root, index++].join('')
        anchors[anchor] = true
        return anchor

      makeTarget = (heading, level, elm) ->
        heading = heading.text()
        anchor = makeAnchor(heading)
        elm.attr('id', anchor)
        heading: heading
        level: level
        anchor: anchor
        element: elm
        children: []
        hovered: false

      # Recursively find all headings at each successive level.
      findTargets = (wrapper, level) ->
        targets = []
        angular.forEach wrapper.find("h#{level}"), (heading) ->
          heading = angular.element(heading)
          # Allow headings to opt out with a `no-toc` attribute.
          return if angular.isDefined(heading.attr('no-toc'))
          container = heading.parent()
          target = makeTarget(heading, level, container)
          target.children = findTargets(container, level + 1) if level < 2
          targets.push(target)
        return targets

      scope.items = findTargets(elm, 1)

  # Create and manage the dynamic table of contents.
  .directive 'tableOfContents', ($timeout, $window, yOffset, $location) ->
    require: '^tocContainer'
    templateUrl: 'partials/toc.html'
    link: (scope, elm, attrs, container) ->
      # Enable animations once the initial state is configured.
      $timeout(-> scope.animation = ANIMATION_NAME)

      scroll = (to) ->
        done = container.transitionTo(to)
        TweenLite.to $window, .4,
          scrollTo: {y: to}
          ease: Power2.easeInOut
          onComplete: done

      scope.scrollToTop = -> scroll(0)
      scope.scrollTo = ($event, item) ->
        $event.preventDefault()
        scroll(yOffset(item.element))

      scope.hover = (item, over) ->
        $timeout.cancel(item.hoverTimeout)
        if item.hovered isnt over
          item.hoverTimeout = $timeout((-> item.hovered = over), HOVER_DELAY)

      scrollToPath = (path) ->
        # Do nothing if tocContainer updated the path based on the scroll
        # position.
        return if path is container.pathUpdate
        anchor = path.replace(/^\//, '')
        if anchor
          scroll(yOffset($window.document.getElementById(anchor)))
        else
          scope.scrollToTop()

      # Wait for the page to load before doing any scrolling.
      # TODO Firefox seems to have already fired the load event here; timeout
      # is a poor excuse, but it works for now.
      #angular.element($window).bind 'load', ->
      $timeout ->
        scope.$watch((-> $location.path()), scrollToPath)
        scrollToPath($location.path())

  # CSS transitions/animations cannot interpolate to/from `height: auto`, but
  # we have access to `scrollHeight` here. We courteously reset to auto height
  # after the show animation is complete.
  .animation "#{ANIMATION_NAME}-show", ->
    setup: (element) ->
      element.css(height: 0)
    start: (element, done) ->
      TweenLite.to element, .3,
        height: "#{element[0].scrollHeight}px"
        onComplete: ->
          element.css(height: null)
          done()
  .animation "#{ANIMATION_NAME}-hide", ->
    setup: (element) ->
      element.css(height: "#{element[0].scrollHeight}px")
    start: (element, done) ->
      TweenLite.to(element, .3, height: 0, onComplete: done)
