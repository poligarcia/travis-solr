#!/usr/bin/env bash

SOLR_PORT=${SOLR_PORT:-8983}

is_solr_up(){
    echo "Checking if solr is up on http://localhost:$SOLR_PORT/solr/admin/cores"
    http_code=`echo $(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$SOLR_PORT/solr/admin/cores")`
    return `test $http_code = "200"`
}

wait_for_solr(){
    while ! is_solr_up; do
        sleep 3
    done
}

echo "Installing solr 4.7.2"
cd /opt
sudo wget http://archive.apache.org/dist/lucene/solr/4.7.2/solr-4.7.2.tgz
sudo tar -xvf solr-4.7.2.tgz
sudo cp -R solr-4.7.2/example /opt/solr
sudo mv /opt/solr/solr/collection1 /opt/solr/solr/ckan
echo "name=ckan" | sudo tee /opt/solr/solr/ckan/core.properties
sudo wget https://raw.githubusercontent.com/ckan/ckan/ckan-2.7.4/ckan/config/solr/schema.xml -O /opt/solr/solr/ckan/conf/schema.xml
sudo wget https://raw.githubusercontent.com/datosgobar/portal-base/master/solr/jetty-logging.xml -O /opt/solr/etc/jetty-logging.xml
echo "NO_START=0\nJETTY_HOST=127.0.0.1\nJETTY_PORT=8983\nJAVA_HOME=$JAVA_HOME" | sudo tee /etc/default/jetty
# sudo java -jar /opt/solr/start.jar --daemon
sudo java -Djetty.home=/opt/solr/ -Dsolr.solr.home=/opt/solr/solr/ -jar /opt/solr/start.jar &

wait_for_solr

cd -
echo "Started solr"
