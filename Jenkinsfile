pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                echo 'Building the website...'
                sh 'ls -la'
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying website...'
                // ఇక్కడ మీ deploy కమాండ్లు వస్తాయి
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