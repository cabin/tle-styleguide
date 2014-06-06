module = angular.module('styleguide.button', [])

# Temporary helper until we have downloadable assets ready.
module.directive 'button', ->
  blurt = [
    'Coming soon!'
    'We promise!'
    'Alright already!'
  ]
  restrict: 'C'
  link: (scope, elm, attrs) ->
    if attrs.href is 'XXX'
      clickCount = 0
      origText = elm.text()
      elm.bind 'click', (event) ->
        event.preventDefault()
        elm.css
          width: "#{elm[0].clientWidth}px"
          textAlign: 'center'
        if clickCount < blurt.length
          text = blurt[clickCount]
          clickCount++
        else if clickCount is blurt.length
          text = origText
          elm.addClass('animated hinge')
        else
          return
        elm.text(text)
