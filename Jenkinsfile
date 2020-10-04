podTemplate(label: 'dind-pod', containers: [
  containerTemplate(name: 'docker', image: 'warriortrading/jenkins-agent:1.0.0', ttyEnabled: true, alwaysPullImage: true, privileged: true,
    command: 'dockerd --host=unix:///var/run/docker.sock --host=tcp://0.0.0.0:2375 --storage-driver=overlay')
],
volumes: [emptyDirVolume(memory: false, mountPath: '/var/lib/docker')]) {
    node('dind-pod') {
        properties([disableConcurrentBuilds()])

        ///////////////////////////////////////////////////////////////////////////////
        // [REST] Pls reset these variables when copy to other repos
        def repo_name = 'warriortrading.chiron.monitor.web'
        def image_name = "chiron.monitor.web"
        ///////////////////////////////////////////////////////////////////////////////


        // ============================================================================
        // [FIXED] Pls DONNOT reset these variables when copy to other repos unless you are sure

        // ********* NOTE: variables below are paired  *********************
        def github_credentialsId = 'github-puller-jacky'
        def github_username = 'jacky-nirvana'
        // *****************************************************************

        def dockerhub_credentialsId = 'docker-registry'

        // ********* NOTE: variables below are paired  *********************
        def aws_credentialsId = 'passport-of-us-east-2'
        def aws_region = 'us-east-2'
        // *****************************************************************

        // ============================================================================

        // docker image settings
        // def branch_name='dev' // for testing
        def branch_name_mapping = [
            "dev": "DEV",
            "qa": "QA",
            "stage": "STAGE",
            "prod": "PROD",
            "recovery": "RECOVERY",
            "image": "IMAGE",
            "jenkins": "JENKINS",
            ]
        def branch_tag = branch_name_mapping[branch_name]
        def image_tag = "${branch_tag}-${env.BUILD_ID}"

        stage('1. checkout code, build & push image and tag repo') {
            container('docker') {
                echo "start ===> 1. checkout code, build image, push image and tag repo"

                withCredentials([
                    usernamePassword(credentialsId: github_credentialsId, passwordVariable: 'GITHUB_ACCESS_TOKEN', usernameVariable: 'GITHUB_ACCESS_USR'),
                    usernamePassword(credentialsId: dockerhub_credentialsId, passwordVariable: 'DOCKER_REGISTRY_PW', usernameVariable: 'DOCKER_REGISTRY_USER'),
                    usernamePassword(credentialsId: aws_credentialsId, passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')
                    ]) {
                    dir(repo_name) {
                        // 1.1. checkout code
                        echo "start ===> 1.1. checkout code"
                        git branch: branch_name,
                            credentialsId: github_credentialsId,
                            url: "https://github.com/WarriorTrading/${repo_name}.git";

                        // 1.2. build & push image
                        echo "start ===> 1.2. build & push image"

                        // ============================================================================
                        // [FIXED] Pls DONNOT reset these variables when copy to other repos unless you are sure
                        BUILD_ARGS="GITHUB_ACCESS_USR=${GITHUB_ACCESS_USR};GITHUB_ACCESS_TOKEN=${GITHUB_ACCESS_TOKEN};AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID};AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY};AWS_REGION=${aws_region}"
                        // ============================================================================

                        sh "bash /scripts/build_and_push_image.sh -f . -n ${image_name} -t ${image_tag} -u ${DOCKER_REGISTRY_USER} -p ${DOCKER_REGISTRY_PW} -b \"${BUILD_ARGS}\""

                        // 1.3. tag repo
                        echo "start ===> 1.3. tag repo"
                        sh "git config --global hub.protocol https"
                        sh "git remote set-url origin https://${GITHUB_ACCESS_TOKEN}:x-oauth-basic@github.com/WarriorTrading/${repo_name}.git"
                        sh "git config --global user.email \"${GITHUB_ACCESS_USR}\""
                        sh "git config --global user.name \"${github_username}\""

                        sh "bash /scripts/add_git_tag.sh -t ${image_tag}"
                    }
                }
                echo "finish ===> 1. checkout code, build image, push image and tag repo"
            }
        }
    }
}
