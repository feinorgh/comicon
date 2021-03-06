'use strict';

var comiconControllers = angular.module('comiconControllers', []);

comiconControllers.controller('ComicGeneratorController',
        ['$scope', 'ComicStrip', 'ComicText',
        function($scope, ComicStrip, ComicText) {
            $scope.getNewStrip = function() {
                $scope.comicstrip = ComicStrip.get({}, function(res) {
                    ComicText.position(res.data);
                });
            }
            $scope.getNewStrip();
        }
]);

