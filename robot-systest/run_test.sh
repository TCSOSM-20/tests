#!/usr/bin/env bash

##
# Copyright 2020 ATOS
#
# All Rights Reserved.
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
##

cat /dev/zero | ssh-keygen -q -N "" > /dev/null

install_osmclient(){
    echo -e "\nInstalling osmclient ${OSMCLIENT}"
    python3 -m pip install git+https://osm.etsi.org/gerrit/osm/osmclient@${OSMCLIENT}
}

download_packages(){
    echo -e "\nDownloading packages ${PACKAGES}"
    rm -rf ${PACKAGES_FOLDER}
    git clone https://osm.etsi.org/gitlab/vnf-onboarding/osm-packages.git ${PACKAGES_FOLDER} && (cd ${PACKAGES_FOLDER} && \
        git checkout ${PACKAGES})
}

create_vim(){
    echo -e "\nCreating VIM ${VIM_TARGET}"
    osm vim-create --name ${VIM_TARGET} --user ${OS_USERNAME} --password ${OS_PASSWORD} --tenant ${OS_PROJECT_NAME} \
                   --auth_url ${OS_AUTH_URL} --account_type openstack --description vim \
                   --config "{management_network_name: ${VIM_MGMT_NET}}" || true
}

PARAMS=""

while (( "$#" )); do
    case "$1" in
        -t|--testingtags)
            TEST=$2
            shift 2
            ;;
        -p|--packagesbranch)
            PACKAGES=$2 && download_packages
            shift 2
            ;;
        -o|--osmclientversion)
            OSMCLIENT=$2 install_osmclient
            shift 2
            ;;
        -c|--createvim)
            create_vim
            shift 1
            ;;
        -h|--help)
            echo "OSM TESTS TOOL

Usage:
        docker run --rm=true -t osmtests --env-file <env_file> \\
            -v <path_to_reports>:/reports osmtests \\
            -v <path_to_clouds.yaml>:/robot-systest/clouds.yaml \\
            -v <path_to_kubeconfig>:/root/.kube/config \\
            -o <osmclient_version> \\
            -p <package_branch> \\
            -t <testing_tags>

Options:
        --env-file: It is the environmental file where is described the OSM target and VIM
        -o <osmclient_version> [OPTIONAL]: It is used to specify a particular osmclient version. Default: latest
        -p <package_branch> [OPTIONAL]: OSM packages repository branch. Default: master
        -t <testing_tags> [OPTIONAL]: Robot tests tags. [sanity, regression, particular_test]. Default: sanity
        -c To create a VIM for the tests

Volumes:
        <path_to_reports> [OPTIONAL]: It is the absolute path to reports location in the host
        <path_to_clouds.yaml> [OPTIONAL]: It is the absolute path to the clouds.yaml file in the host
        <path_to_kubeconfig> [OPTIONAL]: It is the kubeconfig file to be used for k8s clusters"

            exit 0
            ;;
        -*|--*=)
            echo "Error: Unsupported flag $1" >&2
            exit 1
            ;;
        *)
            PARAMS="$PARAMS $1"
            shift
            ;;
    esac
done

eval set -- "$PARAMS"

if [[ -n "$stackName" ]]; then
    export OSM_HOSTNAME=osm${stackName}_nbi
fi

if [[ -z "${TEST}" ]]; then
    printf "Test not provided. \nRunning default test: sanity\n"
    TEST="sanity"
fi

if [[ -n "${TEST}" ]]; then
    robot -d ${ROBOT_DEVOPS_FOLDER}/reports -i ${TEST} ${ROBOT_DEVOPS_FOLDER}/testsuite/
    exit 0
else
    echo "Wrong test provided"
    exit 1
fi

exit 1
