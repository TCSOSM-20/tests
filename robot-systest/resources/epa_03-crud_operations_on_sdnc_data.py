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

import os
import yaml
from pathlib import Path

# Prometheus host and port
if os.environ.get("PROMETHEUS_HOSTNAME", False):
    prometheus_host = os.environ.get("PROMETHEUS_HOSTNAME")
    prometheus_port = "9090"
else:
    prometheus_host = os.environ.get("OSM_HOSTNAME")
    prometheus_port = "9091"

# VIM Configuration
sdnc_type = "onos"
sdnc_name = "epa_03_crud_operations_on_sdnc_test"
# Get credentials from ONOS SDNCs file
os_sdnc = os.environ.get("OS_SDNC")
sdncs_file_paths = ["./sdncs.yaml", str(Path.home()) + "/.config/onos/sdncs.yaml"]
for path in sdncs_file_paths:
    sdncs_file_path = Path(path)
    if sdncs_file_path.exists(): break
if not sdncs_file_path.exists(): raise Exception("ONOS sdncs file not found")
with sdncs_file_path.open() as sdncs_file:
    sdncs = yaml.safe_load(sdncs_file)
    if not os_sdnc in sdncs["sdncs"]: raise Exception("SDN controller '" + os_sdnc + "' not found")
    sdnc = sdncs["sdncs"][os_sdnc]
    if not "username" in sdnc["auth"]: raise Exception("Username not found in SDN controller '" + os_sdnc + "'")
    sdnc_user = sdnc["auth"]["username"]
    if not "password" in sdnc["auth"]: raise Exception("Password not found in SDN controller '" + os_sdnc + "'")
    sdnc_password = sdnc["auth"]["password"]
    if not "url" in sdnc["auth"]: raise Exception("URL not found in SDN controller '" + os_sdnc + "'")
    sdnc_url = sdnc["auth"]["url"]
