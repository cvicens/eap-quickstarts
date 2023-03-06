export PROJECT_NAME=kitchensink-s2i

oc new-project ${PROJECT_NAME} 


oc replace --force -f ./util/eap72-image-stream.json

for resource in \
  eap72-amq-persistent-s2i.json \
  eap72-amq-s2i.json \
  eap72-basic-s2i.json \
  eap72-https-s2i.json \
  eap72-sso-s2i.json

do
  oc apply -f https://raw.githubusercontent.com/jboss-container-images/jboss-eap-7-openshift-image/7.2.x/templates/${resource}
done


oc create secret generic github-creds \
  --from-literal=username=cvicens \
  --from-literal=password=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 \
  --type=kubernetes.io/basic-auth -n ${PROJECT_NAME}

oc annotate secret github-creds 'build.openshift.io/source-secret-match-uri-1=https://github.com/*' -n ${PROJECT_NAME}

oc new-app --template=eap72-basic-s2i -n ${PROJECT_NAME} \
  --as-deployment-config=false \
  --build-env MAVEN_SETTINGS_XML="/tmp/src/ext-lib/m2/settings.xml" \
  --build-env ARTIFACT_DIR="arco-saer-app/arco-saer-app-ear/target" \
  --build-env MAVEN_ARGS="-e -P openshift,linea-singleton,linea -DskipTests -Dcom.redhat.xpaas.repo.redhatga clean install" \
 -p APPLICATION_NAME=arco-saer-app \
 -p IMAGE_STREAM_NAMESPACE=${PROJECT_NAME} \
 -p SOURCE_REPOSITORY_URL=https://github.com/cvicens/arco-saer-cde-mig \
 -p SOURCE_REPOSITORY_REF=s2i \
 -p CONTEXT_DIR=.