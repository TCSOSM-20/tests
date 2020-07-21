# Copyright 2020 Canonical Ltd.
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
Library   String
Library   OperatingSystem


*** Variables ***
${success_return_code}   0


*** Keywords ***
Package Build 
    [Documentation]   Build the package NS, VNF given the package_folder

    [Arguments]   ${pkg_folder}   ${skip_charm_build}=${EMPTY}

    ${skip_charm}   Set Variable If   '${skip_charm_build}'!='${EMPTY}'   --skip-charm-build   \
    ${rc}   ${stdout}=   Run and Return RC and Output   osm package-build ${pkg_folder} ${skip_charm}
    Should Be Equal As Integers   ${rc}   ${success_return_code}
    Should Contain   ${stdout}   Package created
    ${package}=   Get Line  ${stdout}  -1

    [Return]  ${package}

Package Validate
    [Documentation]   Validate descriptors given a base directory

    [Arguments]   ${pkg_folder}
    ${rc}   ${stdout}=   Run and Return RC and Output   osm package-validate ${pkg_folder} | awk -F\| '$2 !~ /-/ && $4 ~ /OK|ERROR/ {print $4}'
    Should Be Equal As Integers   ${rc}   ${success_return_code}
    Should Contain   ${stdout}   'OK'
    ${package}=   Get Line  ${stdout}  -1

    [Return]  ${package}

