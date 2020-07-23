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
Documentation     [BASIC-14] VNF Relations

Library   OperatingSystem
Library   SSHLibrary

Resource   %{ROBOT_DEVOPS_FOLDER}/lib/vnfd_lib.robot
Resource   %{ROBOT_DEVOPS_FOLDER}/lib/nsd_lib.robot
Resource   %{ROBOT_DEVOPS_FOLDER}/lib/ns_lib.robot
Resource   %{ROBOT_DEVOPS_FOLDER}/lib/ssh_lib.robot
Resource   %{ROBOT_DEVOPS_FOLDER}/lib/juju_lib.robot

Variables   %{ROBOT_DEVOPS_FOLDER}/resources/basic_14-vnf_relations.py

Suite Teardown   Run Keyword And Ignore Error   Test Cleanup


*** Variables ***
${username}   ubuntu
${password}   ${EMPTY}
${ns_config}   {vld: [ {name: mgmtnet, vim-network-name: %{VIM_MGMT_NET}} ] }
${action_name}   touch
${vnf_member_index_1}   1
${vnf_member_index_2}   2
${day_1_file_name}   /home/ubuntu/first-touch
${day_2_file_name_1}   /home/ubuntu/mytouch1
${day_2_file_name_2}   /home/ubuntu/mytouch2
${ns_timeout}   15min


*** Test Cases ***
Create Charm VNF Descriptor
    [Tags]   vnf_relations   charm   sanity   regression

    Create VNFD  '%{PACKAGES_FOLDER}/${vnfd_pkg}'


Create Charm NS Descriptor
    [Tags]   vnf_relations   charm   sanity   regression

    Create NSD  '%{PACKAGES_FOLDER}/${nsd_pkg}'


Instantiate Charm Network Service
    [Tags]   vnf_relations   charm   sanity   regression

    ${id}=  Create Network Service  ${nsd_name}  %{VIM_TARGET}  ${ns_name}  ${ns_config}  ${publickey}  ${ns_timeout}
    Set Suite Variable  ${ns_id}  ${id}


# TODO Check juju status for relations


Delete NS Instance
    [Tags]   vnf_relations   charm   sanity   regression  cleanup

    Delete NS  ${ns_name}


Delete NS Descriptor
    [Tags]   vnf_relations   charm   sanity   regression  cleanup

    Delete NSD  ${nsd_name}


Delete VNF Descriptor Provides
    [Tags]   vnf_relations   charm   sanity   regression  cleanup

    Delete VNFD  ${vnfd_name}


*** Keywords ***
Test Cleanup
    [Documentation]  Test Suite Cleanup: Deleting descriptors and NS instance

    Run Keyword If Test Failed  Delete NS  ${ns_name}

    Run Keyword If Test Failed  Delete NSD  ${nsd_name}

    Run Keyword If Test Failed  Delete VNFD  ${vnfd_name}

