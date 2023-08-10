pipeline {
    agent any
    tools {
       terraform 'terraform'
    }
	
      
    stages {
        stage('dev infrastructure') {
            when {
                branch 'dev'
            }
            steps {
                script {
							withCredentials([<object of type com.cloudbees.jenkins.plugins.awscredentials.AmazonWebServicesCredentialsBinding>]) {
							// some block
							}	
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
						withCredentials([<object of type com.cloudbees.jenkins.plugins.awscredentials.AmazonWebServicesCredentialsBinding>]) {
						// some block
					}
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
						withCredentials([<object of type com.cloudbees.jenkins.plugins.awscredentials.AmazonWebServicesCredentialsBinding>]) {
					// some block
					}
                    sh 'terraform init'
                    sh 'terraform plan -var-file="prod-terraform.tfvars"'
                    sh 'terraform apply -var-file="prod-terraform.tfvars" --auto-approve'
                }
            }
        }
    }
}
