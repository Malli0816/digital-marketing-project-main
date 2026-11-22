pipeline {
    agent any

    environment {
        IMAGE_NAME = "digital-marketing"
        CONTAINER_NAME = "digital-marketing-container"
        PORT = "8082"
        PUBLIC_URL = "http://20.51.161.93:8082/"
    }

    stages {
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
                    curl --fail --silent --show-error --output /dev/null \
                        http://127.0.0.1:18081/
                '''
            }
        }

        stage('Deploy to Docker') {
            steps {
                sh '''
                    docker rm -f "${CONTAINER_NAME}" 2>/dev/null || true

                    conflicts=$(docker ps --filter "publish=${PORT}" --format '{{.ID}}')
                    for container_id in $conflicts; do
                        name=$(docker inspect --format '{{.Name}}' "$container_id")
                        name=${name#/}
                        image=$(docker inspect --format '{{.Config.Image}}' "$container_id")
                        image_name=${image%:*}

                        if [ "$name" = "${CONTAINER_NAME}" ] || [ "$image_name" = "${IMAGE_NAME}" ]; then
                            echo "Removing previous Digital Marketing container: ${name} (${image})"
                            docker rm -f "$container_id"
                        else
                            echo "Port ${PORT} is occupied by unrelated container: ${name} (${image}). Refusing to remove it."
                            exit 1
                        fi
                    done

                    if command -v ss >/dev/null 2>&1; then
                        ss -ltnp "sport = :${PORT}"
                    fi

                    docker run -d \
                        --name "${CONTAINER_NAME}" \
                        --restart unless-stopped \
                        -p ${PORT}:80 \
                        ${IMAGE_NAME}:${BUILD_NUMBER}
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                sh '''
                    curl --fail --silent --show-error --output /dev/null \
                        --retry 10 --retry-connrefused --retry-delay 2 --max-time 5 \
                        http://127.0.0.1:${PORT}/
                    curl --fail --silent --show-error --output /dev/null \
                        --retry 10 --retry-connrefused --retry-delay 2 --max-time 5 \
                        "${PUBLIC_URL}"
                    docker ps
                '''
            }
        }
    }

    post {
        success {
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
