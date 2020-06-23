# Copyright 2020 ETSI
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM ubuntu:18.04

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install git software-properties-common \
    make python3 debhelper python3-setuptools python3-pip apt-utils ssh iputils-ping libcurl4-openssl-dev libssl-dev \
    python3-openstackclient
RUN add-apt-repository -y ppa:rmescandon/yq && apt update && apt install yq -y 
RUN python3 -m pip install haikunator requests robotframework robotframework-seleniumlibrary robotframework-requests robotframework-jsonlibrary \
        robotframework-sshlibrary charm-tools git+https://osm.etsi.org/gerrit/osm/IM.git git+https://osm.etsi.org/gerrit/osm/osmclient.git
WORKDIR /robot-systest
RUN git clone https://osm.etsi.org/gitlab/vnf-onboarding/osm-packages.git --recurse-submodules /robot-systest/osm-packages
COPY robot-systest /robot-systest
COPY charm.sh /usr/sbin/charm

# Folder where Robot tests are stored
ENV ROBOT_DEVOPS_FOLDER=/robot-systest

# Folder to save alternative DUT environments (optional)
ENV ENVIRONMENTS_FOLDER=environments

# Folder where all required packages are stored
ENV PACKAGES_FOLDER=/robot-systest/osm-packages

# Folder where test results should be exported
ENV ROBOT_REPORT_FOLDER=/robot-systest/results

# Kubeconfig file
ENV K8S_CREDENTIALS=/root/.kube/config

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

ENTRYPOINT [ "/robot-systest/run_test.sh"]
