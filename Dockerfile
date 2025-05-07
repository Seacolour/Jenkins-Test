# ========== 第一阶段：构建 Java 应用 ==========
FROM registry.cn-hangzhou.aliyuncs.com/seacolour_docker/maven:3.9.9 AS builder

WORKDIR /build

# 拷贝项目源码（包含 pom.xml 和 src）
COPY . .

# 编译构建 jar 包（跳过测试以加快构建速度）
RUN mvn clean package -DskipTests

# ========== 第二阶段：部署 ==========
FROM registry.cn-hangzhou.aliyuncs.com/seacolour_docker/openjdk:v21

LABEL maintainer="1326192454@qq.com"

WORKDIR /app

# 只复制最终 jar 文件到生产镜像中
COPY --from=builder /build/target/*.jar app.jar

EXPOSE 8123

ENTRYPOINT ["java", "-jar", "app.jar"]
