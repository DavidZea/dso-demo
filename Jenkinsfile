pipeline {
  agent {
    kubernetes {
      yamlFile 'build-agent.yaml'
      defaultContainer 'maven'
      idleMinutes 1
    }
  }
  stages {
    stage('Build') {
      parallel {
        stage('Compile') {
          steps {
            container('maven') {
              sh 'mvn compile'
            }
          }
        }
      }
    }
    stage('Static Analysis') {
      parallel {
        stage('Unit Tests') {
          steps {
            container('maven') {
              sh 'mvn test'
            }
          }
        }
        stage('SCA') {
          steps {
            container('maven') {
              catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                // Forzamos la versión 10.0.4 y desactivamos el OSS Index que arrojaba error 401
                sh 'mvn org.owasp:dependency-check-maven:10.0.4:check -DossindexAnalyzerEnabled=false -DassemblyAnalyzerEnabled=false'
              }
            }
          }
          post {
            always {
              // Eliminamos onlyIfSuccessful para que el reporte se archive siempre, falle o pase el análisis
              archiveArtifacts allowEmptyArchive: true, artifacts: 'target/dependency-check-report.html', fingerprint: true
            }
          }
        }
        // MODIFICACIÓN: Movido aquí (dentro del bloque parallel de Static Analysis)
        stage('OSS License Checker') {
          steps {
            container('licensefinder') {
              catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') { 
                sh 'ls -al'
                sh '''#!/bin/bash --login
                rvm use default
                gem install license_finder --no-document
                license_finder
                '''
              }
            }
          }
        }
      }
    }
    stage('Package') {
      parallel {
        stage('Create Jarfile') {
          steps {
            container('maven') {
              sh 'mvn package -DskipTests'
            }
          }
        }
        stage('OCI Image BnP') {
          steps {
            container('kaniko') {
              sh '/kaniko/executor -f `pwd`/Dockerfile -c `pwd` --insecure --skip-tls-verify --cache=true --destination=docker.io/piedraver/dso-demo'
            }
          }
        }
      }
    }

    stage('Deploy to Dev') {
      steps {
        // TODO
        sh "echo done"
      }
    }
  }
}
