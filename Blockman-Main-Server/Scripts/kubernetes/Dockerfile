FROM harbor.sandboxol.cn/china-test/base:latest
ARG app
ARG environment
env AppEnvironment=$environment
env App=$app
ADD ${app}-0.0.1-SNAPSHOT.jar /root/${app}-0.0.1-SNAPSHOT.jar
CMD ["/usr/bin/java", "-jar", "-Dfile.encoding=UTF-8", "-Dspring.profiles.active=$AppEnvironment", "/root/$App-0.0.1-SNAPSHOT.jar"]
