//# sourceURL=dataquality.js
'use strict';
window.smartRApp.controller('DataqualityController',
    ['$scope', 'smartRUtils', 'commonWorkflowService', function($scope, smartRUtils, commonWorkflowService) {
        commonWorkflowService.initializeWorkflow('dataquality', $scope);
        $scope.fetch = {
            disabled: false,
            running: false,
            loaded: false,
            conceptBoxes: {
                numeric: {concepts: [], valid: false},
                categoric: {concepts: [], valid: false}
            }
        };
        $scope.runAnalysis = {
            disabled: true,
            running: false,
            scriptResults: {},
            params: {
                // inputmode: 'shannon'
                // transformation: 'raw'
            }
        };
        $scope.$watchGroup(['fetch.running', 'runAnalysis.running'],
            function(newValues) {
                var fetchRunning = newValues[0],
                    runAnalysisRunning = newValues[1];
                // clear old results
                if (fetchRunning) {
                    $scope.runAnalysis.scriptResults = {};
                }
                // disable tabs when certain criteria are not met
                $scope.fetch.disabled = runAnalysisRunning;
                $scope.runAnalysis.disabled = fetchRunning || !$scope.fetch.loaded;
            }
        );
    }]);