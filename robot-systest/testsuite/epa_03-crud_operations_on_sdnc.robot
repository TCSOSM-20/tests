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
Documentation     [EPA-03] CRUD operations on SDNC accounts.

Resource   %{ROBOT_DEVOPS_FOLDER}/lib/sdnc_lib.robot

Variables   %{ROBOT_DEVOPS_FOLDER}/resources/epa_03-crud_operations_on_sdnc_data.py

Suite Teardown   Run Keyword And Ignore Error   Delete Basic SDNC


*** Test Cases ***
Create Basic SDNC
    [Tags]  sdnc_crud  sanity   regression

    ${created_sdnc_id}=  Create SDNC  ${sdnc_name}  ${sdnc_user}  ${sdnc_password}  ${sdnc_url}  ${sdnc_type}
    Check for SDNC  ${sdnc_name}


Check SDNC Status Is Healthy
    [Tags]  sdnc_crud  sanity   regression

    Check for SDNC Status  ${sdnc_name}  ${prometheus_host}  ${prometheus_port}


Delete Basic SDNC
    [Tags]  sdnc_crud  sanity   regression  cleanup

    Delete SDNC  ${sdnc_name}
