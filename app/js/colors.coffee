module = angular.module('styleguide.colors', [])
  
module.controller 'ColorSwatchCtrl', ($scope) ->
  $scope.colors = [
    # Gold
    '#514939', '#685d45', '#807252', '#97875f', '#ac9f7f', '#c1b79f', '#d5cfbf'

    # Red
    '#712d2d', '#993434', '#c03b3b', '#e84242', '#ed6868', '#f18e8e', '#f6b3b3'

    # Salmon
    '#733b2c', '#9c4a33', '#c45839', '#ed6640', '#f18566', '#f4a38c', '#f8c2b3'

    # Orange
    '#7a5027', '#a7682b', '#d3812f', '#ff9933', '#ffad5c', '#ffc285', '#ffd6ad'

    # Yellow
    '#7a6427', '#a7872b', '#d3a92f', '#ffcc33', '#ffd65c', '#ffe085', '#ffebad'

    # Yellow-Green
    '#545c2f', '#6d7a38', '#869940', '#9fb748', '#b2c56d', '#c5d491', '#d9e2b6'

    # Green
    '#36532f', '#416e37', '#4b883f', '#55a247', '#77b56c', '#99c791', '#bbdab5'

    # Green-Blue
    '#2e574f', '#347467', '#3a907f', '#40ac97', '#66bdac', '#8ccdc1', '#b3ded5'

    # Sea-Blue
    '#305d60', '#367c80', '#3d9ba1', '#44bac1', '#69c8cd', '#8fd6da', '#b4e3e6'

    # Sky-Blue
    '#31526d', '#396c93', '#4085ba', '#489fe1', '#6db2e7', '#91c5ed', '#b6d9f3'

    # Royal-Blue
    '#31356e', '#384095', '#404bbd', '#4756e4', '#6c78e9', '#919aef', '#b5bbf4'

    # Purple
    '#562f6f', '#703698', '#8a3ec0', '#a446e8', '#b66bed', '#c890f1', '#dbb5f6'

    # Pink
    '#712f58', '#993674', '#c03e91', '#e846ad', '#ed6bbd', '#f190ce', '#f6b5de'

    # Dark
    '#101010', '#262523', '#3a3935', '#4f4d48', '#64615b', '#78756d', '#8c8981'

    # Light
    '#9f9c95', '#b1afaa', '#c4c2be', '#d7d6d3', '#e9e9e7', '#fcfcfc', '#ffffff'
  ]

  $scope.select = (color) ->
    $scope.selected = color
