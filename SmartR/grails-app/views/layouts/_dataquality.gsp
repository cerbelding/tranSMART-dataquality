<script type="text/ng-template" id="dataquality">
<div ng-controller="DataqualityController">
    <tab-container>
        <workflow-tab tab-name="Fetch Data" disabled="fetch.disabled">
            <concept-box style="display: inline-block;"
                         concept-group="fetch.conceptBoxes.numeric"
                         type="LD-numerical"
                         min="0"
                         max="-1"
                         label="Numerical Variables"
                         tooltip="Select numerical variables of interest from the data tree and drag them into the box.">
            </concept-box>
            <concept-box style="display: inline-block;"
                         concept-group="fetch.conceptBoxes.categoric"
                         type="LD-categorical"
                         min="0"
                         max="-1"
                         label="Categorical Variables"
                         tooltip="Select categorical variables of interest from the tree and drag them into the box.">
            </concept-box>
            <br/>
            <br/>
            <fetch-button concept-map="fetch.conceptBoxes"
                          loaded="fetch.loaded"
                          running="fetch.running"
                          allowed-cohorts="[1,2]">
            </fetch-button>
        </workflow-tab>

        <workflow-tab tab-name="Run Analysis" disabled="runAnalysis.disabled">
            <br/>
            <br/>
            <div class="heim-input-field sr-input-area"></div>
            <hr class="sr-divider">
            <run-button button-name="Create Plot"
                        store-results-in="runAnalysis.scriptResults"
                        script-to-run="run"
                        arguments-to-use="runAnalysis.params"
                        running="runAnalysis.running">
            </run-button>
            <br/>
            <br/>
            <dataquality data="runAnalysis.scriptResults"></dataquality>
        </workflow-tab>
    </tab-container>
</div>
</script>
