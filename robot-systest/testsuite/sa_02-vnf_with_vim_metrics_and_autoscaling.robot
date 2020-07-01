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
Documentation     [SA-02] VNF with VIM-based metrics and auto-scaling.

Library   OperatingSystem
Library   String
Library   Collections
Library   SSHLibrary

Resource   %{ROBOT_DEVOPS_FOLDER}/lib/vnfd_lib.robot
Resource   %{ROBOT_DEVOPS_FOLDER}/lib/nsd_lib.robot
Resource   %{ROBOT_DEVOPS_FOLDER}/lib/ns_lib.robot
Resource   %{ROBOT_DEVOPS_FOLDER}/lib/ssh_lib.robot
Resource   %{ROBOT_DEVOPS_FOLDER}/lib/prometheus_lib.robot

Variables   %{ROBOT_DEVOPS_FOLDER}/resources/sa_02-vnf_with_vim_metrics_and_autoscaling_data.py

Suite Teardown   Run Keyword And Ignore Error   Test Cleanup


*** Variables ***
${ns_id}   ${EMPTY}
${username}   ubuntu
${password}   osm4u
${vnf_member_index}   1
${vnf_ip_addr}   ${EMPTY}
${vnf_id}   ${EMPTY}
${ns_config}   {vld: [ {name: mgmtnet, vim-network-name: %{VIM_MGMT_NET}} ] }


*** Test Cases ***
Create VNF Descriptor
    [Tags]   vnf_vim_metrics_autoscaling   sanity   regression

    Create VNFD  '%{PACKAGES_FOLDER}/${vnfd_pkg}'


Create NS Descriptor
    [Tags]   vnf_vim_metrics_autoscaling   sanity   regression

    Create NSD  '%{PACKAGES_FOLDER}/${nsd_pkg}'


Instantiate Network Service
    [Tags]   vnf_vim_metrics_autoscaling   sanity   regression

    ${id}=  Create Network Service  ${nsd_name}  %{VIM_TARGET}  ${ns_name}  ${ns_config}  ${publickey}
    Set Suite Variable  ${ns_id}  ${id}


Get VNF Id
    [Tags]   vnf_vim_metrics_autoscaling   sanity   regression

    @{vnfr_list}=  Get Ns Vnfr Ids  ${ns_id}
    Log List  ${vnfr_list}
    Set Suite Variable   ${vnf_id}   ${vnfr_list}[0]


Get VNF IP Address
    [Tags]   vnf_vim_metrics_autoscaling   sanity   regression

    ${ip_addr}=  Get Vnf Management Ip Address   ${ns_id}   ${vnf_member_index}
    log   ${ip_addr}
    Set Suite Variable   ${vnf_ip_addr}   ${ip_addr}


Get VNF VIM-based Metric Before Auto-scaling
    [Tags]   vnf_vim_metrics_autoscaling   sanity   regression

    Variable Should Exist  ${prometheus_host}  msg=Prometheus address is not available
    Variable Should Exist  ${prometheus_port}  msg=Prometheus port is not available
    Variable Should Exist  ${metric_name}  msg=Prometheus metric name is not available
    ${metric_value}=  Wait Until Keyword Succeeds  6 times  2 minutes  Get Metric  ${prometheus_host}  ${prometheus_port}  ${metric_name}
    Run Keyword Unless  ${metric_value} > 0  Fail  msg=The metric '${metric_name}' value is '${metric_value}'
    Run Keyword Unless  ${metric_value} < ${metric_threshold}  Fail  msg=The metric '${metric_name}' value is higher than '${metric_threshold}' before scaling


Increase VIM-based Metric To Force Auto-scaling
    [Tags]   vnf_vim_metrics_autoscaling   sanity   regression

    Variable Should Exist  ${privatekey}  msg=SSH private key not available
    Execute Remote Command Check Rc Return Output   ${vnf_ip_addr}   ${username}   ${password}   ${privatekey}   for i in {1..9}; do yes > /dev/null & done


Wait VIM-based Metric To Exceed Threshold
    [Tags]   vnf_vim_metrics_autoscaling   sanity   regression

    Wait Until Keyword Succeeds  6 times  2 minutes  Check VIM-based Metric Exceeds Threshold


Get VDUs After Auto-scaling
    [Tags]   vnf_vim_metrics_autoscaling   sanity   regression

    Sleep  1 minute  Wait for auto-scale to take place
    @{vdur_list}=  Get Vnf Vdur Names  ${vnf_id}
    Log List  ${vdur_list}
    ${vdurs}=  Get Length  ${vdur_list}
    Run Keyword Unless  ${vdurs} > 1  Fail  msg=There is no new VDU after auto-scaling


Delete NS Instance
    [Tags]   vnf_vim_metrics_autoscaling   sanity   regression  cleanup

    Delete NS  ${ns_name}


Delete NS Descriptor
    [Tags]   vnf_vim_metrics_autoscaling   sanity   regression  cleanup

    Delete NSD  ${nsd_name}


Delete VNF Descriptor
    [Tags]   vnf_vim_metrics_autoscaling   sanity   regression  cleanup

    Delete VNFD  ${vnfd_name}


*** Keywords ***
Test Cleanup
    [Documentation]  Test Suite Cleanup: Deleting descriptors and NS instance

    Run Keyword If Test Failed  Delete NS  ${ns_name}
    Run Keyword If Test Failed  Delete NSD  ${nsd_name}
    Run Keyword If Test Failed  Delete VNFD  ${vnfd_name}


Check VIM-based Metric Exceeds Threshold
    [Documentation]  Auxiliar keyword to check if metric exceeds threshold

    Variable Should Exist  ${prometheus_host}  msg=Prometheus address is not available
    Variable Should Exist  ${prometheus_port}  msg=Prometheus port is not available
    Variable Should Exist  ${metric_name}  msg=Prometheus metric name is not available
    ${metric_value}=  Get Metric  ${prometheus_host}  ${prometheus_port}  ${metric_name}
    Run Keyword Unless  ${metric_value} > ${metric_threshold}  Fail  msg=The metric '${metric_name}' value is '${metric_value}' which is lower than '${metric_threshold}'


