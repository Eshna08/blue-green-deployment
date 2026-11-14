pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Eshna08/blue-green-deployment.git'
            }
        }

        stage('Select Environment') {
            steps {
                script {
                    def active = sh(
                        script: "grep -o '127.0.0.1:808[23]' /etc/nginx/sites-available/experiment2",
                        returnStdout: true
                    ).trim()

                    env.TARGET = active.endsWith('8082') ? 'green' : 'blue'
                    env.PORT = env.TARGET == 'blue' ? '8082' : '8083'
                    env.FILE = env.TARGET == 'blue' ? 'blue.html' : 'green.html'
                    env.IMAGE = "${env.TARGET}-website:build-${env.BUILD_NUMBER}"
                    env.CONTAINER = "${env.TARGET}-container"

                    echo "Deploying ${env.TARGET.toUpperCase()} environment"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build --build-arg SITE_FILE=${FILE} -t ${IMAGE} .'
            }
        }

        stage('Deploy Inactive Environment') {
            steps {
                sh '''
                    docker rm -f ${CONTAINER} || true
                    docker run -d --name ${CONTAINER} -p ${PORT}:80 ${IMAGE}
                    sleep 3
                    curl -f http://localhost:${PORT}
                '''
            }
        }

        stage('Switch Traffic') {
            steps {
                sh '''
                    sudo sed -i "s/127.0.0.1:808[23]/127.0.0.1:${PORT}/" \
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
