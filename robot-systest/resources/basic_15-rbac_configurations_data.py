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
# User, project and roles to use
user_name = 'basic_15_test_user'
user_password = 'basic_15_user_pass'
user_role = 'project_user'
user_project = 'admin'
project_name = 'basic_15_test_project'
new_project_name = 'basic_15_project_test'
role_name = 'test_role'
