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
Create User
    [Arguments]   ${user_name}   ${user_password}

    Should Not Be Empty   ${user_name}
    Should Not Be Empty   ${user_password}
    ${rc}   ${stdout}=   Run and Return RC and Output   osm user-create ${user_name} --password ${user_password}
    Log   ${stdout}
    Should Be Equal As Integers   ${rc}   ${success_return_code}
    [Return]  ${stdout}


Update User Role
    [Arguments]   ${user_name}   ${project_name}   ${role_name}

    Should Not Be Empty   ${user_name}
    Should Not Be Empty   ${project_name}
    Should Not Be Empty   ${role_name}
    ${rc}   ${stdout}=   Run and Return RC and Output   osm user-update --add-project-role '${project_name},${role_name}' ${user_name}
    Log   ${stdout}
    Should Be Equal As Integers   ${rc}   ${success_return_code}


Check If User Exists
    [Arguments]  ${user_name}

    Should Not Be Empty   ${user_name}
    ${rc}   ${stdout}=   Run And Return RC And Output   osm user-list | awk 'NR>3 {print $2}' | grep "${user_name}"
    Log   ${stdout}
    Should Be Equal As Integers   ${rc}   ${success_return_code}


Delete User
    [Arguments]  ${user_name}

    ${rc}   ${stdout}=   Run and Return RC and Output   osm user-delete ${user_name}
    Log   ${stdout}
    Should Be Equal As Integers   ${rc}   ${success_return_code}
