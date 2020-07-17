# -*- coding: utf-8 -*-

##
# Copyright 2019 Tech Mahindra Limited
#
# All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
##

## Change log:
# 1. Feature 7829: Jayant Madavi, Mrityunjay Yadav : MY00514913@techmahindra.com : 06-sep-2019
##

*** Settings ***
Library   String


*** Variables ***
${success_return_code}   0
${delete_max_wait_time}   1min
${delete_pol_time}   15sec


*** Keywords ***
Get VNFDs List
    ${rc}   ${stdout}=   Run and Return RC and Output   osm vnfd-list
    log   ${stdout}
    log   ${rc}
    Should Be Equal As Integers   ${rc}   ${success_return_code}


Create VNFD
    [Documentation]   Onboards ("creates") a NF Package into OSM.
    ...               - Parameters:
    ...                 - vnfd_pkg: Name (and location) of the NF Package
    ...                 - overrides (optional): String with options to override the EPA and/or interface properties of the Package.
    ...                                        This is very useful to allow to deploy e.g. non-EPA packages in EPA VIMs (or vice-versa).
    ...                                        Valid strings are the same as in the command. E.g.:
    ...                                        - `--override-epa`: adds EPA attributes to all VDUs.
    ...                                        - `--override-nonepa`: removes all EPA attributes from all VDUs.
    ...                                        - `--override-paravirt`: converts all interfaces to `PARAVIRT`. This one can be combined with
    ...                                           the others above (e.g. '--override-nonepa --override-paravirt').
    ...               - Relevant environment variables:
    ...                  - OVERRIDES: If the environment variable "OVERRIDES" exists, it prevails over the value in the argument.
    ...                               This is often more convenient to enforce the same behaviour for every test run in a given VIM.

    [Arguments]   ${vnfd_pkg}   ${overrides}=${EMPTY}

    # If env variable "OVERRIDES" exists, it prevails over the value in the argument
    ${overrides}=   Get Environment Variable    OVERRIDES   default=${overrides}

    # Proceedes with the onboarding with the appropriate arguments
    ${rc}   ${stdout}=   Run and Return RC and Output   osm vnfd-create ${overrides} ${vnfd_pkg}
    log   ${stdout}
    Should Be Equal As Integers   ${rc}   ${success_return_code}
    ${lines}=  Get Line Count  ${stdout}
    ${last}=  Evaluate  ${lines} - 1
    ${id}=  Get Line  ${stdout}  ${last}
    [Return]  ${id}


Delete VNFD
    [Arguments]   ${vnfd_id}

    ${rc}   ${stdout}=   Run and Return RC and Output   osm vnfd-delete ${vnfd_id}
    log   ${stdout}
    Should Be Equal As Integers   ${rc}   ${success_return_code}
    WAIT UNTIL KEYWORD SUCCEEDS   ${delete_max_wait_time}   ${delete_pol_time}   Check For VNFD   ${vnfd_id}


Check For VNFD
    [Arguments]   ${vnfd_id}

    ${rc}   ${stdout}=   Run and Return RC and Output   osm vnfd-list | awk '{print $2}' | grep ${vnfd_id}
    Should Not Be Equal As Strings   ${stdout}   ${vnfd_id}
