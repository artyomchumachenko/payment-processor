pipeline {
  agent any
  tools {
    maven 'M3'
  }
  environment {
    IMAGE_NAME = "payment-processor-api"
    IMAGE_TAG  = "${env.BRANCH_NAME}-${env.BUILD_NUMBER}"
  }
  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build API Module') {
      steps {
        sh 'mvn -B -pl api -am clean package -DskipTests'
      }
      post {
        always {
          archiveArtifacts artifacts: 'api/target/*.jar', fingerprint: true
        }
      }
    }
  }
}
