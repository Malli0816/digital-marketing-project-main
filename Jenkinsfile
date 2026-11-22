pipeline {
    agent any

    environment {
        IMAGE_NAME = "digital-marketing"
        CONTAINER_NAME = "digital-marketing-container"
        PORT = "8081"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build --no-cache \
                    -t ${IMAGE_NAME}:${BUILD_NUMBER} .
                '''
            }
        }

        stage('Test New Image') {
            steps {
                sh '''
                    docker rm -f dm-test 2>/dev/null || true
                    trap 'docker rm -f dm-test 2>/dev/null || true' EXIT

                    docker run -d \
                    --name dm-test \
                    -p 127.0.0.1:18081:80 \
                    ${IMAGE_NAME}:${BUILD_NUMBER}

                    sleep 3

                    curl -f http://127.0.0.1:18081/

                    docker rm -f dm-test
                '''
            }
        }

        stage('Deploy to Docker') {
            steps {
                sh '''
                    docker rm -f ${CONTAINER_NAME} 2>/dev/null || true

                    docker run -d \
                    --name ${CONTAINER_NAME} \
                    --restart unless-stopped \
                    -p ${PORT}:80 \
                    ${IMAGE_NAME}:${BUILD_NUMBER}
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                sh '''
                    sleep 3
                    curl -f http://127.0.0.1:${PORT}/
                    docker ps
                '''
            }
        }
    }
}
