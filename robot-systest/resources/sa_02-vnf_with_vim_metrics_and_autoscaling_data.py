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

# Prometheus metric and threshold
metric_name = 'osm_cpu_utilization'
metric_threshold = 60
# Get ${HOME} from local machine
home = str(Path.home())
# NS and VNF descriptor package folder
vnfd_pkg = 'hackfest_basic_metrics_vnf'
nsd_pkg = 'hackfest_basic_metrics_ns'
# NS and VNF descriptor id
vnfd_name = 'hackfest_basic_metrics-vnf'
nsd_name = 'hackfest_basic-ns-metrics'
# NS instance name
ns_name = 'sa_02-vnf_with_vim_metrics_and_autoscaling_test'
# SSH keys to be used
publickey = home + '/.ssh/id_rsa.pub'
privatekey = home + '/.ssh/id_rsa'

