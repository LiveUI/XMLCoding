pipeline {
  agent none
  options {
    timeout(time: 15, unit: 'MINUTES')
  }

  stages {
    stage('Builds') {
        parallel {
            stage('Build MacOS') {
              agent {
                label 'mac'
              }
              when {
                anyOf {
                  branch 'master'
                }
              }
              steps {
                script {
                  sh 'swift test'
                }
              }
            }

            stage('Build Linux (Docker)') {
              agent any
              when {
                anyOf {
                  branch 'master'
                }
              }
              steps {
                script {
                  sh './scripts/docker-shortcuts/test.sh'
                }
              }
            }
        }
    }
  }
}
