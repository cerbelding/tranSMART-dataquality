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
        	var input_data_numeric = scope.data.input_data_numeric;
        	var input_data_categorical = scope.data.input_data_categorical;
        	
        	var rate_missing = scope.data.rate_missing;
        	var rate_missing_cleaned = scope.data.rate_missing_cleaned;
        	
        	var rate_vollstaendigkeit = scope.data.rate_vollstaendigkeit;
        	
        	var NAs = scope.data.NAs;
        	var ausreisser = scope.data.ausreisser
        
        	
        	function createResultTable(){
        	    //initialize tableData as content for the HTML Template
        	    var tableData = "";
        	    
        	    /* FIRST TABLE (Rates) */
        	    //add Heading + Table-Header
        	    tableData += "<H2>Data Quality - Dataset Level</H2>";
        	    tableData += "<div class='dataTable'><table><th>Quality Indicator</th><th>Value</th><th>Comments</th>";
        	    
        	    //add Rate_Missing
        	    tableData += "<tr><td>Rate_Missing</td><td>" + rate_missing + "</td><td>Relation of Missing Values</td></tr>";
        	    
        	    //add Rate_Missing_Cleaned
        	    tableData += "<tr><td>Rate_Missing_Cleaned</td><td>" + rate_missing_cleaned + "</td><td>Relation of Missing Values, without Variables with 100% Missings</td></tr>";
        	    
        	    //add Rate_Completeness
        	    tableData += "<tr><td>Rate_Completeness</td><td>" + rate_vollstaendigkeit + "</td><td>Relation of Variables with 0% Missings</td></tr>";
        	    
        	    //close Table + div
        	    tableData += "</table></div><br>";
        	    
        	    /* SECOND TABLE (Outliers) */
        	    //add Headings + Table-Header
        	    tableData += "<H2>Data Quality - Variable Level</H2><H3>Outlier Overview</H3>";
        	    tableData += "<div class='dataTable'><table><th>Variable name</th><th>Outlier counter</th><th>Outlier ratio</th><th>Outlier mean</th><th>Mean incl. Outliers</th><th>Mean excl. Outliers</th>";
        	    
        	    //add Table Content
        	    for (var i = 0; i < ausreisser.variables.lenght; i++){
        		tableData += "<tr>";
        		tableData += "<td>" + ausreisser.variables[i] + "</td>";
			tableData += "<td>" + ausreisser.outliers_cnt[i] + "</td>";
			tableData += "<td>" + ausreisser.outliers_ratio[i] + "</td>";
			tableData += "<td>" + ausreisser.outliers_mean[i] + "</td>";
			tableData += "<td>" + ausreisser.with_mean[i] + "</td>";
			tableData += "<td>" + ausreisser.without_mean[i] + "</td>";
			tableData += "</tr>";
        	    }
        	    //close Table + div
        	    tableData += "</table></div><br>";
        	    
        	    /* THIRD TABLE (Missing Values) */
        	    //add Headings + Table-Header
        	    tableData += "<H3>Missing-Values Overview</H3>";
        	    tableData += "<div class='dataTable'><table><th>Variable name</th><th>NA counter</th><th>NA relation</th>";
        	    
        	    //add Table Content
        	    for (var i = 0; i < NAs.variables.lenght; i++){
        		tableData += "<tr>";
        		tableData += "<td>" + NAs.variables[i] + "</td>";
			tableData += "<td>" + NAs.na_count[i] + "</td>";
			tableData += "<td>" + NAs.na_relation[i] + "</td>";
			tableData += "</tr>";
        	    }
        	    //close Table + div
        	    tableData += "</table></div>";
        	    
        	    // Add tableData to HTML Template
        	    d3.select(root).append("div").attr("class", "canRemove").attr("id", "dataTables");
			document.getElementById("dataTables").innerHTML = tableData;
        	}
        	
        	/* UTILITY FUNCTIONS */
        	
        	// Textwidth of any given text
		function getTextWidth(text, font) {
			var canvas = document.createElement("canvas");
			var context = canvas.getContext("2d");
			context.font = font;
			var metrics = context.measureText(text);
			return metrics.width;
		}
        	
        	// Removes the plot at wish
                function removePlot() {
                    //d3.select(root).selectAll('svg').remove();
                    d3.selectAll('.canRemove').remove();
    				d3.selectAll('.d3-tip').remove();
                }

        }
    }]);