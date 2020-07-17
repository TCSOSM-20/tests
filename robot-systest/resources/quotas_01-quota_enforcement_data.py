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
# VNFD package to use during test
vnfd_name = 'hackfest_basic_vnf'
# Project names to use
project_1_name = 'quotas_01_proj_1'
project_2_name = 'quotas_01_proj_2'
project_3_name = 'quotas_01_proj_3'
# User name and password for project
user_name = 'quotas_01_user'
user_password = 'quotas_01_pass'
