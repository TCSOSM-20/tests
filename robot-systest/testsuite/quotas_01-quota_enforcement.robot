#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

*** Settings ***
Documentation     [QUOTAS-01] Quota enforcement.

Library   OperatingSystem
Library   String
Library   Collections

Resource   %{ROBOT_DEVOPS_FOLDER}/lib/project_lib.robot

Variables   %{ROBOT_DEVOPS_FOLDER}/resources/quotas_01-quota_enforcement_data.py

Suite Teardown   Run Keyword And Ignore Error   Test Cleanup


*** Variables ***
${success_return_code}   0
${project_1_quotas}   vnfds=1,nsds=2,ns_instances=3
${project_2_quotas}   vnfds=1,nsds=1,ns_instances=1
${project_3_quotas}   vnfds=5,nsds=,ns_instances=
${vnfd_pkg}   %{PACKAGES_FOLDER}/${vnfd_name}

*** Test Cases ***
Create First Project With Quotas
    [Tags]   quota_enforcement   sanity   regression

    Create Project With Quotas   ${project_1_name}   ${project_1_quotas}
    ${project_1_vnfds}=   Get Project Quotas   ${project_1_name}   vnfds
    Should Be Equal As Integers   1   ${project_1_vnfds}
    ${project_1_nsds}=   Get Project Quotas   ${project_1_name}   nsds
    Should Be Equal As Integers   2   ${project_1_nsds}
    ${project_1_ns_instances}=   Get Project Quotas   ${project_1_name}   ns_instances
    Should Be Equal As Integers   3   ${project_1_ns_instances}


Create Second Project With Quotas
    [Tags]   quota_enforcement   sanity   regression

    Create Project With Quotas   ${project_2_name}   ${project_2_quotas}
    ${project_2_vnfds}=   Get Project Quotas   ${project_2_name}   vnfds
    Should Be Equal As Integers   1   ${project_2_vnfds}
    ${project_2_nsds}=   Get Project Quotas   ${project_2_name}   nsds
    Should Be Equal As Integers   1   ${project_2_nsds}
    ${project_2_ns_instances}=   Get Project Quotas   ${project_2_name}   ns_instances
    Should Be Equal As Integers   1   ${project_2_ns_instances}

Create User In Projects
    [Tags]   quota_enforcement   sanity   regression

    ${rc}   ${stdout}=   Run And Return RC And Output   osm user-create ${user_name} --password ${user_password} --project-role-mappings ${project_1_name},project_admin --project-role-mappings ${project_2_name},project_admin
    Should Be Equal As Integers   ${rc}   ${success_return_code}
    Check If User Is Assigned To Project   ${user_name}   ${project_1_name}
    Check If User Is Assigned To Project   ${user_name}   ${project_2_name}


Change First Project Name to Third Project Name
    [Tags]   quota_enforcement   sanity   regression

    Update Project Name   ${project_1_name}   ${project_3_name}
    ${project_3_vnfds}=   Get Project Quotas   ${project_3_name}   vnfds
    Should Be Equal As Integers   1   ${project_3_vnfds}
    ${project_3_nsds}=   Get Project Quotas   ${project_3_name}   nsds
    Should Be Equal As Integers   2   ${project_3_nsds}
    ${project_3_ns_instances}=   Get Project Quotas   ${project_3_name}   ns_instances
    Should Be Equal As Integers   3   ${project_3_ns_instances}
    Check If User Is Assigned To Project   ${user_name}   ${project_3_name}


Create VNFDs On Third Project Until Exceed Quota
    [Tags]   quota_enforcement   sanity   regression

    Create VNFD In Project   ${project_3_name}   ${vnfd_pkg}   ${user_name}   ${user_password}  override='id=v1;name=v1'
    Run Keyword And Expect Error  *  Create VNFD In Project   ${project_3_name}   ${vnfd_pkg}   ${user_name}   ${user_password}  override='id=v2;name=v2'


Increase Third Project Quotas
    [Tags]   quota_enforcement   sanity   regression

    Update Project Quotas   ${project_3_name}   ${project_3_quotas}
    ${project_3_vnfds}=   Get Project Quotas   ${project_3_name}   vnfds
    Should Be Equal As Integers   5   ${project_3_vnfds}


Create More VNFDs On Third Project Until Exceed Quota
    [Tags]   quota_enforcement   sanity   regression

    Create VNFD In Project   ${project_3_name}   ${vnfd_pkg}   ${user_name}   ${user_password}  override='id=v2;name=v2'
    Create VNFD In Project   ${project_3_name}   ${vnfd_pkg}   ${user_name}   ${user_password}  override='id=v3;name=v3'
    Create VNFD In Project   ${project_3_name}   ${vnfd_pkg}   ${user_name}   ${user_password}  override='id=v4;name=v4'
    Create VNFD In Project   ${project_3_name}   ${vnfd_pkg}   ${user_name}   ${user_password}  override='id=v5;name=v5'
    Run Keyword And Expect Error  *  Create VNFD In Project   ${project_3_name}   ${vnfd_pkg}   ${user_name}   ${user_password}  override='id=v6;name=v6'


Create VNFDs On Second Project Until Exceed Quota
    [Tags]   quota_enforcement   sanity   regression

    Create VNFD In Project   ${project_2_name}   ${vnfd_pkg}   ${user_name}   ${user_password}  override='id=vp2_1;name=vp2_1'
    Run Keyword And Expect Error  *  Create VNFD In Project   ${project_2_name}   ${vnfd_pkg}   ${user_name}   ${user_password}  override='id=vp2_2;name=vp2_2'


Check Project Scopes
    [Tags]   quota_enforcement   sanity   regression

    ${rc}   ${stdout}=   Run And Return RC And Output   osm --project ${project_3_name} --password ${user_password} --user ${user_name} vnfpkg-show vp2_1
    Log   ${stdout}
    Should Not Be Equal As Integers   ${rc}   ${success_return_code}
    ${rc}   ${stdout}=   Run And Return RC And Output   osm --project ${project_2_name} --password ${user_password} --user ${user_name} vnfpkg-show v1
    Log   ${stdout}
    Should Not Be Equal As Integers   ${rc}   ${success_return_code}


Delete Second Project VNFD
    [Tags]   quota_enforcement   sanity   regression  cleanup

    Delete VNFD In Project  ${project_2_name}   vp2_1   ${user_name}   ${user_password}


Delete Third Project VNFDs
    [Tags]   quota_enforcement   sanity   regression  cleanup

    Delete VNFD In Project  ${project_3_name}   v1   ${user_name}   ${user_password}
    Delete VNFD In Project  ${project_3_name}   v2   ${user_name}   ${user_password}
    Delete VNFD In Project  ${project_3_name}   v3   ${user_name}   ${user_password}
    Delete VNFD In Project  ${project_3_name}   v4   ${user_name}   ${user_password}
    Delete VNFD In Project  ${project_3_name}   v5   ${user_name}   ${user_password}


Delete Second Project After Removing User From It
    [Tags]   quota_enforcement   sanity   regression  cleanup

    Run Keyword And Expect Error  *  Delete Project  ${project_2_name}
    Remove User From Project  ${user_name}  ${project_2_name}
    Delete Project  ${project_2_name}


Delete Projects User
    [Tags]   quota_enforcement   sanity   regression  cleanup

    ${rc}=   Run And Return RC   osm user-delete ${user_name}


Delete Third Project
    [Tags]   quota_enforcement   sanity   regression  cleanup

    Delete Project  ${project_3_name}


*** Keywords ***
Test Cleanup
    Run Keyword If Test Failed  Run Keyword And Ignore Error  Delete VNFD In Project  ${project_2_name}   vp2_1   ${user_name}   ${user_password}
    Run Keyword If Test Failed  Run Keyword And Ignore Error  Delete VNFD In Project  ${project_3_name}   v1   ${user_name}   ${user_password}
    Run Keyword If Test Failed  Run Keyword And Ignore Error  Delete VNFD In Project  ${project_3_name}   v2   ${user_name}   ${user_password}
    Run Keyword If Test Failed  Run Keyword And Ignore Error  Delete VNFD In Project  ${project_3_name}   v3   ${user_name}   ${user_password}
    Run Keyword If Test Failed  Run Keyword And Ignore Error  Delete VNFD In Project  ${project_3_name}   v4   ${user_name}   ${user_password}
    Run Keyword If Test Failed  Run Keyword And Ignore Error  Delete VNFD In Project  ${project_3_name}   v5   ${user_name}   ${user_password}
    Run Keyword If Test Failed  Run Keyword And Ignore Error  Delete Project  ${project_1_name}
    Run Keyword If Test Failed  Delete Project  ${project_2_name}
    Run Keyword If Test Failed  Run Keyword And Ignore Error  Delete Project  ${project_3_name}
    Run And Return RC   osm user-delete ${user_name}
