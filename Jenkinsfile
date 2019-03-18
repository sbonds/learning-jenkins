// Example from https://jenkins.io/doc/pipeline/tour/hello-world/
pipeline {
    agent { docker { image 'golang' } }
    stages {
        stage('build') {
            steps {
                sh 'go version'
            }
        }
    }
}