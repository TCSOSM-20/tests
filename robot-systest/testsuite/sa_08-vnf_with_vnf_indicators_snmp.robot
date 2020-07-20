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
Documentation     [SA-08] VNF with VNF-based indicators through SNMP.

Library   OperatingSystem
Library   String
Library   Collections

Resource   %{ROBOT_DEVOPS_FOLDER}/lib/vnfd_lib.robot
Resource   %{ROBOT_DEVOPS_FOLDER}/lib/nsd_lib.robot
Resource   %{ROBOT_DEVOPS_FOLDER}/lib/ns_lib.robot
Resource   %{ROBOT_DEVOPS_FOLDER}/lib/ssh_lib.robot
Resource   %{ROBOT_DEVOPS_FOLDER}/lib/prometheus_lib.robot

Variables   %{ROBOT_DEVOPS_FOLDER}/resources/sa_08-vnf_with_vnf_indicators_snmp_data.py

Suite Teardown   Run Keyword And Ignore Error   Test Cleanup


*** Variables ***
${ns_config}   {vld: [ {name: mgmtnet, vim-network-name: %{VIM_MGMT_NET}} ] }


*** Test Cases ***
Create VNF Descriptor
    [Tags]   vnf_indicators_snmp   sanity   regression

    Create VNFD  '%{PACKAGES_FOLDER}/${vnfd_pkg}'


Create NS Descriptor
    [Tags]   vnf_indicators_snmp   sanity   regression

    Create NSD  '%{PACKAGES_FOLDER}/${nsd_pkg}'


Instantiate Network Service
    [Tags]   vnf_indicators_snmp   sanity   regression

    ${id}=  Create Network Service  ${nsd_name}  %{VIM_TARGET}  ${ns_name}  ${ns_config}  ${EMPTY}
    Set Suite Variable  ${ns_id}  ${id}


Get VNF SNMP Metrics
    [Tags]   vnf_indicators_snmp   sanity   regression

    Variable Should Exist  ${prometheus_host}  msg=Prometheus address is not available
    Variable Should Exist  ${prometheus_port}  msg=Prometheus port is not available
    Variable Should Exist  ${metric_1_name}  msg=Prometheus first metric name is not available
    Variable Should Exist  ${metric_2_name}  msg=Prometheus second metric name is not available
    ${metric_1_value}=  Wait Until Keyword Succeeds  6 times  1 minutes  Get Metric  ${prometheus_host}  ${prometheus_port}  ${metric_1_name}  ${metric_1_filter}
    Run Keyword Unless  ${metric_1_value} > 0  Fail  msg=The metric '${metric_1_name}' value is '${metric_1_value}'
    ${metric_2_value}=  Wait Until Keyword Succeeds  6 times  1 minutes  Get Metric  ${prometheus_host}  ${prometheus_port}  ${metric_2_name}  ${metric_2_filter}
    Run Keyword Unless  ${metric_2_value} > 0  Fail  msg=The metric '${metric_2_name}' value is '${metric_2_value}'


Delete NS Instance
    [Tags]   vnf_indicators_snmp   sanity   regression  cleanup

    Delete NS  ${ns_name}


Delete NS Descriptor
    [Tags]   vnf_indicators_snmp   sanity   regression  cleanup

    Delete NSD  ${nsd_name}


Delete VNF Descriptor
    [Tags]   vnf_indicators_snmp   sanity   regression  cleanup

    Delete VNFD  ${vnfd_name}


*** Keywords ***
Test Cleanup
    [Documentation]  Test Suite Cleanup: Deleting descriptors and NS instance

    Run Keyword If Test Failed  Delete NS  ${ns_name}
    Run Keyword If Test Failed  Delete NSD  ${nsd_name}
    Run Keyword If Test Failed  Delete VNFD  ${vnfd_name}
