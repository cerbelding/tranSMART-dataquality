# tranSMART-dataquality

This repository contains the developmental part of Cornelius Knopp's master thesis.
This encompasses all the project data needed to build a dataquality-Plugin in tranSMART using the SmartR framework.

## Build the plugin
### Alternative 1: build `.war` manually
To use these contents, simply copy the `SmartR` folder into the `SmartR` folder of your tranSMART binaries.  
Afterwards one has to build the `.war`-file using Grails.

### Alternative 2: use UMG-internal GitLab-CI/CD Pipeline
_THIS APPROACH DOES ONLY WORK WITH VALID CREDENTIALS FOR GWDG-GITLAB!_ 
  
* Step 1: create a personal GitLab branch in each of the following Repositories [1]
  * `transmart-data`
  * `Rmodules`
  * `transmart-core-db`
  * `transmartApp`
  * `SmartR`
* Step 2: copy/move the plugin files into the `SmartR`-Repository [2]
* Step 3: modify `.gitlab-ci.yml` File
  * replace branch "master" by your personal branch name
* Step 4: start the CI/CD Pipeline (if not triggered automatically)
* Step 5: Start the tranSMART-server by using the `tm_umg`-Repository from GWDG-GitLab [3]
  * clone `tm_umg`-Repository
  * switch to your (local) personal branch
  * modify `.env` according to `tm_umg`-README --> replace WAR_BRANCH by personal branch name
  * start the server via ```docker-compose up -d```


______
[1] [https://gitlab.gwdg.de/medinf/AGITF/transmart](https://gitlab.gwdg.de/medinf/AGITF/transmart)  
[2] [https://gitlab.gwdg.de/medinf/AGITF/transmart/SmartR](https://gitlab.gwdg.de/medinf/AGITF/transmart/SmartR)  
[3] [https://gitlab.gwdg.de/medinf/AGITF/tm_umg](https://gitlab.gwdg.de/medinf/AGITF/tm_umg)
