#!/usr/bin/env groovy
def scm_url = "git@bitbucket.org:fractalindustries/nginx-version-test"
def scm_branch = "master"
def docker_registry_url = "https://fractal-docker-registry.bintray.io"

def scm_credentials = "dcos-jenkins"
def docker_registry_credentials = "dcos-jenkins-bintray"

def jenkins_slave = "mesos"
def marathon_url = env.MARATHON_URL == null ? 'http://marathon.mesos:8080' : env.MARATHON_URL
def marathon_file_path = "marathon.json"
def marathon_app_id = "nginx-version-test"


node ( 'mesos' ) {

	// Wipe the workspace
	deleteDir()

	stage ('Checkout') {
		git url: scm_url, branch: scm_branch, credentialsId: scm_credentials
			sh "git rev-parse --short HEAD > .git/commit"
			sh "basename `git rev-parse --show-toplevel` > .git/image"
            COMMIT_ID = readFile('.git/commit').trim()
            SERVICE_NAME = readFile('.git/image')
	}

	stage ('Docker Build and Push') {
		withDockerRegistry([credentialsId: docker_registry_credentials, url: docker_registry_url]) {
			def app = docker.build "fractal-docker-registry.bintray.io/${SERVICE_NAME}:${COMMIT_ID}"
			app.push
			}
		}

	stage ('Marathon-Deployment') {
		sh "./marathon.sh -i=$COMMIT_ID -s=$SERVICE_NAME"
		sh "curl -X PUT ${marathon_url}/v2/apps/${marathon_app_id} -d @${marathon_file_path} -H 'Content-type: application/json'"
	}
}


