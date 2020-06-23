<!--
Copyright 2020 ETSI

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
implied.
See the License for the specific language governing permissions and
limitations under the License
-->

# OSM test automation project - osm/tests

This repository contains tools and configuration files for testing and automation needs of OSM projet

## Prerequisites

* **Robot Framework**
* **Packages**: ssh ping yq git
* **Python3 packages**: haikunator requests robotframework robotframework-seleniumlibrary robotframework-requests robotframework-jsonlibrary robotframework-sshlibrary
* Clone **osm-packages** from gitlab
* Environment config file for your infrastructure [envfile.rc]

## Installing

This bash script can be used to setup your environment to execute the tests.

```bash
   PACKAGES_FOLDER=osm-packages
   add-apt-repository -y ppa:rmescandon/yq && apt update && apt install yq git iputils-ping ssh -y
   pip install haikunator requests robotframework robotframework-seleniumlibrary robotframework-requests robotframework-jsonlibrary \
      robotframework-sshlibrary
   snap install charm
   # Download community packages
   git clone https://osm.etsi.org/gitlab/vnf-onboarding/osm-packages.git ${PACKAGES_FOLDER}
```

envfile.rc

```bash
   # VIM Setup
   OS_USERNAME=<openstack_username>
   OS_PASSWORD=<openstack_password>
   OS_TENANT_NAME=<openstack_tenant_name>
   OS_AUTH_URL=<openstack_authorization_url>
   OS_TENANT_ID=<openstack_tenant_id>

   # OSM Setup
   OSM_HOSTNAME=<osm_ip_address>
   VIM_TARGET=<osm_vim_name>
   VIM_MGMT_NET=<osm_vim_mgmt_name>

   # Clouds file datacenter
   OS_CLOUD=<datacenter_in_clouds_file>

   # K8S config file
   K8S_CREDENTIALS=<path_to_kubeconfig>

   # The following set of environment variables will be used in host
   # of the robot framework. Not needed for docker execution

   # Folder where Robot tests are stored
   ROBOT_DEVOPS_FOLDER=robot-systest

   # Folder to save alternative DUT environments (optional)
   ENVIRONMENTS_FOLDER=environments

   # Folder where all required packages are stored
   PACKAGES_FOLDER=osm-packages

   # Folder where test results should be exported
   ROBOT_REPORT_FOLDER=results
```

## Deployment

It is possible to run the tests directly from the repository or using a docker container with the tests

1. Docker container creation:

```bash
docker build -t osmtests .
```

Options:

* --env-file: It is the environmental file where is described the OSM target and VIM
* -o <osmclient_version> [OPTIONAL]: It is used to specify a particular osmclient version. Default: latest
* -p <package_branch> [OPTIONAL]: OSM packages repository branch. Default: master
* -t <testing_tags> [OPTIONAL]: Robot tests tags. [sanity, regression, particular_test]. Default: sanity

Volumes:

* <path_to_reports> [OPTIONAL]: It is the absolute path to reports location in the host
* <path_to_clouds.yaml> [OPTIONAL]: It is the absolute path to the clouds.yaml file in the host
* <path_to_kubeconfig> [OPTIONAL]: It is the kubeconfig file to be used for k8s clusters

```bash
   docker run --rm=true -t osmtests --env-file <env_file> \
       -v <path_to_reports>:/reports osmtests \
       -v <path_to_clouds.yaml>:/robot-systest/clouds.yaml \
       -v <path_to_kubeconfig>:/root/.kube/config \
       -o <osmclient_version> \
       -p <package_branch> \
       -t <testing_tags>
```

1. Running the tests manually:

The way of executing the tests is via the following command:

```bash
   source envfile.rc
   robot -d reports -i <testing_tags> testsuite/
```

## Built With

* [Python](www.python.org/) - The language used
* [Robot Framework](robotframework.org) - The testing framework

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://osm.etsi.org/gitweb/?p=osm/tests.git;a=tags).

## License

This project is licensed under the Apache2 License - see the [LICENSE.md](LICENSE) file for details

## Acknowledgments
