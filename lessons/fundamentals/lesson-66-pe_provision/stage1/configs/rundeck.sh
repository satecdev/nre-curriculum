!#/bin/bash

STAGE="stage1"

#-- Get key
curl -D - -X POST -H "Content-Type: application/x-www-form-urlencoded"   -H "Cache-Control: no-cache"   -d "j_username=admin&j_password=admin"   --cookie-jar /antidote/${STAGE}/configs/rd_cookie   http://localhost:4440/${SYRINGE_FULL_REF}/j_security_check

#-- delete all projects

# delete all projects (jq not in docker)
#curl -s -X GET -H "Accept: application/json" --cookie /antidote/${STAGE}/configs/rd_cookie "http://localhost:4440/${SYRINGE_FULL_REF}/api/32/projects" | jq -r ' .[] | .name' | while read project
#do
#    curl -vvv -X DELETE -H "Accept: application/json"  --cookie /antidote/${STAGE}/configs/rd_cookie "http://localhost:4440/${SYRINGE_FULL_REF}/api/32/project/${project}"
#done

curl -vvv -X DELETE -H "Accept: application/json"  --cookie /antidote/${STAGE}/configs/rd_cookie "http://localhost:4440/${SYRINGE_FULL_REF}/api/32/project/SATEC"


#-- Create project. PENDING QUOTES FORMAT in order to use variable STAGE
#curl -vvv -X POST -H "Content-Type: application/json" -d {"name":"SATEC","config":{"project.label":"SATEC-label","resources.source.2.type":"file","resources.source.2.config.file":"/antidote/${STAGE}/configs/rundeckinventory.json","resources.source.2.config.format":"resourcejson"}} --cookie /antidote/${STAGE}/configs/rd_cookie "http://localhost:4440/${SYRINGE_FULL_REF}/api/32/projects"
curl -vvv -X POST -H "Content-Type: application/json" -d '{ "name": "SATEC", "config": { "project.label":"SATEC-label", "resources.source.2.type":"file", "resources.source.2.config.file":"/antidote/rundeckinventory.json", "resources.source.2.config.format":"resourcejson" } }' --cookie /antidote/stage1/configs/rd_cookie "http://localhost:4440/${SYRINGE_FULL_REF}/api/32/projects"

#-- add key 
curl -vvv -X POST -H "Content-type: application/x-rundeck-data-password" -d "antidotepassword" --cookie /antidote/${STAGE}/configs/rd_cookie "http://localhost:4440/${SYRINGE_FULL_REF}/api/32/storage/keys/antidote/cpe"

#-- create jobs (FILE: rundeck.jobs.yml with all jobs)
curl -vvv -X POST -H "Content-Type: application/yaml" --data-binary @/antidote/${STAGE}/configs/rundeck.jobs.yml --cookie /antidote/${STAGE}/configs/rd_cookie "http://localhost:4440/${SYRINGE_FULL_REF}/api/32/project/SATEC/jobs/import?fileformat=yaml&dupeOption=update"

