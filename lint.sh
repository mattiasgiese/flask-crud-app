USER=tux
PASS=b1systems
JENKINS_URL=${1:-http://jenkins.training.b1}
JENKINS_CRUMB=`curl -u ${USER}:${PASS} "$JENKINS_URL/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,\":\",//crumb)"`
curl -u ${USER}:${PASS} -X POST -H $JENKINS_CRUMB -F "jenkinsfile=<Jenkinsfile" $JENKINS_URL/pipeline-model-converter/validate
