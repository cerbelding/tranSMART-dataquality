//# sourceURL=d3Dataquality.js

'use strict';

window.smartRApp.directive('dataquality', [
    'smartRUtils',
    'rServeService',
    '$rootScope',
    function(smartRUtils, rServeService, $rootScope) {

        return {
            restrict: 'E',
            scope: {
                data: '='
            },
            templateUrl: $rootScope.smartRPath +  '/js/smartR/_angular/templates/dataquality.html',
            link: function (scope, element) {
                var vizDiv = element.children()[0];
                /**
                 * Watch data model (which is only changed by ajax calls when we want to (re)draw everything)
                 */
                scope.$watch('data', function () {
                    $(vizDiv).empty();
                    if (! $.isEmptyObject(scope.data)) {
                        reportDataquality(scope, vizDiv);
                    }
                });
            }
        };


        function reportDataquality(scope, vizDiv) {
        	document.write("Dataquality Report:");
        }
    }]);
        
