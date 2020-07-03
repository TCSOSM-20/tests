# Copyright 2020 Canonical Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#     Unless required by applicable law or agreed to in writing, software
#     distributed under the License is distributed on an "AS IS" BASIS,
#     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#     See the License for the specific language governing permissions and
#     limitations under the License.

from jinja2 import Template

class renderTemplate():

    def render_template(self, template_file, config_file, **kwargs):
        """Renders a template with the values provided

        Args:
            template_file: Template we want to render
            config_file: Output file once the template is rendered

        Returns:
            content: The output of the config file
        """

        with open(template_file, "r") as t_file:
            content = t_file.read()
        template = Template(content)
        content = template.render(kwargs)
        with open(config_file, "w") as c_file:
            c_file.write(content)
        return content
