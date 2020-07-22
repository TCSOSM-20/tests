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
Create Project
    [Arguments]   ${project_name}

    Should Not Be Empty   ${project_name}
    ${rc}   ${stdout}=   Run and Return RC and Output   osm project-create ${project_name}
    Log   ${stdout}
    Should Be Equal As Integers   ${rc}   ${success_return_code}
    [Return]  ${stdout}


Create Project With Quotas
    [Arguments]   ${project_name}   ${project_quotas}

    Should Not Be Empty   ${project_name}
    Should Not Be Empty   ${project_quotas}
    ${rc}   ${stdout}=   Run and Return RC and Output   osm project-create ${project_name} --quotas ${project_quotas}
    Log   ${stdout}
    Should Be Equal As Integers   ${rc}   ${success_return_code}
    [Return]  ${stdout}


Get Project Quotas
    [Arguments]   ${project_name}   ${quotas_name}

    Should Not Be Empty   ${project_name}
    Should Not Be Empty   ${quotas_name}
    ${rc}   ${stdout}=   Run and Return RC and Output   osm project-show ${project_name} | grep '${quotas_name}' | awk -F ',|: ' '{print $2}' | awk '{print $1}'
    Log   ${stdout}
    Should Be Equal As Integers   ${rc}   ${success_return_code}
    [Return]  ${stdout}


Update Project Quotas
    [Arguments]   ${project_name}   ${project_quotas}

    Should Not Be Empty   ${project_name}
    Should Not Be Empty   ${project_quotas}
    ${rc}   ${stdout}=   Run and Return RC and Output   osm project-update ${project_name} --quotas ${project_quotas}
    Log   ${stdout}
    Should Be Equal As Integers   ${rc}   ${success_return_code}


Update Project Name
    [Arguments]   ${project_name}   ${new_name}

    Should Not Be Empty   ${project_name}
    Should Not Be Empty   ${new_name}
    ${rc}   ${stdout}=   Run and Return RC and Output   osm project-update ${project_name} --name ${new_name}
    log   ${stdout}
    Should Be Equal As Integers   ${rc}   ${success_return_code}


Check If User Is Assigned To Project
    [Arguments]  ${user_name}  ${project_name}

    Should Not Be Empty   ${user_name}
    Should Not Be Empty   ${project_name}
    ${rc}   ${stdout}=   Run And Return RC And Output   osm user-show ${user_name} | grep "project_name" | grep "${project_name}"
    Log   ${stdout}
    Should Be Equal As Integers   ${rc}   ${success_return_code}


Create VNFD In Project
    [Documentation]     Onboards a VNFD package into an OSM project.
    ...                 Extra parameters (such as 'override') are given to this function in name=value format. These parameters will be appended to the 'osm vnfpkg-create' command with the next syntax: --param_name=param_value

    [Arguments]   ${project_name}   ${vnfd_pkg}   ${project_user}   ${user_password}   @{optional_parameters}

    Should Not Be Empty   ${project_name}
    Should Not Be Empty   ${vnfd_pkg}
    Should Not Be Empty   ${project_user}
    Should Not Be Empty   ${user_password}

    ${osm_pkg_create_command}=  Set Variable  osm --project ${project_name} --user ${project_user} --password ${user_password} vnfpkg-create ${vnfd_pkg}
    FOR  ${param}  IN  @{optional_parameters}
        ${match}  ${param_name}  ${param_value} =  Should Match Regexp  ${param}  (.+)=(.+)  msg=Syntax error in optional parameters
        ${osm_pkg_create_command}=  Catenate  ${osm_pkg_create_command}  --${param_name}=${param_value}
    END

    ${rc}   ${stdout}=   Run and Return RC and Output   ${osm_pkg_create_command}
    Log   ${stdout}
    Should Be Equal As Integers   ${rc}   ${success_return_code}
    [Return]  ${stdout}


Delete VNFD In Project
    [Arguments]   ${project_name}   ${vnfd_pkg}   ${project_user}   ${user_password}

    Should Not Be Empty   ${project_name}
    Should Not Be Empty   ${vnfd_pkg}
    Should Not Be Empty   ${project_user}
    Should Not Be Empty   ${user_password}
    ${rc}   ${stdout}=   Run and Return RC and Output   osm --project ${project_name} --user ${project_user} --password ${user_password} vnfpkg-delete ${vnfd_pkg}
    Log   ${stdout}
    Should Be Equal As Integers   ${rc}   ${success_return_code}


Remove User From Project
    [Arguments]  ${user_name}  ${project_name}

    Should Not Be Empty   ${user_name}
    Should Not Be Empty   ${project_name}
    ${rc}   ${stdout}=   Run And Return RC And Output   osm user-update ${user_name} --remove-project ${project_name}
    Log   ${stdout}
    Should Be Equal As Integers   ${rc}   ${success_return_code}


Delete Project
    [Arguments]  ${project_name}

    ${rc}   ${stdout}=   Run and Return RC and Output   osm project-delete ${project_name}
    Log   ${stdout}
    Should Be Equal As Integers   ${rc}   ${success_return_code}
