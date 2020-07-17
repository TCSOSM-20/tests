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
Library   SSHLibrary
Library   %{ROBOT_DEVOPS_FOLDER}/lib/renderTemplate.py

Resource   %{ROBOT_DEVOPS_FOLDER}/lib/vnfd_lib.robot
Resource   %{ROBOT_DEVOPS_FOLDER}/lib/nsd_lib.robot
Resource   %{ROBOT_DEVOPS_FOLDER}/lib/ns_lib.robot
Resource   %{ROBOT_DEVOPS_FOLDER}/lib/ssh_lib.robot

Variables   %{ROBOT_DEVOPS_FOLDER}/resources/k8s_01-create_k8s_cluster_data.py

Suite Teardown   Run Keyword And Ignore Error   Test Cleanup


*** Variables ***
${username}   ubuntu
${password}   ${EMPTY}


*** Test Cases ***
Render a template
    [Tags]   newK8sCluster   regression

    ${stdout}=    Render template   %{ROBOT_DEVOPS_FOLDER}/resources/${template}  %{ROBOT_DEVOPS_FOLDER}/resources/${config_file}  IP_VM1=%{IP_VM1}  IP_VM2=%{IP_VM2}  IP_VM3=%{IP_VM3}  IP_VM4=%{IP_VM4}  IP_JUJU=%{IP_JUJU}  NETWORK=%{VIM_MGMT_NET}
    Log To Console  \n${stdout}

Create Controller VNF Descriptor
    [Tags]  newK8sCluster   regression

    Create VNFD  '%{PACKAGES_FOLDER}/${vnfd_pkg1}'

Create Machines VNF Descriptor
    [Tags]  newK8sCluster   regression

    Create VNFD  '%{PACKAGES_FOLDER}/${vnfd_pkg2}'

Create K8s Cluster NS Descriptor
    [Tags]  newK8sCluster   regression

    Create NSD  '%{PACKAGES_FOLDER}/${nsd_pkg}'

Instantiate K8s Cluster Network Service
    [Tags]  newK8sCluster   regression

    ${id}=  Create Network Service  ${nsd_name}  %{VIM_TARGET}  ${ns_name}  ns_config=${EMPTY}  publickey=${publickey}  ns_launch_max_wait_time=70min  config_file=%{ROBOT_DEVOPS_FOLDER}/resources/${config_file}  
    Set Suite Variable  ${ns_id}  ${id}

Get Management Ip Addresses
    [Tags]  newK8sCluster   regression

    ${ip_addr_1}  Get Vnf Management Ip Address  ${ns_id}  ${vnf_member_index_1}
    log  ${ip_addr_1}
    Set Suite Variable  ${vnf_1_ip_addr}  ${ip_addr_1}
    ${ip_addr_2}  Get Vnf Management Ip Address  ${ns_id}  ${vnf_member_index_2}
    log  ${ip_addr_2}
    Set Suite Variable  ${vnf_2_ip_addr}  ${ip_addr_2}
    ${ip_addr_3}  Get Vnf Management Ip Address  ${ns_id}  ${vnf_member_index_3}
    log  ${ip_addr_3}
    Set Suite Variable  ${vnf_3_ip_addr}  ${ip_addr_3}
    ${ip_addr_4}  Get Vnf Management Ip Address  ${ns_id}  ${vnf_member_index_4}
    log  ${ip_addr_4}
    Set Suite Variable  ${vnf_4_ip_addr}  ${ip_addr_4}
    ${ip_addr_5}  Get Vnf Management Ip Address  ${ns_id}  ${vnf_member_index_5}
    log  ${ip_addr_5}
    Set Suite Variable  ${vnf_5_ip_addr}  ${ip_addr_5}

Test SSH Access
    [Tags]  newK8sCluster   regression

    Variable Should Exist  ${vnf_1_ip_addr}  msg=IP address of the management VNF '${vnf_member_index_1}' is not available
    Variable Should Exist  ${vnf_2_ip_addr}  msg=IP address of the management VNF '${vnf_member_index_2}' is not available
    Variable Should Exist  ${vnf_3_ip_addr}  msg=IP address of the management VNF '${vnf_member_index_3}' is not available
    Variable Should Exist  ${vnf_4_ip_addr}  msg=IP address of the management VNF '${vnf_member_index_4}' is not available
    Variable Should Exist  ${vnf_5_ip_addr}  msg=IP address of the management VNF '${vnf_member_index_5}' is not available
    Sleep  30s  Waiting ssh daemon to be up
    Test SSH Connection  ${vnf_1_ip_addr}  ${username}  ${password}  ${privatekey}
    Test SSH Connection  ${vnf_2_ip_addr}  ${username}  ${password}  ${privatekey}
    Test SSH Connection  ${vnf_3_ip_addr}  ${username}  ${password}  ${privatekey}
    Test SSH Connection  ${vnf_4_ip_addr}  ${username}  ${password}  ${privatekey}
    Test SSH Connection  ${vnf_5_ip_addr}  ${username}  ${password}  ${privatekey}

Check kubeconfig file
    [Tags]  newK8sCluster   regression

    Check If remote File Exists  ${vnf_5_ip_addr}  ${username}  ${password}  ${privatekey}  ${kubeconfig_file}

Delete NS Instance
    [Tags]  newK8sCluster   regression   cleanup

    Delete NS  ${ns_name}


Delete NS Descriptor
    [Tags]  newK8sCluster   regression   cleanup

    Delete NSD  ${nsd_name}


Delete Controller VNF Descriptor
    [Tags]  newK8sCluster   regression   cleanup

    Delete VNFD  ${vnfd_name1}

Delete Machines VNF Descriptor
    [Tags]  newK8sCluster   regression   cleanup

    Delete VNFD  ${vnfd_name2}


*** Keywords ***
Test Cleanup
    [Documentation]  Test Suite Cleanup: Deleting descriptors and NS instance

    Run Keyword If Test Failed  Delete NS  ${ns_name}

    Run Keyword If Test Failed  Delete NSD  ${nsd_name}

    Run Keyword If Test Failed  Delete VNFD  ${vnfd_name}
