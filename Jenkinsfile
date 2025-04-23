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

    stage('Build in JDK-21 Container') {
      agent {
        dockerContainer {
          image 'eclipse-temurin:21-jdk'  // образ с Java 21
        }
      }
      steps {
        sh 'mvn -B clean package -DskipTests'
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
