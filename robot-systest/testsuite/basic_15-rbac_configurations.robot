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
Documentation     [BASIC-15] RBAC Configurations.

Library   OperatingSystem
Library   String
Library   Collections

Resource   %{ROBOT_DEVOPS_FOLDER}/lib/user_lib.robot
Resource   %{ROBOT_DEVOPS_FOLDER}/lib/project_lib.robot
Resource   %{ROBOT_DEVOPS_FOLDER}/lib/role_lib.robot

Variables   %{ROBOT_DEVOPS_FOLDER}/resources/basic_15-rbac_configurations_data.py

Suite Teardown   Run Keyword And Ignore Error   Test Cleanup


*** Variables ***
${success_return_code}   0

*** Test Cases ***
Create And Validate User
    [Tags]   rbac_configurations   sanity   regression

    Create User   ${user_name}   ${user_password}
    Check If User Exists   ${user_name}


Assign Role To User
    [Tags]   rbac_configurations   sanity   regression

    Update User Role   ${user_name}  ${user_project}  ${user_role}
    Check If User Is Assigned To Project   ${user_name}   ${user_project}
    Check If User Has Role   ${user_name}  ${user_role}  ${user_project}


Run Action As User
    [Tags]   rbac_configurations   sanity   regression

    ${rc}   ${stdout}=   Run And Return RC And Output   OSM_USER=${user_name} OSM_PROJECT=${user_project} OSM_PASSWORD=${user_password} osm ns-list
    Should Be Equal As Integers   ${rc}   ${success_return_code}


Create And Update Project
    [Tags]   rbac_configurations   sanity   regression

    Create Project   ${project_name}
    Update Project Name   ${project_name}   ${new_project_name}


Create And Validate Role
    [Tags]   rbac_configurations   sanity   regression

    Create Role   ${role_name}
    Check If Role Exists   ${role_name}


Update Role Information
    [Tags]   rbac_configurations   sanity   regression

    Update Role   ${role_name}   add='vims: true'
    Check If Role Exists   ${role_name}


Delete Allocated Resources
    [Tags]   rbac_configurations   sanity   regression  cleanup

    Delete User   ${user_name}
    Delete Project   ${new_project_name}
    Delete Role   ${role_name}


*** Keywords ***
Test Cleanup
    Run Keyword If Test Failed  Run Keyword And Ignore Error  Delete User  ${user_name}
    Run Keyword If Test Failed  Run Keyword And Ignore Error  Delete Role  ${role_name}
    Run Keyword If Test Failed  Run Keyword And Ignore Error  Delete Project  ${project_name}
    Run Keyword If Test Failed  Run Keyword And Ignore Error  Delete Project  ${new_project_name}
