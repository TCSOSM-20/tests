#   Copyright 2020 Canonical Ltd.
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

# Get ${HOME} from local machine
home = str(Path.home())
# NS and VNF descriptor package files
vnfd_pkg1 = 'k8s_jujucontroller_vnf.tar.gz'
vnfd_pkg2 = 'k8s_jujumachine_vnf.tar.gz'
nsd_pkg = 'k8s_juju_ns.tar.gz'
# NS and VNF descriptor package files
vnfd_name1 = 'k8s_jujucontroller_vnf'
vnfd_name2 = 'k8s_jujumachine_vnf'
nsd_name = 'k8s_juju'
# VNF Member indexes
vnf_member_index_1 = 'k8s_vnf1'
vnf_member_index_2 = 'k8s_vnf2'
vnf_member_index_3 = 'k8s_vnf3'
vnf_member_index_4 = 'k8s_vnf4'
vnf_member_index_5 = 'k8s_juju'
# Username
username = 'ubuntu'
# Kubeconfig file
kubeconfig_file = '/home/ubuntu/.kube/config'
# NS instance name
ns_name = 'k8s-cluster'
# SSH keys to be used
publickey = home + '/.ssh/id_rsa.pub'
privatekey = home + '/.ssh/id_rsa'
# Template and config file to use
template = 'k8s_juju_template.yaml'
config_file = 'config.yaml'
