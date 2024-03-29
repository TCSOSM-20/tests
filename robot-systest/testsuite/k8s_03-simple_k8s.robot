#   Copyright 2020 Canonical Ltd.
#
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
Resource   %{ROBOT_DEVOPS_FOLDER}/lib/package_lib.robot
Resource   %{ROBOT_DEVOPS_FOLDER}/lib/connectivity_lib.robot
Resource   %{ROBOT_DEVOPS_FOLDER}/lib/ssh_lib.robot
Resource   %{ROBOT_DEVOPS_FOLDER}/lib/k8scluster_lib.robot

Variables   %{ROBOT_DEVOPS_FOLDER}/resources/k8s_03-simple_k8s_data.py

Suite Teardown   Run Keyword And Ignore Error   Test Cleanup


*** Variables ***
${ns_id}   ${EMPTY}
${ns_config}   {vld: [ {name: mgmtnet, vim-network-name: %{VIM_MGMT_NET}} ] }
${publickey}   ${EMPTY}
${vnf_member_index}   native_k8s_charm-vnf
${action_name}   changecontent
${kdu_name}   native-kdu
${application_name}   nginx
${customtitle}   Day 2 Action

*** Test Cases ***
Create Simple K8s VNF Descriptor
    [Tags]   simple_k8s   charm   sanity   regression
    Upload Package   '%{PACKAGES_FOLDER}/${vnfd_pkg}'

Create Simple K8s Descriptor
    [Tags]   simple_k8s   charm   sanity   regression
    Upload Package   '%{PACKAGES_FOLDER}/${nsd_pkg}'

Add K8s Cluster To OSM
    [Tags]   simple_k8s   charm   sanity   regression
    Create K8s Cluster  %{K8S_CREDENTIALS}  ${k8scluster_version}  %{VIM_TARGET}  %{VIM_MGMT_NET}  ${k8scluster_name}

Network Service K8s Instance Test
    [Tags]   simple_k8s   charm   sanity   regression
    ${id}=   Create Network Service   ${nsd_name}   %{VIM_TARGET}   ${ns_name}   ${ns_config}  ${publickey}
    Set Suite Variable   ${ns_id}   ${id}

Execute Day 2 Operations
    [Documentation]     Performs one Day 2 operation per VNF that creates a new file.
    [Tags]   simple_k8s   charm   sanity   regression

    Variable Should Exist  ${ns_id}  msg=Network service instance is not available
    ${ns_op_id}=  Execute NS K8s Action  ${ns_name}  ${action_name}  ${vnf_member_index}  ${kdu_name}  application-name=${application_name}  customtitle=${customtitle}


Delete NS K8s Instance Test
    [Tags]   simple_k8s   charm   sanity   regression   cleanup
    Delete NS   ${ns_name}

Remove K8s Cluster from OSM
    [Tags]   simple_k8s   charm   sanity   regression
    Delete K8s Cluster  ${k8scluster_name}

Delete NS Descriptor Test
    [Tags]   simple_k8s   charm   sanity   regression   cleanup
    Delete NSD   ${nsd_name}

Delete VNF Descriptor Test
    [Tags]   simple_k8s   charm   sanity   regression   cleanup
    Delete VNFD   ${vnfd_name}

Delete VNF NS Packages
    [Tags]   simple_k8s   charm   sanity   regression   cleanup
    Delete Package   '%{PACKAGES_FOLDER}/${vnfd_pkg}'
    Delete Package   '%{PACKAGES_FOLDER}/${nsd_pkg}'


*** Keywords ***
Test Cleanup
    [Documentation]  Test Suit Cleanup: Deleting Descriptor, instance and vim
    Run Keyword If Test Failed  Delete NS   ${ns_name}
    Run Keyword If Test Failed  Delete NSD   ${nsd_name}
    Run Keyword If Test Failed  Delete VNFD   ${vnfd_name}
    Run Keyword If Test Failed  Delete K8s Cluster   ${k8scluster_name}
