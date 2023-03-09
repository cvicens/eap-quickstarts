export PROJECT_NAME=kitchensink-s2i-2

oc new-project ${PROJECT_NAME} 

oc replace --force -f ./util/eap72-image-stream.json

for resource in \
  eap72-amq-persistent-s2i.json \
  eap72-amq-s2i.json \
  eap72-basic-s2i.json \
  eap72-https-s2i.json \
  eap72-sso-s2i.json
do
  oc apply -f ./util/${resource}
done

oc create secret generic github-creds \
  --from-literal=username=cvicens \
  --from-literal=password=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 \
  --type=kubernetes.io/basic-auth -n ${PROJECT_NAME}

oc annotate secret github-creds 'build.openshift.io/source-secret-match-uri-1=https://github.com/*' -n ${PROJECT_NAME}

oc new-app --name=kitchensink-db \
  -e POSTGRESQL_USER=luke \
  -e POSTGRESQL_PASSWORD=secret \
  -e POSTGRESQL_DATABASE=kitchensink centos/postgresql-10-centos7 \
  --as-deployment-config=false -n ${PROJECT_NAME}

oc label deployment/kitchensink-db app.kubernetes.io/part-of=kitchensink-app --overwrite=true  -n ${PROJECT_NAME} && \
oc label deployment/kitchensink-db app.openshift.io/runtime=postgresql --overwrite=true -n ${PROJECT_NAME} 

oc new-app --template=eap72-basic-s2i -n ${PROJECT_NAME} \
  --build-env MAVEN_ARGS_APPEND="-Dcom.redhat.xpaas.repo.jbossorg" \
 -p APPLICATION_NAME=kitchensink \
 -p IMAGE_STREAM_NAMESPACE=${PROJECT_NAME} \
 -p SOURCE_REPOSITORY_URL=https://github.com/cvicens/eap-quickstarts \
 -p SOURCE_REPOSITORY_REF=7.4.x \
 -p CONTEXT_DIR=kitchensink

oc set env dc/kitchensink DB_HOST=kitchensink-db DB_PORT=5432 DB_NAME=kitchensink DB_USERNAME=luke DB_PASSWORD=secret && \
oc set probe dc/kitchensink --readiness --initial-delay-seconds=90 --failure-threshold=5 && \
oc set probe dc/kitchensink --liveness --initial-delay-seconds=90 --failure-threshold=5

oc label dc/kitchensink app.kubernetes.io/part-of=kitchensink-app --overwrite=true -n ${PROJECT_NAME} && \
oc label dc/kitchensink app.openshift.io/runtime=jboss --overwrite=true -n ${PROJECT_NAME}

# ---
# kind: ConfigMap
# apiVersion: v1
# metadata:
#   name: eap-config
#   namespace: kitchensink-s2i
# data:
#   DB_HOST: kitchensink-db
#   DB_NAME: kitchensink
#   DB_PASSWORD: secret
#   DB_PORT: '5432'
#   DB_USERNAME: luke
# ---
# apiVersion: wildfly.org/v1alpha1
# kind: WildFlyServer
# metadata:
#   name: kitchen-sink
#   namespace: kitchensink-s2i
# spec:
#   applicationImage: 'kitchensink:latest'
#   envFrom:
#     - configMapRef:
#         name: eap-config
#   replicas: 1

# oc set probe statefulset/kitchen-sink --readiness --initial-delay-seconds=90 --failure-threshold=5 && \
# oc set probe statefulset/kitchen-sink --liveness --initial-delay-seconds=90 --failure-threshold=5