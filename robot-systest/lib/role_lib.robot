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

*** Variables ***
${success_return_code}   0


*** Keywords ***
Create Role
    [Arguments]   ${role_name}

    Should Not Be Empty   ${role_name}
    ${rc}   ${stdout}=   Run and Return RC and Output   osm role-create ${role_name}
    Log   ${stdout}
    Should Be Equal As Integers   ${rc}   ${success_return_code}
    [Return]  ${stdout}


Update Role
    [Documentation]     Updates a role in OSM.
    ...                 The extra parameters (like '--add') are given to this function in name=value format. These parameters will be appended to the 'osm role-update' command with the next syntax: --param_name=param_value
    ...                 Example of execution:
    ...                     Update Role  \${role_name}  add='vims: true'

    [Arguments]  ${role_name}  @{optional_parameters}

    ${osm_update_command}=  Set Variable  osm role-update ${role_name}
    FOR  ${param}  IN  @{optional_parameters}
        ${match}  ${param_name}  ${param_value} =  Should Match Regexp  ${param}  (.+)=(.+)  msg=Syntax error in optional parameters
        ${osm_update_command}=  Catenate  ${osm_update_command}  --${param_name}=${param_value}
    END
    ${rc}  ${stdout}=  Run and Return RC and Output  ${osm_update_command}
    log  ${stdout}
    Should Be Equal As Integers  ${rc}  ${success_return_code}


Check If Role Exists
    [Arguments]  ${role_name}

    Should Not Be Empty   ${role_name}
    ${rc}   ${stdout}=   Run And Return RC And Output   osm role-list | awk 'NR>3 {print $2}' | grep "${role_name}"
    Log   ${stdout}
    Should Be Equal As Integers   ${rc}   ${success_return_code}


Check If User Has Role
    [Arguments]  ${user_name}  ${role_name}  ${project_name}

    Should Not Be Empty   ${user_name}
    Should Not Be Empty   ${role_name}
    Should Not Be Empty   ${project_name}
    ${rc}   ${stdout}=   Run And Return RC And Output   osm user-show ${user_name} | grep -B1 "role_name" | grep -B1 "${role_name}" | grep "project_name" | grep "${project_name}"
    Log   ${stdout}
    Should Be Equal As Integers   ${rc}   ${success_return_code}


Delete Role
    [Arguments]  ${role_name}

    ${rc}   ${stdout}=   Run and Return RC and Output   osm role-delete ${role_name}
    Log   ${stdout}
    Should Be Equal As Integers   ${rc}   ${success_return_code}
