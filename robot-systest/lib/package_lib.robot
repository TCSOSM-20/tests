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
Upload Package
    [Documentation]   Onboards ("creates") a NF Package into OSM.
    ...               - Parameters:
    ...                 - pkg: Name (and location) of the NF Package

    [Arguments]   ${pkg}

    # Proceedes with the onboarding with the appropriate arguments
    ${rc}   ${stdout}=   Run and Return RC and Output   tar -czf ${pkg}.tar.gz -C ${pkg} .
    ${rc}   ${stdout}=   Run and Return RC and Output   osm upload-package ${pkg}.tar.gz
    log   ${stdout}
    Should Be Equal As Integers   ${rc}   ${success_return_code}
    [Return]  ${stdout}


Delete Package
    [Arguments]   ${pkg}

    # Proceedes with the onboarding with the appropriate arguments
    ${rc}   ${stdout}=   Run and Return RC and Output   rm ${pkg}.tar.gz
