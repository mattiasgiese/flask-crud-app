def withDockerNetwork(Closure inner) {
  try {
    networkId = UUID.randomUUID().toString()
    sh "docker network create ${networkId}"
    inner.call(networkId)
  } finally {
    sh "docker network rm ${networkId}"
  }
}

pipeline {

  agent { label 'docker' }

  parameters {
    string(name: 'dbuser', defaultValue: 'bookstore', description: 'Database user')
    string(name: 'dbpass', defaultValue: 'bookstore', description: 'Database password')
    string(name: 'dbname', defaultValue: 'bookstore', description: 'Database name')
    choice(name: 'dbtype', choices: ['sqlite', 'mysql+pymysql', 'postgres'], description: 'Database type')
    string(name: 'dbfile', defaultValue: 'test/test.db', description: 'Database file if sqlite is used')
    booleanParam(name: 'create_db', defaultValue: true, description: 'Whether or not to create the DB')
  }

  environment {
       // URL may not be used:
       // you tried to assign a value to the class 'java.net.URL'
       APPURL = 'http://frontend:5000'
       // listen address of our application
  }

  stages {
    stage("test") {

      steps {
        script {

          def db_image = [
            "mysql+pymysql": "mariadb:10",
            "postgres": "postgres:latest",
          ]

          def docker_opts = [
            "mysql+pymysql": "-e 'MYSQL_RANDOM_ROOT_PASSWORD=yes' -e 'MYSQL_DATABASE=${dbname}' -e 'MYSQL_USER=${dbuser}' -e 'MYSQL_PASSWORD=${dbpass}'",
            "postgres": "-e 'POSTGRES_PASSWORD=${dbpass}' -e 'POSTGRES_USER=${dbuser}' -e 'POSTGRES_DB=${dbname}'",
          ]

          def database = docker.image(db_image."$dbtype")
          def frontend = docker.build("frontend")
          db_opts = docker_opts."$dbtype"

          // first arg is image name
          // second arg is dir with Dockerfile
          def tester = docker.build("frontend-tester", "test")

          if ( dbtype == 'sqlite' ) {
            database_uri = "${dbtype}:///${dbfile}"
          }
          else {
            database_uri = "${dbtype}://${dbuser}:${dbpass}@database/${dbname}"
          }

          withDockerNetwork{ n ->
            database.withRun("--network ${n} --name database ${db_opts}")
            { c ->
              frontend.withRun("--name frontend --network ${n} -e 'LISTEN_ADDRESS=0.0.0.0' -e 'DATABASE_URI=${database_uri}'") {
                // prepare database
                frontend.inside("--network ${n} -e 'LISTEN_ADDRESS=0.0.0.0' -e 'DATABASE_URI=${database_uri}'") {
                  sh 'test/wait-for-db.sh'
                  sh "python prepare_db.py"
                }
                // run all tests
                tester.inside("--network ${n}") {
                  sh "bash test/test-crud.sh"
                }
              }
            }
          }
        }
      }
    }
  }
}
