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
Documentation     [EPA-01] EPA+SRIOV without underlay.

Library   OperatingSystem
Library   String
Library   Collections
Library   SSHLibrary

Resource   %{ROBOT_DEVOPS_FOLDER}/lib/vnfd_lib.robot
Resource   %{ROBOT_DEVOPS_FOLDER}/lib/nsd_lib.robot
Resource   %{ROBOT_DEVOPS_FOLDER}/lib/ns_lib.robot
Resource   %{ROBOT_DEVOPS_FOLDER}/lib/ssh_lib.robot

Variables   %{ROBOT_DEVOPS_FOLDER}/resources/epa_01-epa_sriov_data.py

Suite Teardown   Run Keyword And Ignore Error   Test Cleanup


*** Variables ***
${ns_id}   ${EMPTY}
${username}   ubuntu
${password}   osm4u
${vnf_member_index}   1
${vnf_ip_addr}   ${EMPTY}
${ns_config}   {vld: [ {name: mgmtnet, vim-network-name: %{VIM_MGMT_NET}} ] }


*** Test Cases ***
Create VNF Descriptor
    [Tags]   epa_sriov   sanity   regression

    Create VNFD  '%{PACKAGES_FOLDER}/${vnfd_pkg}'


Create NS Descriptor
    [Tags]   epa_sriov   sanity   regression

    Create NSD  '%{PACKAGES_FOLDER}/${nsd_pkg}'


Instantiate Network Service
    [Tags]   epa_sriov   sanity   regression

    ${id}=  Create Network Service  ${nsd_name}  %{VIM_TARGET}  ${ns_name}  ${ns_config}  ${publickey}
    Set Suite Variable  ${ns_id}  ${id}


Get VNF IP Address
    [Tags]   epa_sriov   sanity   regression

    ${ip_addr}=  Get Vnf Management Ip Address   ${ns_id}   ${vnf_member_index}
    log   ${ip_addr}
    Set Suite Variable   ${vnf_ip_addr}   ${ip_addr}


Check SR-IOV Interface
    [Tags]   epa_sriov   sanity   regression

    Sleep  30 seconds  Waiting for SSH daemon to be up
    Execute Remote Command Check Rc Return Output   ${vnf_ip_addr}   ${username}   ${password}   ${privatekey}   lspci | grep "Ethernet controller" | grep -v "Virtio"

Delete NS Instance
    [Tags]   epa_sriov   sanity   regression  cleanup

    Delete NS  ${ns_name}


Delete NS Descriptor
    [Tags]   epa_sriov   sanity   regression  cleanup

    Delete NSD  ${nsd_name}


Delete VNF Descriptor
    [Tags]   epa_sriov   sanity   regression  cleanup

    Delete VNFD  ${vnfd_name}


*** Keywords ***
Test Cleanup
    [Documentation]  Test Suite Cleanup: Deleting descriptors and NS instance

    Run Keyword If Test Failed  Delete NS  ${ns_name}

    Run Keyword If Test Failed  Delete NSD  ${nsd_name}

    Run Keyword If Test Failed  Delete VNFD  ${vnfd_name}

