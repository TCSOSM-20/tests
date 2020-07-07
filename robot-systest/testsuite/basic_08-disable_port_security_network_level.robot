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
Documentation     [BASIC-08] Disable port security at network level.

Library   OperatingSystem
Library   String
Library   Collections

Resource   %{ROBOT_DEVOPS_FOLDER}/lib/vim_lib.robot
Resource   %{ROBOT_DEVOPS_FOLDER}/lib/vnfd_lib.robot
Resource   %{ROBOT_DEVOPS_FOLDER}/lib/nsd_lib.robot
Resource   %{ROBOT_DEVOPS_FOLDER}/lib/ns_lib.robot
Resource   %{ROBOT_DEVOPS_FOLDER}/lib/prometheus_lib.robot

Variables   %{ROBOT_DEVOPS_FOLDER}/resources/basic_08-disable_port_security_network_level_data.py

Suite Teardown   Run Keyword And Ignore Error   Test Cleanup


*** Variables ***
${ns_config}   {vld: [ {name: mgmtnet, vim-network-name: %{VIM_MGMT_NET}} ] }
${port_disabled_msg}   port_security_enabled: false

*** Test Cases ***
Create VIM With Port Security Disabled
    [Tags]  disable_port_security  sanity   regression

    ${created_vim_account_id}=  Create VIM Target  ${vim_name}  ${vim_user}  ${vim_password}  ${vim_auth_url}  ${vim_tenant}  ${vim_account_type}  config=${vim_config}
    Check for VIM Target Status  ${vim_name}  ${prometheus_host}  ${prometheus_port}

Create VNF Descriptor
    [Tags]   disable_port_security   sanity   regression

    Create VNFD  '%{PACKAGES_FOLDER}/${vnfd_pkg}'


Create NS Descriptor
    [Tags]   disable_port_security   sanity   regression

    Create NSD  '%{PACKAGES_FOLDER}/${nsd_pkg}'


Instantiate Network Service
    [Tags]   disable_port_security   sanity   regression

    ${id}=  Create Network Service  ${nsd_name}  ${vim_name}  ${ns_name}  ${ns_config}  ${publickey}
    Set Suite Variable  ${ns_id}  ${id}


Check Port Security Is Disabled
    [Tags]   disable_port_security   sanity   regression

    ${rc}   ${disabled_ports}=   Run and Return RC and Output   osm ns-show ${ns_name} | grep -c '${port_disabled_msg}'
    Run Keyword Unless  ${disabled_ports} > 6  Fail  msg=Found only '${disabled_ports}' matches for '${port_disabled_msg}'


Delete NS Instance
    [Tags]   disable_port_security   sanity   regression  cleanup

    Delete NS  ${ns_name}


Delete NS Descriptor
    [Tags]   disable_port_security   sanity   regression  cleanup

    Delete NSD  ${nsd_name}


Delete VNF Descriptor
    [Tags]   disable_port_security   sanity   regression  cleanup

    Delete VNFD  ${vnfd_name}


Delete VIM
    [Tags]  disable_port_security  sanity   regression  cleanup

    Delete VIM Target  ${vim_name}


*** Keywords ***
Test Cleanup
    [Documentation]  Test Suite Cleanup: Deleting descriptors and NS instance

    Run Keyword If Test Failed  Delete NS  ${ns_name}
    Run Keyword If Test Failed  Delete NSD  ${nsd_name}
    Run Keyword If Test Failed  Delete VNFD  ${vnfd_name}
    Run Keyword If Test Failed  Delete VIM Target  ${vim_name}
