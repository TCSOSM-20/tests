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

from pathlib import Path

# Get ${HOME} from local machine
home = str(Path.home())
# NS and VNF descriptor package files
vnfd_pkg1 = 'charm-packages/nscharm_policy_vnf'
vnfd_pkg2 = 'charm-packages/nscharm_user_vnf'
nsd_pkg = 'charm-packages/nscharm_ns'
# NSD and VNFD names in OSM
vnfd_name1 = 'nscharm-policy-vnf'
vnfd_name2 = 'nscharm-user-vnf'
nsd_name = 'nscharm-ns'
# NS Descriptor file
nsd_file = 'nscharm_nsd.yaml'
# NS instance name
ns_name = 'test_nscharm'
# SSH keys to be used
publickey = home + '/.ssh/id_rsa.pub'
privatekey = home + '/.ssh/id_rsa'
# Juju variables
old_juju_password = 'd55ce8ab4efa59e7f1b865bce53f55ed'
