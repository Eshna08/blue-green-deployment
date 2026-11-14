
pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Eshna08/blue-green-deployment.git'
            }
        }

        stage('Build Green Image') {
            steps {
                sh 'docker build -t green-website:build-${BUILD_NUMBER} .'
            }
        }

        stage('Deploy Green Container') {
            steps {
                sh '''
                    docker rm -f green-container || true
                    docker run -d --name green-container \
                    -p 8083:80 \
                    green-website:build-${BUILD_NUMBER}
                '''
            }
        }

        stage('Switch Traffic to Green') {
            steps {
                sh '''
                    sudo sed -i 's/127.0.0.1:8082/127.0.0.1:8083/' \
                    /etc/nginx/sites-available/experiment2

                    sudo nginx -t
                    sudo systemctl reload nginx
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                sh 'curl -f http://localhost:8084'
            }
        }
    }
}
