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
# NS and VNF descriptor package folder
vnfd_pkg = 'charm-packages/vnf_relations_vnf'
nsd_pkg = 'charm-packages/vnf_relations_ns'
# NS and VNF descriptor id
vnfd_name = 'vnf_relations-vnf'
nsd_name = 'vnf_relations-ns'
# NS instance name
ns_name = 'basic_14_vnf_relations_test'
# SSH keys to be used
publickey = home + '/.ssh/id_rsa.pub'
privatekey = home + '/.ssh/id_rsa'
