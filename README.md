## Tiny Cloud: An sample how to build package and deploy it to cloud

### Root directory structure

```txt
.
├── ci                     User Provided Service file
│   └── ups-tiny.json
├── home                   Root folder of static web contents
│   ├── css
│   ├── icon
│   ├── img
│   ├── js
│   └── index.html
├── java                   An adoptopenjdk11 minimal runtime environment will be created
├── lib                    Store tiny library jar files and some dependencies
├── virtual                Virtual host path, with some virtual host contents
│   ├── one
│   └── two
├── application-cloud.yml  Application configuration file for cloud environment
├── application-local.yml  Application configuration file for local test environment
├── build.sh               Build script file to create a minimal JRE11 about 50M
├── manifest.yml           An deployment manifest file
└── README.md              This read me file
```

### Copy some library jar files to 'lib' folder

 - Base tiny libraries without REST and JPA

```txt
export repo=~/.m2/repository
export dest=../tiny-cloud/lib
cp $repo/javax/annotation/javax.annotation-api/1.3.2/javax.annotation-api-1.3.2.jar $dest
cp $repo/net/tiny/tiny-boot/1.0.0/tiny-boot-1.0.0.jar $dest
cp $repo/net/tiny/tiny-service/1.0.0/tiny-service-1.0.0.jar $dest
```

 - Extended tiny libraries with Web Service, REST and JPA

```txt
export repo=~/.m2/repository
export dest=../tiny-cloud/lib
cp $repo/javax/ws/rs/javax.ws.rs-api/2.1.1/javax.ws.rs-api-2.1.1.jar $dest
cp $repo/net/tiny/tiny-rest/1.0.0/tiny-rest-1.0.0.jar $dest
cp $repo/net/tiny/tiny-naming/1.0.0/tiny-naming-1.0.0.jar $dest
cp $repo/net/tiny/tiny-enterprise/1.0.0/tiny-enterprise-1.0.0.jar $dest
cp $repo/net/tiny/tiny-jpa/1.0.0/tiny-jpa-1.0.0.jar $dest
cp $repo/mysql/mysql-connector-java/8.0.19/mysql-connector-java-8.0.19.jar $dest
```

### Build a openjdk11 minimal package
 - On linux to run 'build.sh', name of 'java' folder has be created. About 50M minimal JRE11 that tiny needed.
 - Download [openjdk-11+28_linux-x64_bin.tar.gz](https://download.java.net/openjdk/jdk11/ri/openjdk-11+28_linux-x64_bin.tar.gz), you can get full JRE11 about 200M
 - From [adoptopenjdk.net](https://adoptopenjdk.net/releases.html?variant=openjdk11&jvmVariant=hotspot), you can download 'OpenJDK11U-jre_x64_linux_hotspot_11.0.6_10.tar.gz', to build a smaller JRE about 120M

### Deploy a tiny application to PaaS
 - Write a manifest file for deployment (manifest.yml)

```yaml
---
applications:
- name: tiny
  buildpack: binary_buildpack
  stack: cflinuxfs3
  memory: 1G
  instances: 2
  routes:
  - route: tiny.cloud.domain
  - route: tiny-1.cloud.domain
  - route: tiny-2.cloud.domain
  command: './java/bin/java -Duser.timezone=JST -cp lib/tiny-boot-1.0.0.jar:lib/tiny-service-1.0.0.jar:lib/tiny-rest-1.0.0.jar:lib/tiny-naming-1.0.0.jar:lib/javax.ws.rs-api-2.1.1.jar:lib/javax.annotation-api-1.3.2.jar:lib/mysql-connector-java-8.0.19.jar net.tiny.boot.Main'
  env:
    profile: cloud
    TZ: Asia/Tokyo
  services:
  - ups-tiny
  - mysql-db
```

 - Write a User Provided Service file (ups-tiny.json)

```json
{
    "cf.token"    : "DES:CAhQn4bV:HIOsSQIg",
    "cf.username" : "paas",
    "cf.password" : "Piz5wX49L4MS4SYsGwEMNw=="
}
```

 - Run the next command to register a User Provided Service of name 'ups-tiny'

```txt
cf cups ups-tiny -p ci/ups-tiny.json
```

 - Run the next command to create a database service of name 'mysql-db'

```txt
cf cs mysql free mysql-db -c '{"dbname" : "mysql"}'
```


 - Run the next command to deploy a tiny application of name 'tiny'

```txt
cf push -f manifest.yml
```

 - Lookup a running tiny application information

```txt
cf app tiny
......
     state     since                  CPU    memory        disk
#0   running   2020-02-27T04:56:42Z   0.0%   60.8M of 1G   52.2M of 1G
#1   running   2020-02-27T04:56:41Z   0.0%   62.2M of 1G   52.2M of 1G
```

 - Access the running tiny web service

```txt
curl -v --insecure https://tiny.cloud.domain/health
curl -v -u paas:password http://tiny..cloud.domain/home/index.html
curl -v http://tiny-1.cloud.domain/index.html
curl -v http://tiny-2.cloud.domain/index.html
curl -u paas:password http://tiny.cloud.domain/sys/stop
```