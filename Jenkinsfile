pipeline {
    agent any
    tools {
       terraform 'terraform'
    }
    stages {
        stage('aws credential') {
            steps {
                withCredentials([
                    [
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-jenkins',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]
                ]) {
                    // This block can be left empty or you can add steps that require AWS credentials
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
