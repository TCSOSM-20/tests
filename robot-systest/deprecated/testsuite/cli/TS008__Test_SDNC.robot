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


*** Settings ***
Documentation    Test suiet to create/delete sdnc account via osmclient
Library     OperatingSystem
Library     Collections
Resource    ../../lib/cli/sdnc_account_lib.robot


*** Test Cases ***
Create SDNC Account Test
    [Tags]  sdnc

    Create SDNC Account


Get SDNC Accounts List Test
    [Tags]  sdnc

    Get SDNC List


Delete SDNC Account Test
    [Tags]  sdnc

    Delete SDNC Account
