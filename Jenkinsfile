pipeline {
    agent any

    environment {
        IMAGE_NAME = "jenkins-test"
        BUILD_DATE = new Date().format("yyyyMMdd")
        BUILD_NUMBER = "${env.BUILD_NUMBER}"
        IMAGE_TAG = "${BUILD_DATE}-${BUILD_NUMBER}"
        CONTAINER_NAME = "my-java-app"
    }

    stages {
        stage('Checkout') {
            steps {
                // 检出代码
                checkout scm
            }
        }

        stage('Build with Maven') {
            agent {
                docker {
                    image 'maven:3.9.9-eclipse-temurin-21'
                    args '-v $HOME/.m2:/root/.m2'
                }
            }
            steps {
                // 使用 Maven 构建项目
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                // 构建 Docker 镜像
                sh '''
                    docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                '''
            }
        }

        stage('Deploy') {
            steps {
                // 停止并移除旧的容器
                sh '''
                    docker stop ${CONTAINER_NAME} || true
                    docker rm ${CONTAINER_NAME} || true
                '''
                // 运行新的容器
                sh '''
                    docker run -d --name ${CONTAINER_NAME} -p 8123:8123 ${IMAGE_NAME}:${IMAGE_TAG}
                '''
            }
        }
    }

    post {
        always {
            // 清理未使用的 Docker 镜像
            sh 'docker image prune -f'
        }
    }
}
