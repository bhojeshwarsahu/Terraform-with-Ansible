pipeline {
    agent any


stages {
    stage('dev infrastructure') {
        when {
            branch 'dev'
        }
        steps {
            script {
					withCredentials([string(credentialsId: 'aws-jenkins', variable: 'AWS_ACCESS_KEY_ID'),
					string(credentialsId: 'aws-jenkins', variable: 'AWS_SECRET_ACCESS_KEY')]) {
					sh 'terraform init'
					sh 'terraform plan -var-file="dev-terraform.tfvars"'
				}                              
            }
        }
    }

    stage('Staging infrastructure') {
        when {
            branch 'stage'
        }
        steps {
            script {
					withCredentials([string(credentialsId: 'aws-jenkins', variable: 'AWS_ACCESS_KEY_ID'),
					string(credentialsId: 'aws-jenkins', variable: 'AWS_SECRET_ACCESS_KEY')]) {
					sh 'terraform init -reconfigure'
					sh 'terraform plan -var-file="stage-terraform.tfvars"'
					sh 'terraform apply -var-file="stage-terraform.tfvars" --auto-approve'
				}                              
            }
        }
    }

    stage('Production infrastructure') {
        when {
            branch 'master'
        }
        steps {
            script {
					withCredentials([string(credentialsId: 'aws-jenkins', variable: 'AWS_ACCESS_KEY_ID'),
					string(credentialsId: 'aws-jenkins', variable: 'AWS_SECRET_ACCESS_KEY')]) {
					sh 'terraform init'
					sh 'terraform plan -var-file="prod-terraform.tfvars"'
					sh 'terraform apply -var-file="prod-terraform.tfvars" --auto-approve'
				}                              
            }
			}
		}
	}
}
