# kubernetes 发布

## 目录结构

    - kubernetes
    - k8s-yaml
     |- helm
     |  - sandbox-java
     |- deploy
    - Dockerfile
    - README.md       

## 部署测试命令：
# windows
- helm template --release-name gateway-service k8s-yaml/helm/sandbox-java --set service.port=8899 --set containers.port=8899 --set fullnameOverride=gateway-service --set nameOverride=gateway-service --set image.repository=harbor.sandboxol.cn/china-test/gateway-service --set livenessProbe.httpGet.port=8899 --set readinessProbe.httpGet.port=8899 --set podAnnotations.prometheus\.io\/port=8899 --set extraEnvs.APP_PARAMETER="-Xms307m -Xmx307m -Xss256k" > k8s-yaml/deploy/gateway-service.yaml

