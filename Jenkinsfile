pipeline {
  agent any

  triggers {
    // Проверяем изменения в Git каждые 5 минут
    pollSCM('H/5 * * * *')
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
        // Собираем только api (+ зависимости)
        sh 'mvn -B -pl api -am clean package -DskipTests'
      }
      post {
        always {
          archiveArtifacts artifacts: 'api/target/*.jar', fingerprint: true
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        // Собираем образ на основе корневого Dockerfile
        script {
          docker.build("${IMAGE_NAME}:${IMAGE_TAG}", ".")
        }
      }
    }

    stage('Load to Minikube') {
      steps {
        // Переключаемся на Docker-контекст minikube
        sh 'eval $(minikube docker-env)'
      }
    }

    stage('Push Image (optional)') {
      when {
        expression { false } // Отключено, т.к. используем локальный демоник minikube
      }
      steps {
        // docker.withRegistry('https://my.registry:5000', 'credentials-id') {
        //   docker.image("${IMAGE_NAME}:${IMAGE_TAG}").push()
        // }
      }
    }

    stage('Helm Deploy') {
      when {
        branch pattern: '^release\\/.*', comparator: 'REGEXP'
      }
      steps {
        dir('infra/helm/payment-processor-api') {
          sh """
            helm upgrade --install payment-processor-api . \
              --set image.tag=${IMAGE_TAG}
          """
        }
      }
    }
  }
}
