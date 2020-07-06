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
Documentation     [SA-07] Events or alarms coming from SA-related VNFs in the NS.

Library   OperatingSystem
Library   String
Library   Collections
Library   SSHLibrary

Resource   %{ROBOT_DEVOPS_FOLDER}/lib/vnfd_lib.robot
Resource   %{ROBOT_DEVOPS_FOLDER}/lib/nsd_lib.robot
Resource   %{ROBOT_DEVOPS_FOLDER}/lib/ns_lib.robot
Resource   %{ROBOT_DEVOPS_FOLDER}/lib/ssh_lib.robot
Resource   %{ROBOT_DEVOPS_FOLDER}/lib/prometheus_lib.robot

Variables   %{ROBOT_DEVOPS_FOLDER}/resources/sa_07-alarms_from_sa-related_vnfs_data.py

Suite Teardown   Run Keyword And Ignore Error   Test Cleanup


*** Variables ***
${ns_id}   ${EMPTY}
${ws_ns_id}   ${EMPTY}
${username}   ubuntu
${password}   ${EMPTY}
${vnf_member_index}   1
${ws_vnf_ip_addr}   ${EMPTY}
${success_return_code}   0
${alarm_msg}   notify_alarm
${ws_log_file}   webhook.log
${ns_config}   {vld: [ {name: mgmtnet, vim-network-name: %{VIM_MGMT_NET}} ] }


*** Test Cases ***
Create Webhook Service VNF Descriptor
    [Tags]   alarms_sa_related_vnfs   sanity   regression

    Create VNFD  '%{PACKAGES_FOLDER}/${ws_vnfd_pkg}'


Create Webhook Service NS Descriptor
    [Tags]   alarms_sa_related_vnfs   sanity   regression

    Create NSD  '%{PACKAGES_FOLDER}/${ws_nsd_pkg}'


Instantiate Webhook Service Network Service
    [Tags]   alarms_sa_related_vnfs   sanity   regression

    ${id}=  Create Network Service  ${ws_nsd_name}  %{VIM_TARGET}  ${ws_ns_name}  ${ns_config}  ${publickey}
    Set Suite Variable  ${ws_ns_id}  ${id}


Get Webhook Service VNF IP Address
    [Tags]   alarms_sa_related_vnfs   sanity   regression

    ${ip_addr}=  Get Vnf Management Ip Address   ${ws_ns_id}   ${vnf_member_index}
    log   ${ip_addr}
    Set Suite Variable   ${ws_vnf_ip_addr}   ${ip_addr}


Start Webhook Service
    [Tags]   alarms_sa_related_vnfs   sanity   regression

    Variable Should Exist  ${privatekey}  msg=SSH private key not available
    Sleep   40 seconds   Wait for SSH daemon to be up
    ${stdout}=   Execute Remote Command Check Rc Return Output   ${ws_vnf_ip_addr}   ${username}   ${password}   ${privatekey}   nc -lkv '${ws_port}' > '${ws_log_file}' 2>&1 &


Create VNF Descriptor
    [Tags]   alarms_sa_related_vnfs   sanity   regression

    ${rc}   ${stdout}=   Run and Return RC and Output   mkdir '%{PACKAGES_FOLDER}/${new_vnfd_pkg}' && WEBHOOK_URL="http://${ws_vnf_ip_addr}:${ws_port}" envsubst < '%{PACKAGES_FOLDER}/${vnfd_pkg}'/'${vnfd_file}' > '%{PACKAGES_FOLDER}/${new_vnfd_pkg}'/'${vnfd_file}'
    log   ${stdout}
    Should Be Equal As Integers   ${rc}   ${success_return_code}
    Create VNFD  '%{PACKAGES_FOLDER}/${new_vnfd_pkg}'


Create NS Descriptor
    [Tags]   alarms_sa_related_vnfs   sanity   regression

    Create NSD  '%{PACKAGES_FOLDER}/${nsd_pkg}'


Instantiate Network Service
    [Tags]   alarms_sa_related_vnfs   sanity   regression

    ${id}=  Create Network Service  ${nsd_name}  %{VIM_TARGET}  ${ns_name}  ${ns_config}  ${publickey}
    Set Suite Variable  ${ns_id}  ${id}


Get Alarm Metric
    [Tags]   alarms_sa_related_vnfs   sanity   regression

    Variable Should Exist  ${prometheus_host}  msg=Prometheus address is not available
    Variable Should Exist  ${prometheus_port}  msg=Prometheus port is not available
    Variable Should Exist  ${metric_name}  msg=Prometheus metric name is not available
    ${metric_value}=  Wait Until Keyword Succeeds  6 times  2 minutes  Get Metric  ${prometheus_host}  ${prometheus_port}  ${metric_name}
    Run Keyword Unless  ${metric_value} > 0  Fail  msg=The metric '${metric_name}' value is '${metric_value}'


Check Alarms Were Received
    [Tags]   alarms_sa_related_vnfs   sanity   regression

    Wait Until Keyword Succeeds  6 times  40 seconds  Execute Remote Command Check Rc Return Output   ${ws_vnf_ip_addr}   ${username}   ${password}   ${privatekey}   cat '${ws_log_file}' | grep '${alarm_msg}' | grep '${ns_name}'


Delete NS Instance
    [Tags]   alarms_sa_related_vnfs   sanity   regression  cleanup

    Delete NS  ${ns_name}


Delete NS Descriptor
    [Tags]   alarms_sa_related_vnfs   sanity   regression  cleanup

    Delete NSD  ${nsd_name}


Delete VNF Descriptor
    [Tags]   alarms_sa_related_vnfs   sanity   regression  cleanup

    Delete VNFD  ${vnfd_name}


Delete Webhook Service NS Instance
    [Tags]   alarms_sa_related_vnfs   sanity   regression  cleanup

    Delete NS  ${ws_ns_name}


Delete Webhook Service NS Descriptor
    [Tags]   alarms_sa_related_vnfs   sanity   regression  cleanup

    Delete NSD  ${ws_nsd_name}


Delete Webhook Service VNF Descriptor
    [Tags]   alarms_sa_related_vnfs   sanity   regression  cleanup

    Delete VNFD  ${ws_vnfd_name}


*** Keywords ***
Test Cleanup
    [Documentation]  Test Suite Cleanup: Deleting descriptors and NS instance

    Run Keyword If Test Failed  Delete NS  ${ns_name}
    Run Keyword If Test Failed  Delete NSD  ${nsd_name}
    Run Keyword If Test Failed  Delete VNFD  ${vnfd_name}
    Run Keyword If Test Failed  Delete NS  ${ws_ns_name}
    Run Keyword If Test Failed  Delete NSD  ${ws_nsd_name}
    Run Keyword If Test Failed  Delete VNFD  ${ws_vnfd_name}
