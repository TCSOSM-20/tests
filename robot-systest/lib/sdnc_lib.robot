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
Documentation     Library to manage SDNCs.

Library   String
Library   Collections
Library   OperatingSystem

Resource   %{ROBOT_DEVOPS_FOLDER}/lib/prometheus_lib.robot


*** Variables ***
${success_return_code}   0
${delete_max_wait_time}   1min
${delete_pol_time}   15sec
${sdnc_status_max_wait_time}   6min
${sdnc_status_pol_time}   1min


*** Keywords ***
Create SDNC
    [Documentation]     Creates an SDNC in OSM.
    ...                 The optional parameters (such as 'switch_dpid' or 'ip-address') are given to this function in name=value format. These parameters will be appended to the 'osm sdnc-create' command with the next syntax: --param_name=param_value
    ...                 Returns the ID of the created SDNC Target.
    ...                 Example of execution:
    ...                     \${sdnc_id}=  Create SDNC  \${sdnc_name}  \${sdnc_user}  \${sdnc_password}  \${sdnc_url}  \${sdnc_type}  switch_dpid='{...}'

    [Arguments]  ${sdcn_name}  ${sdnc_user}  ${sdnc_password}  ${sdnc_url}  ${sdnc_type}  @{optional_parameters}

    ${osm_sdnc_create_command}=  Set Variable  osm sdnc-create --name ${sdnc_name} --user ${sdnc_user} --password ${sdnc_password} --url ${sdnc_url} --type ${sdnc_type}
    FOR  ${param}  IN  @{optional_parameters}
        ${match}  ${param_name}  ${param_value} =  Should Match Regexp  ${param}  (.+)=(.+)  msg=Syntax error in optional parameters
        ${osm_sdnc_create_command}=  Catenate  ${osm_sdnc_create_command}  --${param_name}=${param_value}
    END
    ${rc}  ${stdout}=  Run and Return RC and Output  ${osm_sdnc_create_command}
    log  ${stdout}
    Should Be Equal As Integers  ${rc}  ${success_return_code}
    [Return]  ${stdout}


Delete SDNC
    [Arguments]   ${sdnc_name}

    ${rc}  ${stdout}=  Run Keyword And Continue On Failure  Run and Return RC and Output  osm sdnc-delete ${sdnc_name}
    log  ${stdout}
    Wait Until Keyword Succeeds  ${delete_max_wait_time}  ${delete_pol_time}  Check for SDNC  ${sdnc_name}


Get SDNC List
    ${rc}  ${stdout}=  Run and Return RC and Output  osm sdnc-list
    log  ${stdout}
    Should Be Equal As Integers  ${rc}  ${success_return_code}


Check for SDNC
    [Arguments]  ${sdnc_name}

    ${rc}  ${stdout}=  Run and Return RC and Output  osm sdnc-list | awk '{print $2}' | grep ${sdnc_name}
    Should Be Equal As Strings  ${stdout}  ${sdnc_name}


Check for SDNC Status
    [Arguments]  ${sdnc_name}  ${prometheus_host}  ${prometheus_port}

    ${sdnc_id}=  Get SDNC ID  ${sdnc_name}
    Wait Until Keyword Succeeds  ${sdnc_status_max_wait_time}  ${sdnc_status_pol_time}  Check If SDNC Is Available  ${sdnc_id}  ${prometheus_host}  ${prometheus_port}


Get SDNC ID
    [Arguments]  ${sdnc_name}

    ${rc}  ${stdout}=  Run and Return RC and Output  osm sdnc-list | grep " ${sdnc_name} " | awk '{print $4}'
    Should Be Equal As Integers  ${rc}  ${success_return_code}
    Should Not Be Equal As Strings  ${stdout}  ${EMPTY}  msg=SDNC '${sdnc_name}' not found  values=false
    [Return]  ${stdout}


Check If SDNC Is Available
    [Arguments]  ${sdnc_id}  ${prometheus_host}  ${prometheus_port}

    ${metric}=  Get Metric  ${prometheus_host}  ${prometheus_port}  osm_sdnc_status  sdnc_id=${sdnc_id}
    Should Be Equal As Integers  ${metric}  0  msg=SDNC '${sdnc_id}' is not active  values=false
