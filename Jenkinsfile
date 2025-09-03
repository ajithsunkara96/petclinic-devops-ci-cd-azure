pipeline {
  agent any

  options {
    timestamps()
    disableConcurrentBuilds()
  }

  // No 'tools { maven ... }' needed since we use ./mvnw

  environment {
    LOCATION  = 'canadacentral'
    RG_NAME   = 'project7'                // existing RG
    PLAN_NAME = 'project7-service-plan'
    APP_NAME  = 'project7-web-app-ajs'    // must be globally unique; change if needed
    SKU_NAME  = 'S1'
  }

  triggers { githubPush() }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Build with Maven Wrapper') {
      steps {
        sh '''
          chmod +x mvnw
          ./mvnw -v || true
          ./mvnw -ntp clean package -DskipTests -Dcheckstyle.skip=true
        '''
      }
    }

    stage('Publish artifact') {
      steps {
        sh '''
          ls -l target
          JAR_PATH=$(ls target/*.jar | head -n1)
          cp "$JAR_PATH" target/project7springpetclinic.jar
        '''
        archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
      }
    }

    stage('Azure Login') {
      steps {
        withCredentials([
          usernamePassword(credentialsId: 'azure-sp', usernameVariable: 'AZ_CLIENT_ID', passwordVariable: 'AZ_CLIENT_SECRET'),
          string(credentialsId: 'azure-tenant', variable: 'AZ_TENANT_ID'),
          string(credentialsId: 'azure-subscription', variable: 'AZ_SUBSCRIPTION_ID')
        ]) {
          sh '''
            az version
            az login --service-principal -u "$AZ_CLIENT_ID" -p "$AZ_CLIENT_SECRET" --tenant "$AZ_TENANT_ID"
            az account set --subscription "$AZ_SUBSCRIPTION_ID"

            # For Terraform (AzureRM provider & backend)
            export ARM_CLIENT_ID="$AZ_CLIENT_ID"
            export ARM_CLIENT_SECRET="$AZ_CLIENT_SECRET"
            export ARM_TENANT_ID="$AZ_TENANT_ID"
            export ARM_SUBSCRIPTION_ID="$AZ_SUBSCRIPTION_ID"

            echo "Azure login OK and subscription set."
          '''
        }
      }
    }

    stage('Terraform Init/Plan/Apply') {
      steps {
        sh '''
          cd infra
          terraform -version
          terraform init -input=false
          terraform validate
          terraform plan -out=tfplan -input=false
          terraform apply -auto-approve -input=false tfplan
        '''
      }
    }

    stage('Deploy to Azure Web App') {
      steps {
        sh '''
          cd infra
          RG=$(terraform output -raw resource_group || echo "project7")
          APP=$(terraform output -raw webapp_name || echo "${APP_NAME}")
          cd ..

          az webapp deploy \
            --resource-group "$RG" \
            --name "$APP" \
            --type jar \
            --src-path target/project7springpetclinic.jar

          echo "App URL: https://$APP.azurewebsites.net"
        '''
      }
    }
  }

  post {
    success { echo '✅ Build, infra, and deployment completed successfully.' }
    failure { echo '❌ Pipeline failed. Check the stage that errored for details.' }
    // cleanWs can fail if the workspace wasn’t allocated due to early errors.
    // Re-enable after you get a clean successful run:
    // always { cleanWs(deleteDirs: true, notFailBuild: true) }
  }
}