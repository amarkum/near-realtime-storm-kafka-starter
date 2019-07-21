
# Storm Kafka NRT Onboarding Project
This guide has the necessary steps that you can to take to setup all the tools and utilities required for this project.

**Problem Statement**
A supermarket has as many as 4 floors, a customer can shop in either 1 or all the floors.
The data for this will be stored into a `MySQL` database in a simple `customer` table.
A `customer` table has `columns` which has basic details of the customer, and purchase amount of each floor.
The goal is to create and deploy a storm topology which reads any new transaction carried out in `MySQL` database through  `kafka topic` by pre-defined `KafkaSpout` class.
Read all the transaction on each floor, Log a message on the console about the total amount a customer has to pay. If he is a star member, he gets 15% discount on total purchase.
`customer` table has `is_star` column as `boolean` to signify the membership.
Also, save the data into `flux` table.

**Output**
`Robert is a star member, final purchase amount is $1872.` \
Now, when a new record gets inserted into the `customer` table, Storm should be able to `emit` the purchase message as above.

**Kafka Spout Configuration**

```java
Config stormConfig = new Config();  
stormConfig.put(Config.TOPOLOGY_MAX_SPOUT_PENDING, 1);  
String zkConnString = "localhost:2181";  
String topic = "kafkatopic-customer";  
BrokerHosts hosts = new ZkHosts(zkConnString);  
SpoutConfig kafkaSpoutConfig = new SpoutConfig(hosts, topic, "/" + topic,  
  UUID.randomUUID().toString());  
final TopologyBuilder topologyBuilder = new TopologyBuilder();    
topologyBuilder.setSpout("kafka-spout", new KafkaSpout(kafkaSpoutConfig), 1);
```
The `kafkatopic-customer` is a Kafka topic where new messages will be written whenever there is an update to `MySQL` table.

# How To setup a Kafka Topic which listen changes to MySQL Table

The simplest way is to have `MySQL` table created already and connect it via `KafkaConnect` using `Confluent`

## Setting up MySQL
Install MySQL using
```
$ brew install mysql@5.7
```
Start the mysql service
```
service mysql@5.7 start
```
`MySQL` will be installed with a single user `root`  with NO password.
Also, make sure the `mysql\bin` exists in System's `PATH` 
 Run the secure installation and set the password of the user `root`
 ```
$ mysql_secure_installation
```

Login to mysql
```
$ mysql -u root -p
```

To Create the Database
```
mysql> CREATE DATABASE customerdb;
mysql> USE customerdb;
```

Load Queries into db from files
```
$ mysql -u root -p customerdb < customer.sql
```
You can find `customer.sql` in the `nrt-onboard/resources/` directory

OR Execute the below `Query`.

```SQL
DROP TABLE IF EXISTS `customer`;
CREATE TABLE `customer` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `is_star` tinyint(1) NOT NULL,
  `fullname` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `firstname` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `lastname` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `city` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `state` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `floor1` double DEFAULT NULL,
  `floor2` double DEFAULT NULL,
  `floor3` double DEFAULT NULL,
  `floor4` double DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `customer` (`id`, `is_star`, `fullname`, `firstname`, `lastname`, `city`, `state`, `floor1`, `floor2`, `floor3`, `floor4`) VALUES 
('11', '1', 'Sade Morgan', 'Sade', 'Morgan', 'Mont', 'Bolivia', '558', '737', '1752', '1569'),
('12', '0', 'Edan . Cabrera', 'Edan', 'Cabrera', 'Bareilly', 'Burundi', '1162', '1860', '1821', '2526'),
('13', '1', 'Anika X. Cantu', 'Anika X.', 'Cantu', 'Rutten', 'Iceland', '1756', '2282', '272', '3007'),
('14', '1', 'Isaiah F. Cochran', 'Isaiah F.', 'Cochran', 'Ladispoli', 'Andorra', '3416', '5148', '1318', '3124'),
('15', '1', 'Ian Barnett', 'Reuben', 'Ian Barnett', 'Reuben', 'Tuvalu', '88', '370', '1885', '3347'),
('16', '1', 'Autumn Camacho', 'Autumn', 'Camacho', 'Patan', 'Turks and Caicos Islands', '3363', '1139', '1178', '123'),
('17', '0', 'Leroy Q. Griffin', 'Leroy Q.', 'Griffin', 'Mobile', 'Burundi', '3475', '5220', '934', '3417'),
('18', '0', 'Macy Grant', 'Myles', 'Macy Grant', 'Myles', 'Cameroon', '939', '5427', '418', '803'),
('19', '0', 'Ann L. Walters', 'Heidi', 'Ann L. Walters', 'Heidi', 'New Caledonia', '2790', '3386', '1679', '1393'),
('20', '0', 'Tara Juarez', 'Lee', 'Tara Juarez', 'Lee', 'Indonesia', '1192', '4240', '1437', '1841');
```

# Setting up Confluent
`Confluent` is a tool that start  `Kafka` and `zookeeper` services instantly and helps you minimising the steps required to connect  a datasource e.g `MySQL` with `KafkaConnect`.
`Confluent` can be used instead of manually installing and setting up each packages.

#### Download and Extract
Download the latest binary distribution of [confluent](https://www.confluent.io/download/) \
Extract the tar.gz file in your home directory and rename it simply as `confluent`  
```
$ tar xf confluent-5.2.1-2.12.tar.gz
```
To start the Confluent Platform use
```
$ cd ~/confluent
$ ./bin/confluent start

This CLI is intended for development only, not for production
https://docs.confluent.io/current/cli/index.html

Using CONFLUENT_CURRENT: /tmp/confluent.5j9IM8Vb
Starting zookeeper
zookeeper is [UP]
Starting kafka
kafka is [UP]
Starting schema-registry
schema-registry is [UP]
Starting kafka-rest
kafka-rest is [UP]
Starting connect
connect is [UP]
Starting ksql-server
ksql-server is [UP]
Starting control-center
control-center is [UP]
```

In order for confluent to connect to `MySQL`  it would require `MySQL Connector JAR`
Download this [tar.gz](https://dev.mysql.com/downloads/connector/j/5.1.html) and place the `mysql-connector-java-*.*.**.jar` in `share/java/kafka-connect-jdbc` \
You can also use `mysql-connector-java-5.1.47.jar` present in project's `resources` directory.

**Create a JSON Configuration file.**

Create a  configuration file  `mysql_kafka_connect_conf.json` in your `home` directory.
`/User/<your_id>/jdbc_mysql_kafka_connect_conf.json`
```j
{
    "name": "jdbc_mysql_kafka_connect",
        "config": {
                "connector.class": "io.confluent.connect.jdbc.JdbcSourceConnector",
                "key.converter": "org.apache.kafka.connect.json.JsonConverter",
                "key.converter.schema.registry.url": "http://localhost:8081",
                "value.converter": "org.apache.kafka.connect.json.JsonConverter",
                "value.converter.schema.registry.url": "http://localhost:8081",
		"value.converter.schemas.enable": "false",
                "connection.url": "jdbc:mysql://localhost:3306/customerdb?user=root&password=<YourPassword>",
                "table.whitelist": "customer",
                "mode": "timestamp",
                "validate.non.null": "false",
                "topic.prefix": "kafkatopic-"
        }
}
```
Run the below command to load the configuration as per the `MySQL` database
```
$ ./bin/confluent load jdbc_mysql_kafka_connect -d /Users/<your_id>/jdbc_mysql_kafka_connect_conf.json
```

Use this command to check the status if the it is able to establish a connection with `kafka-connect` 
```
$ ./bin/confluent status jdbc_mysql_kafka_connect
```
A `topic` will be created instantly with mentioned `prefix` in JSON file.
If the above command shows status as `RUNNING`, a topic would would have been created.

```
$ ./bin/kafka-topics --list --zookeeper localhost:2181
```

The above commands lists the `kafka topics` that have been created \
`kafkatopic-customer` should be be a listed topic

Alternatively Go to : http://localhost:9021/ 
`Confluent` UI to see if the topic is listed out there.

To read the message from `Kafka` topic, use the `kafka-console-consumer`.
```java 
./bin/kafka-console-consumer \
--bootstrap-server localhost:9092 \
--property schema.registry.url=http://localhost:8081 \
--property print.key=true \
--from-beginning \
--topic kafkatopic-customer
```

You will instantly be able to see the records which has been inserted already into the database.
Try adding one more `row` to the `customer` table, you will instantly be able to see the updates in the terminal `encoded` in `JSON` format, as we are using a JSON serialiser to write output to	 Kafka topic  `org.apache.kafka.connect.json.JsonConverter`.

### Troubleshooting confluent

More information regarding confluent MySQL can be found [here](https://www.confluent.io/blog/simplest-useful-kafka-connect-data-pipeline-world-thereabouts-part-1/)


# How to setup a Storm Local Cluster 
**Pre-requisites**

1) **Create a data folder**\
In the home directory, created a folder `/data`, where we will be storing data for all the frameworks.\
for storm, say create a subfolder `/storm` into `/data` folder.\
e.g.`/Users/ab012345/data/storm/` 

We can create the same for zookeeper and Kafka , if want to store processing files.
Since, `confluent` runs `zookeeper` and `kafka` service from confluent directory we may choose not to create it

<image src="https://i.ibb.co/sm9pGLg/01-dirs.png" width="300" height="120">

`Storm` and `Kafka` both needs `zookeeper` for synchronisation service.
So, in order to setup local cluster of storm and Kafka we must have `zookeeper` installed up and running.
If you have started `zookeeper` via `confluent` me may skip the manual install and run process of zookeeper.


## How to configure IntelliJ to run storm topology examples.
Storm comes loaded with sample examples of topology; you can find these in the `storm/examples/` \
We will be creating a maven build on `storm-starter` example,
storm-starter is a very basic topology to help you understand how topology is created and deployed.

1) Import the `storm-starter` folder, (Project SDK should use jdk 1.7-1.8)
2) Remove the `<scope>\${provided.scope}</scope>` from `pom.xml`, as this will enable to compile dependency on build. 
Change it to `<scope>compile</scope>`
```
<!-- 
Use "provided" scope to keep storm out of the jar-with-dependencies
For IntelliJ dev, intellij will load properly.
-->
<scope>${provided.scope}</scope>
```
3) Run any Topology Main Class e.g WordCountTopology
4) To deploy it on the real single storm cluster,
Change the scope to `<scope>provided</scope>` 
run `mvn clean install`
 In `/target` directory copy the `JAR` and

**To Deploy topology in Local Cluster**
```
$ storm jar <jarname> <package.topology-classname> simple-topology-identifier
```


## How to install and run zookeeper services (Manual installation)

#### Download and Extract
Download the latest binary distribution of [zookeeper](https://www.apache.org/dyn/closer.cgi/zookeeper/)\
e.g. [zookeeper-3.4.14.tar.gz](http://mirrors.estointernet.in/apache/zookeeper/zookeeper-3.4.14/zookeeper-3.4.14.tar.gz)

1) Unzip it to your home folder e.g. `(/Users/ak054561/)` through MacOS default extract utility or you may use relevant command line tools to extract.
2) Rename the folder to `zookeeper` from `zookeeper.XX.XX.XX`
3) Create a new file in `zookeeper/conf/` folder as `zoo.cfg` and paste in the below configuration.
```
tickTime = 2000
dataDir=/Users/<username>/data/zookeeper
clientPort = 2181
initLimit = 5
syncLimit = 2
```
4) provide the data directory for zookeeper which you created at start.
5) Open up a terminal, navigate to zookeeper folder using
```
$ cd ~
$ cd zookeeper
$ bin/zkServer.sh start &
```
This will start zookeeper server, open up a new terminal, navigate to
zookeeper folder again, and start zookeeper client by\
```
$ bin/zkCli.sh start &
```
**Let the Terminal open and service up and running.**


## How to install and run storm

#### Download and Extract
Download the latest binary distribution of [storm](https://www.apache.org/dyn/closer.lua/storm/) \
e.g.[apache-storm-1.2.2.zip](http://mirrors.estointernet.in/apache/storm/apache-storm-1.2.2/apache-storm-1.2.2.zip)


1) Unzip it to your home folder e.g. `(/Users/ak054561/)` through MacOS default extract utility or you may use relevant command line tools to extract.\
2) Rename the folder to `storm` from `storm.XX.XX.XX` \
3) Edit already existing file in `storm/conf/` folder `storm.yaml` and paste in the below configuration.
```
storm.zookeeper.servers:
- "localhost"
storm.local.dir: "/Users/ak054561/data/storm"
nimbus.host: "localhost"
supervisor.slots.ports:
- 6700
- 6701
- 6702
- 6703
```
4) Provide the data directory for storm which you created at start.
5) Open up a terminal, navigate to storm folder by
```
$ cd ~
$ cd storm
$ bin/storm nimbus &
```
This will start nimbus on the localhost.
```
$ bin/storm supervisor &
```
This will start supervisor on the localhost.
```
$ bin/storm ui &
```
This will start Storm UI on port `8080`. \
**Let the Terminal open and service up and running.**


Open up [**http://localhost:8080**](http://localhost:8080) in web browser to check if storm UI is up and running.\
<image src="https://i.ibb.co/23VpWHq/02-storm-ui.png" width="380" height="230">

**storm** (Unix executable) is used to deploy topology and start storm services.\
We may want to set the location of the storm executable in the `PATH` variables, so that it can be accessed from everywhere.

To do this edit the path file @ `/etc/paths`
```
$ sudo vi /etc/paths
```

<img src="https://i.ibb.co/KWpHZKx/03-cmd.png" width="400" height="100">

Add a line below for `storm/bin` full path as shown.

Now, to deploy storm topology, you can simply use
```
$ storm jar <jarname> <package.topology-classname> simple-topology-identifier
```

## How to install and run Kafka?
Apache Kafka also uses zookeeper server for synchronisation service.\
So we must be sure we have already installed and running zookeeper service before. \
If you have started the `confluent` Kafka will already be running and using the `zookeeper` which confluent starts.
Hence, we may want to skip this step as well.

#### Download and Extract
Download the latest binary distribution of [kafka](https://www.apache.org/dyn/closer.cgi?path=/kafka/)

e.g.[kafka_2.11-2.2.0.tg](http://mirrors.estointernet.in/apache/kafka/2.2.0/kafka_2.11-2.2.0.tgz)

1) Unzip it to your home folder e.g. `/Users/ak054561/` through MacOS default extract utility or you may use relevant command line tools to extract.
2) Rename the folder to `kafka` from `kafka.XX.XX.XX`
3) Edit already existing file in `kafka/conf/` folder `server.properties` and make sure below is existing in properties file. (If already existing, ignore.)
```
zookeeper.connect=localhost:2181
```
4) Edit `zookeeper.properties` file in `kafka/conf/` directory and set 
```
dataDir=/Users/ak054561/data/zookeeper
```

## Test Kafka Installation
1) Open up a new terminal, navigate to kafka folder with
```
$ cd ~
$ cd kafka
$ bin/kafka-server-start.sh -daemon config/server.properties
```

2) Open up a new terminal, navigate to kafka folder and create a `topic`
```
bin/kafka-topics.sh --create --zookeeper localhost:2181 --topic test-topic --partitions 2 --replication-factor 1
```
3) Produce a message. \
    Open up a new terminal, navigate to kafka folder and produce a message on topic
```
bin/kafka-console-producer.sh --broker-list localhost:9092 --topic test-topic
```
4) Consume a message. \
    Open up a new terminal, navigate to kafka folder and consume a message on topic from beginning

```
bin/kafka-console-consumer.sh --zookeeper localhost:2181 --topic test-topic --from-beginning
```
\
<image src="https://i.ibb.co/VDNCqgD/04-kafka-images.png" width="640" height="340">

If you were able to follow instruction till here, and you have a working zookeeper, storm and kafka running.\
You are good to go with storm-kafka onboarding project.

## Get Started with On-boarding Project.
Import the Project into IntelliJ.
Maven `dependency` has already been added, scope of the `pom.xml` is set to `compile`.
Perform code changes, submit the `JAR` to storm cluster.
Get all the required evidences.
	
 ![Demo](https://media.giphy.com/media/cjPuh1I5fHryhKzg1D/giphy.gif)
