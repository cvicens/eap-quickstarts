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
  oc apply -f ./util/${resource}
done

oc create secret generic github-creds \
  --from-literal=username=cvicens \
  --from-literal=password=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 \
  --type=kubernetes.io/basic-auth -n ${PROJECT_NAME}

oc annotate secret github-creds 'build.openshift.io/source-secret-match-uri-1=https://github.com/*' -n ${PROJECT_NAME}

oc new-app --template=eap72-basic-s2i -n ${PROJECT_NAME} \
  --as-deployment-config=false \
  --build-env MAVEN_ARGS_APPEND="-Dcom.redhat.xpaas.repo.jbossorg" \
 -p APPLICATION_NAME=kitchensink-app \
 -p IMAGE_STREAM_NAMESPACE=${PROJECT_NAME} \
 -p SOURCE_REPOSITORY_URL=https://github.com/cvicens/eap-quickstarts \
 -p SOURCE_REPOSITORY_REF=7.4.x \
 -p CONTEXT_DIR=kitchensink