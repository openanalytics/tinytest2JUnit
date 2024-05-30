pipeline {
    agent any
    options {
        buildDiscarder(logRotator(numToKeepStr: '3'))
		authorizationMatrix inheritanceStrategy: inheritingGlobal(), permissions: ['hudson.model.Item.Build:consultants', 'hudson.model.Item.Read:consultants', 'hudson.model.Item.Cancel:consultants', 'hudson.model.Item.Workspace:consultants'] 
    }
    environment {
        IMAGE = 'tinytest2junit'
        NS = 'shared'
        REGISTRY = 'registry.openanalytics.eu'
        TAG = sh(returnStdout: true, script: "echo $BRANCH_NAME | sed -e 's/[A-Z]/\\L&/g' -e 's/[^a-z0-9._-]/./g'").trim()
        REGION = 'eu-west-1'
        NOT_CRAN = 'true'
        _R_CHECK_TESTS_NLINES_ = 0
    }
    stages {
        stage('Build Image') {
            agent {
                kubernetes {
                    yaml '''
                    apiVersion: v1
                    kind: Pod
                    spec:
                      imagePullSecrets:
                        - name: registry-robot
                      volumes:
                        - name: kaniko-dockerconfig
                          secret:
                            secretName: registry-robot
                      containers:
                      - name: kaniko
                        image: gcr.io/kaniko-project/executor:v1.21.1-debug
                        env:
                        - name: AWS_SDK_LOAD_CONFIG
                          value: "true"
                        command:
                        - /kaniko/docker-credential-ecr-login
                        - get
                        tty: true
                        resources:
                          requests:
                              memory: "1024Mi"
                          limits:
                              memory: "4096Mi"
                              ephemeral-storage: "4Gi"
                        imagePullPolicy: IfNotPresent
                        volumeMounts:
                          - name: kaniko-dockerconfig
                            mountPath: /kaniko/.docker/config.json
                            subPath: .dockerconfigjson
                    '''
                    defaultContainer 'kaniko'
                }
            }
            steps {
                container('kaniko') {
                    sh """/kaniko/executor \
                    	-v info \
                    	--context ${env.WORKSPACE} \
                    	--cache=true \
                    	--cache-ttl=8760h0m0s \
                    	--cache-repo ${env.REGISTRY}/${env.NS}/${env.IMAGE} \
                    	--cleanup \
                    	--destination ${env.REGISTRY}/${env.NS}/${env.IMAGE}:${env.TAG} \
                    	--registry-mirror ${env.REGISTRY}"""
                }
            }
        }
        stage('Packages') {
            agent {
                kubernetes {
                    yaml """
                    apiVersion: v1
                    kind: Pod
                    spec:
                      imagePullSecrets:
                        - name: registry-robot
                      containers:
                        - name: r
                          image: ${env.REGISTRY}/${env.NS}/${env.IMAGE}:${env.TAG}
                          command: 
                            - cat
                          tty: true
                          imagePullPolicy: Always
                        - name: rdepot-cli
                          command:
                            - cat
                          tty: yes
                          image: ${env.REGISTRY}/openanalytics/rdepot-cli:latest"""
                    defaultContainer 'r'
                }
            }
            stages {
                stage('tinytest2JUnit') {
                    stages {
                        stage('Roxygen') {
                            steps {
                                sh 'R -q -e \'roxygen2::roxygenize("tinytest2JUnit")\''
                            }
                        }
                        stage('Build') {
                            steps {
                                sh 'R CMD build tinytest2JUnit'
                            }
                        }
                        stage('Check') {
                            steps {
                                script() {
                                    switch(sh(script: 'ls tinytest2JUnit_*.tar.gz && R CMD check tinytest2JUnit_*.tar.gz --no-tests --no-manual', returnStatus: true)) {
                                        case 0: currentBuild.result = 'SUCCESS'
                                        default: currentBuild.result = 'FAILURE'; error('script exited with failure status')
                                    }
                                }
                            }
                        }
                        stage('Install') {
                            steps {
                                sh 'R -q -e \'install.packages(list.files(".", "tinytest2JUnit_.*.tar.gz"), repos = NULL)\''
                            }
                        }
                        stage('Test') {
                            steps {
                                dir('tinytest2JUnit') {
                                    sh 'R -q -e \'tinytest2JUnit::testPackage("tinytest2JUnit", file = file.path(getwd(), "results.xml"), at_home = TRUE)\''
                                }
                            }
                            post {
                                always {
                                    dir('tinytest2JUnit') {
                                        junit 'results.xml'
                                    }
                                }
                            }
                        }
                    }
                }
                stage('Archive artifacts') {
                    steps {
                        archiveArtifacts artifacts: '*.tar.gz, *.pdf, **/00check.log, */results.xml', fingerprint: true
                    }
                }
                stage('RDepot') {
                    when {
                        //packamon info: specify when you want your package to be submitted 
                        //see https://www.jenkins.io/doc/book/pipeline/syntax/#built-in-conditions 
                        anyOf {
                            branch 'develop'
                            branch 'master'
                        }
                    }
                    environment {
                        RDEPOT_TOKEN = credentials('jenkins-rdepot-token')
                        RDEPOT_HOST = 'https://rdepot.openanalytics.eu'
                    }
                    steps {
                        container('rdepot-cli') {
                            sh '''rdepot packages submit \
                            	-f *.tar.gz \
                            	--replace false \
                            	--repo internal'''
                        }
                    }
                }
            }
        }
    }
}

