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

# Webhook Service NS and VNF descriptor package folder
ws_vnfd_pkg = 'hackfest_basic_vnf'
ws_nsd_pkg = 'hackfest_basic_ns'
# Webhook Service NS and VNF descriptor package id
ws_vnfd_name = 'hackfest_basic-vnf'
ws_nsd_name = 'hackfest_basic-ns'
# Webhook Service NS instance name
ws_ns_name = 'sa_07-webhook_service_test'
# Webhook Service port to receive alarms
ws_port = 5212

# Get ${HOME} from local machine
home = str(Path.home())
# Prometheus metric for VNF alarm
metric_name = 'osm_cpu_utilization'
# NS and VNF descriptor package folder
vnfd_pkg = 'cirros_alarm_vnf'
nsd_pkg = 'cirros_alarm_ns'
# VNF descriptor file name
vnfd_file = 'cirros_alarm_vnfd.yaml'
# VNF descriptor package location  after env substitution
new_vnfd_pkg = 'new_cirros_alarm_vnf'
# NS and VNF descriptor id
vnfd_name = 'cirros_alarm-vnf'
nsd_name = 'cirros_alarm-ns'
# NS instance name
ns_name = 'sa_07-alarms_from_sa-related_vnfs_test'
# SSH keys to be used
publickey = home + '/.ssh/id_rsa.pub'
privatekey = home + '/.ssh/id_rsa'
