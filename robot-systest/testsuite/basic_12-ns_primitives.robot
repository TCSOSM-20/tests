#   Copyright 2020 Canonical Ltd.
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
Library   OperatingSystem
Library   String
Library   Collections
Library   Process

Resource   %{ROBOT_DEVOPS_FOLDER}/lib/vnfd_lib.robot
Resource   %{ROBOT_DEVOPS_FOLDER}/lib/nsd_lib.robot
Resource   %{ROBOT_DEVOPS_FOLDER}/lib/ns_lib.robot
Resource   %{ROBOT_DEVOPS_FOLDER}/lib/packages_lib.robot

Variables   %{ROBOT_DEVOPS_FOLDER}/resources/basic_12-ns_primitives_data.py

Suite Teardown   Run Keyword And Ignore Error   Test Cleanup


*** Variables ***
${ns_config}   {vld: [ {name: mgmtnet, vim-network-name: %{VIM_MGMT_NET}} ] }
${publickey}   ${EMPTY}

*** Test Cases ***
Change Juju Password

    [Documentation]  NS package needs to be updated with the Juju credentials for your OSM installation

    [Tags]   nsprimitives   charm   sanity   regression

    ${nsd_yaml}=   Get File  %{PACKAGES_FOLDER}${nsd_pkg}/${nsd_file}
    ${changed_nsd_yaml}=   Replace String  ${nsd_yaml}  ${old_juju_password}  %{JUJU_PASSWORD}
    Create File  %{PACKAGES_FOLDER}${nsd_pkg}/${nsd_file}  ${changed_nsd_yaml}

Create NS Package

    [Tags]   nsprimitives   charm   sanity   regression

    ${pkg}=  Package Build  '%{PACKAGES_FOLDER}${nsd_pkg}'
    Log   ${pkg}
    Set Suite Variable  ${ns_pkg}  ${pkg}


Upload Vnfds

    [Tags]   nsprimitives   charm   sanity   regression

    Create VNFD   '%{PACKAGES_FOLDER}${vnfd_pkg1}'
    Create VNFD   '%{PACKAGES_FOLDER}${vnfd_pkg2}'

Upload Nsd

    [Tags]   nsprimitives   charm   sanity   regression

    Create NSD  '${ns_pkg}'

Instantiate NS

    [Tags]   nsprimitives   charm   sanity   regression

    ${id}=  Create Network Service  ${nsd_name}  %{VIM_TARGET}  ${ns_name}  ${ns_config}  ${publickey}  ns_launch_max_wait_time=40min
    Set Suite Variable  ${ns_id}  ${id}

# TODO: Check Initial Config Primitives Status

Delete NS 

    [Tags]   nsprimitives   charm   sanity   regression   cleanup

    Delete NS   ${ns_name}

Delete NS Descriptor

    [Tags]   nsprimitives   charm   sanity   regression   cleanup

    Delete NSD   ${nsd_name}

Delete VNF Descriptors

    [Tags]   nsprimitives   charm   sanity   regression   cleanup

    Delete VNFD   ${vnfd_name1}
    Delete VNFD   ${vnfd_name2}


*** Keywords ***
Test Cleanup
    [Documentation]  Test Suit Cleanup: Deleting Descriptor and instance

    Run Keyword If Test Failed  Delete NS   ${ns_name}
    Run Keyword If Test Failed  Delete NSD   ${nsd_name}
    Run Keyword If Test Failed  Delete VNFD   ${vnfd_name1}
    Run Keyword If Test Failed  Delete VNFD   ${vnfd_name2}
