pipeline {
    agent none
    environment {
        SNYK_CREDENTIALS = credentials('SnykToken')
    }

    stages {
        stage('Checkout Source') {
            agent any
            steps {
                checkout scm
            }
        }

        stage('SCA - Snyk Docker Image') {
            agent {
                docker {
                    image 'snyk/snyk:docker'
                    args '--user root --network host -v /var/run/docker.sock:/var/run/docker.sock --env SNYK_TOKEN=$SNYK_CREDENTIALS_PSW --entrypoint='
                }
            }
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    sh '''
                        echo "🔨 Building Docker image vuln-bank:latest..."
                        docker build -t vuln-bank:latest .

                        echo "🔎 Running Snyk Docker scan..."
                        snyk test --docker vuln-bank:latest --json > snyk-sca-docker-report.json
                    '''
                }
                sh 'cat snyk-sca-docker-report.json || true'
                archiveArtifacts artifacts: 'snyk-sca-docker-report.json'
            }
        }
    }

    post {
        always {
            script {
                def critical = sh(script: "grep -i 'critical' snyk-sca-docker-report.json || true", returnStatus: true)
                if (critical == 0) {
                    echo "⚠️ CRITICAL vulnerability found in Vuln Bank pipeline build #${env.BUILD_NUMBER}"
                } else {
                    echo "✅ No CRITICAL vulnerabilities detected in this build."
                }
            }
        }
    }
}
