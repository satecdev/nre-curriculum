#!/bin/bash
# stage 1 jobs

rm -rf stage1/
rundeck_jobs -i jobs_lesson1_multiple.yml  -d stage1 -u 00000000-0000-0000-0000-000000000000 -l debug

cat jobs_stage1_vqfx3_composite.yml >> stage1/rundeck.jobs.yml

cp stage1/rundeck.jobs.yml ../stage1/configs/

# stage 2 jobs
rm -rf stage2/
rundeck_jobs -i jobs_stage2_config.yml -d stage2 -u 00000000-0000-0000-0000-000000000000 -l debug

rundeck_jobs -i jobs_stage2_verifications_ios1.yml -d stage2 -u 00000000-0000-0000-0000-000000000000 -o 101 -l debug -s "ios1: l3vpn configuration verification at ios1"
rundeck_jobs -i jobs_stage2_verifications_ios1_ios2.yml -d stage2 -u 00000000-0000-0000-0000-000000000000 -o 102 -l debug -s "ios1: l3vpn configuration verification at ios2-rr"
rundeck_jobs -i jobs_stage2_verifications_ios1_vqfx3.yml -d stage2 -u 00000000-0000-0000-0000-000000000000 -o 103 -l debug -s "ios1: l3vpn configuration verification at vqfx3-rr"

rundeck_jobs -i jobs_stage2_verifications_ios2.yml -d stage2 -u 00000000-0000-0000-0000-000000000000 -o 201 -l debug -s "ios2: l3vpn configuration verification at ios2"
rundeck_jobs -i jobs_stage2_verifications_ios1_vqfx3.yml -d stage2 -u 00000000-0000-0000-0000-000000000000 -o 202 -l debug -s "ios2: l3vpn configuration verification vqfx3-rr"


rundeck_jobs -i jobs_stage2_verifications_ios4.yml -d stage2 -u 00000000-0000-0000-0000-000000000000 -o 301 -l debug -s "ios4: l3vpn configuration verification at ios4"
rundeck_jobs -i jobs_stage2_verifications_ios4_ios2.yml -d stage2 -u 00000000-0000-0000-0000-000000000000 -o 302 -l debug -s "ios4: l3vpn configuration verification at ios2-rr"
rundeck_jobs -i jobs_stage2_verifications_ios4_vqfx3.yml -d stage2 -u 00000000-0000-0000-0000-000000000000 -o 303 -l debug -s "ios4: l3vpn configuration verification at vqfx3-rr"


rundeck_jobs -i jobs_stage2_verifications_connectivity.yml -d stage2 -u 00000000-0000-0000-0000-000000000000 -o 400 -l debug -s "end to end connectivity tests"

cp jobs_stage2-003.yml stage2/
cp jobs_stage2-100.yml stage2/
cp jobs_stage2-200.yml stage2/
cp jobs_stage2-300.yml stage2/


rm stage2/rundeck.jobs.yml
for f in stage2/*.yml
do
 cat $f >> stage2/rundeck.jobs.yml
done
cp stage2/rundeck.jobs.yml ../stage2/configs/



#stage 3
rm -rf stage3/

rundeck_jobs -i jobs_tests_ios1.yml -d stage3 -u 00000000-0000-0000-0000-000000000000 -o 401 -l debug -s "IOS1:_TROUBLESHOOTING_TESTS"
rundeck_jobs -i jobs_tests_ios2.yml -d stage3 -u 00000000-0000-0000-0000-000000000000 -o 402 -l debug -s "IOS2:_TROUBLESHOOTING_TESTS"
rundeck_jobs -i jobs_tests_ios4.yml -d stage3 -u 00000000-0000-0000-0000-000000000000 -o 403 -l debug -s "IOS4:_TROUBLESHOOTING_TESTS"
rm stage3/rundeck.jobs.yml

for f in stage3/*.yml
do
 cat $f >> stage3/rundeck.jobs.yml
done
cp stage3/rundeck.jobs.yml ../stage3/configs/
cp stage3/rundeck.jobs.yml ../stage4/configs/
cp stage3/rundeck.jobs.yml ../stage5/configs/
