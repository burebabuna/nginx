#!/usr/bin/env groovy
def scm_url = "git@bitbucket.org:fractalindustries/nginx-version-test"
def scm_branch = "master"
def docker_registry_url = "https://fractal-docker-fos-prod-bintray.io"
def docker_image = "fractal-docker-fos-prod-bintray.io/nginx-version-test"

def scm_credentials = "dcos-jenkins"
def docker_registry_credentials = "dcos-jenkins-bintray"

def jenkins_slave = "mesos"
def marathon_url = "env.MARATHON_URL == null ? 'http://marathon.mesos:8080' : env.MARATHON_URL"

def marathon_file_path = "marathon.json"
def marathon_app_id = "nginx-version-test"

def env = System.getenv()


node ( jenkins_slave ) {

	stage ('Checkout') {
		git url: scm_url, branch: scm_branch, credentialsId: scm_credentials
	}

	stage ('Docker') {
		withDockerRegistry([credentialsId: docker_registry_credentials, url: docker_registry_url]) {
			def COMMIT_ID = sh(script: "git rev-parse HEAD", returnStdout: true).trim()

		stage "Docker-Build"
			docker.build(docker_image)
	
		stage "Docker-Push"		
			app.push "$COMMIT_ID"
		}
	}

	stage ('Marathon-Deployment') {
		sh "./marathon.sh -i=$COMMIT_ID"
		sh "curl -X PUT ${marathon_url}/v2/apps/${marathon_app_id} -d @${marathon_file_path} -H 'Content-type: application/json"
	}
}


