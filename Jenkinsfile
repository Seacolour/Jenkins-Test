pipeline {
    agent any

    environment {
        IMAGE_NAME = "jenkins-test"
        BUILD_DATE = ""               // 会在第一个 stage 里动态赋值
        BUILD_NUMBER = "${env.BUILD_NUMBER}"
        IMAGE_TAG = ""                // 由 BUILD_DATE 和 BUILD_NUMBER 拼接而成
        CONTAINER_NAME = "my-java-app"
    }

    stages {
        stage('Init') {
            steps {
                script {
                    BUILD_DATE = sh(script: "date +%Y%m%d", returnStdout: true).trim()
                    IMAGE_TAG = "${BUILD_DATE}-${BUILD_NUMBER}"
                    env.BUILD_DATE = BUILD_DATE
                    env.IMAGE_TAG = IMAGE_TAG
                    echo "Build tag: ${IMAGE_TAG}"
                }
            }
        }

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build with Maven') {
            agent {
                docker {
                    image 'registry.cn-hangzhou.aliyuncs.com/seacolour_docker/maven:3.9.9'
                    args '-v $HOME/.m2:/root/.m2'
                }
            }
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                '''
            }
        }

        stage('Deploy') {
            steps {
                sh '''
                    docker stop ${CONTAINER_NAME} || true
                    docker rm ${CONTAINER_NAME} || true
                    docker run -d --name ${CONTAINER_NAME} -p 8123:8123 ${IMAGE_NAME}:${IMAGE_TAG}
                '''
            }
        }
    }

    post {
        always {
            sh 'docker image prune -f'
        }
    }
}
