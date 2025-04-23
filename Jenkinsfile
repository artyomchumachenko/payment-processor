pipeline {
  agent {
      docker {
        image 'eclipse-temurin:21-jdk'  // или другой образ JDK 21
        args  '-u root'                // если нужны root-права
      }
    }
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

    stage('Minikube & Build Image') {
      steps {
        sh """
          # 1) Запустить (либо убедиться, что запущен) Minikube
          minikube start

          # 2) Построить образ прямо в Minikube
          minikube image build \
            --file=./Dockerfile \
            -t ${IMAGE_NAME}:${IMAGE_TAG} \
            .
        """
      }
    }

    stage('Helm Deploy') {
      when {
        branch pattern: '^release\\/.*', comparator: 'REGEXP'
      }
      steps {
        dir('infra/helm/payment-processor-api') {
          sh """
            # Убедиться, что kubectl смотрит на Minikube
            kubectl config use-context minikube

            helm upgrade --install payment-processor-api . \
              --set image.tag=${IMAGE_TAG}
          """
        }
      }
    }
  }
}
