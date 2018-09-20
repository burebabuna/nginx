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

// Define Application Properties to attach
// Properties are supposed to be separated by a semicolon ;
// https://www.jfrog.com/confluence/display/RTF/Artifactory+REST+API#ArtifactoryRESTAPI-SetItemProperties
def image_name = "nginx-version-test"
def artifactory_api_url = "https://artifactory.fractalindustries.com/artifactory/api/storage/fractal-docker"

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
		    sh "git rev-parse HEAD > .git/head"
			sh "git rev-parse --short HEAD > .git/commit"
			sh "basename `git rev-parse --show-toplevel` > .git/image"
			COMMIT_ID_LONG = readFile('.git/head')
	        COMMIT_ID_SHORT = readFile('.git/commit').trim()
	        SERVICE_NAME = readFile('.git/image')
		}

		stage ('Docker Build') {
			withDockerRegistry([credentialsId: docker_registry_credentials, url: docker_registry_url]) {
				app = docker.build(docker_image)
				}
		}

		stage ('Docker Tag') {
			withDockerRegistry([credentialsId: docker_registry_credentials, url: docker_registry_url]) {
				app.push("${COMMIT_ID_SHORT}")
				app.push("latest")
				}
		}

		stage ('Update Properties') {
			// This is using a secret user:pass that is stored in Jenkins to talk to Artifactory
			// The PUT curl statement updates the deployed docker image by adding a gitCommit property for this build
		  withCredentials([string(credentialsId: 'artifactory-api-key', variable: 'ArtifactoryAPI')]) {
            sh "curl -X PUT -u $ArtifactoryAPI ${artifactory_api_url}/${image_name}/${COMMIT_ID_SHORT}/manifest.json?properties=gitCommit=${COMMIT_ID_LONG}"
            sh "curl -X GET -u $ArtifactoryAPI ${artifactory_api_url}/${image_name}/${COMMIT_ID_SHORT}/manifest.json?properties"
          }
		}

		stage ("Marathon-Deployment") {
		sh "./marathon.sh -i $COMMIT_ID_SHORT"
		sh "curl -X PUT http://marathon.mesos:8080/v2/apps/$app_name -d @${configJson} -H 'Content-type: application/json'"
		}
}
