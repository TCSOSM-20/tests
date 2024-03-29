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

from pathlib import Path
import os

# Prometheus host and port
if os.environ.get('PROMETHEUS_HOSTNAME', False):
    prometheus_host = os.environ.get('PROMETHEUS_HOSTNAME')
    prometheus_port = '9090'
else:
    prometheus_host = os.environ.get('OSM_HOSTNAME')
    prometheus_port = '9091'

# Prometheus metrics to retrieve
metric_1_name = 'ifInOctets'
metric_1_filter = 'ifIndex=1'
metric_2_name = 'ifMtu'
metric_2_filter = 'ifIndex=2'
# Get ${HOME} from local machine
home = str(Path.home())
# NS and VNF descriptor package folder
vnfd_pkg = 'snmp_ee_vnf'
nsd_pkg = 'snmp_ee_ns'
# NS and VNF descriptor id
vnfd_name = 'snmp_ee-vnf'
nsd_name = 'snmp_ee-ns'
# NS instance name
ns_name = 'sa_08-vnf_with_vnf_indicators_snmp_test'
