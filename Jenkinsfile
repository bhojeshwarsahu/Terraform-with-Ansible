pipeline {
    agent any
    tools {
       terraform 'terraform'
    }

    stages {
        stage('Set AWS Credentials') {
            steps {
                script {
                    // Retrieve AWS credentials using the credentials() function
                    def awsCredentials = credentials('aws-jenkins')

                    // Assign credentials to environment variables
                    env.AWS_ACCESS_KEY_ID = awsCredentials.accessKey
                    env.AWS_SECRET_ACCESS_KEY = awsCredentials.secretKey
                }
            }
        }

        stage('dev infrastructure') {
            when {
                branch 'dev'
            }
            steps {
                script {
                    sh 'terraform init'
                    sh 'terraform plan -var-file="dev-terraform.tfvars"'
                }
            }
        }

        stage('Staging infrastructure') {
            when {
                branch 'stage'
            }
            steps {
                script {
                    sh 'terraform init -reconfigure'
                    sh 'terraform plan -var-file="stage-terraform.tfvars"'
                    sh 'terraform apply -var-file="stage-terraform.tfvars" --auto-approve'
                }
            }
        }

        stage('Production infrastructure') {
            when {
                branch 'master'
            }
            steps {
                script {
                    sh 'terraform init'
                    sh 'terraform plan -var-file="prod-terraform.tfvars"'
                    sh 'terraform apply -var-file="prod-terraform.tfvars" --auto-approve'
                }
            }
        }
    }
}
