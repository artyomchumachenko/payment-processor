pipeline {
  agent { label 'docker' }              // узел с установленным Docker
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

    stage('Prepare Minikube Docker Env') {
      steps {
        // Запускаем Minikube (если ещё не запущен) и переключаемся на его Docker-демон
        sh '''
          minikube start
          eval $(minikube docker-env)
        '''
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

    stage('Build & Load Docker Image') {
      steps {
        // Собираем образ прямо в Minikube
        sh '''
          docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
        '''
      }
    }

    stage('Helm Deploy') {
      when {
        branch pattern: '^release\\/.*', comparator: 'REGEXP'
      }
      steps {
        dir('infra/helm/payment-processor-api') {
          // Убедимся, что kubectl использует контекст Minikube
          sh '''
            kubectl config use-context minikube
            helm upgrade --install payment-processor-api . \
              --set image.tag=${IMAGE_TAG}
          '''
        }
      }
    }
  }
}
