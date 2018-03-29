#!/usr/bin/env groovy

// Define source code configurations

def scm_repository = 'git@bitbucket.org:fractalindustries/nginx-version-test'
def scm_branch = 'master'
def scm_credentials = 'dcos-jenkins'

// Define docker related configuration

def docker_registry_url = "https://docker.fractalindustries.com"
def docker_registry_credentials = "artifactory"
def docker_image = "docker.fractalindustries.com/nginx-version-test"
def dockerfile_path = "Dockerfile"

// Define marathon related configurations

def marathon_url = 'http://marathon.mesos'
def marathon_path = "marathon.json"
def configJson = 'marathon.json'

// Application

def app_name = 'nginx-version-test'

// Pipeline steps

node ( 'mesos' ) {

		// Wipe the workspace
		deleteDir()
		stage ('Checkout') {
			git url: scm_repository, branch: scm_branch, credentialsId: scm_credentials
		}

		stage ('Env Variable Capture') {
			sh "git rev-parse --short HEAD > .git/commit"
			sh "basename `git rev-parse --show-toplevel` > .git/image"
	        COMMIT_ID = readFile('.git/commit').trim()
	        SERVICE_NAME = readFile('.git/image')
		}

		stage ('Docker Build') {
			withDockerRegistry([credentialsId: docker_registry_credentials, url: docker_registry_url]) {
				app = docker.build(docker_image)
				}
		}

		stage ('Docker Tag') {
			withDockerRegistry([credentialsId: docker_registry_credentials, url: docker_registry_url]) {
				app.push("${COMMIT_ID}")
				app.push("latest")
				}
		}

		stage ("Marathon-Deployment") {
		sh "./marathon.sh -i $COMMIT_ID"
		sh "curl -X DELETE http://marathon.mesos:8080/v2/apps/$app_name -H 'Content-type: application/json' && sleep 30"
		sh "curl -X PUT http://marathon.mesos:8080/v2/apps/$app_name -d @${configJson} -H 'Content-type: application/json'"
		//def health_check = shell.parse("sleep 120 && curl -X GET http://marathon.mesos:8080/v2/apps/$APP_NAME -H 'Content-type: application/json'")
		//print health_check
		}
}
