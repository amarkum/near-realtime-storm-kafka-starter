package com.cerner.nrtonboarding;

import org.apache.storm.Config;
import org.apache.storm.LocalCluster;
import org.apache.storm.kafka.*;
import org.apache.storm.spout.SchemeAsMultiScheme;
import org.apache.storm.topology.TopologyBuilder;

import java.util.HashMap;
import java.util.UUID;

public class KafkaStormTopology {

    public static void main(String[] args) {

        Config stormConfig = new Config();
        stormConfig.setDebug(true);
        stormConfig.put(Config.TOPOLOGY_MAX_SPOUT_PENDING, 1);
        String zkConnString = "localhost:2181";
        String topic = "kafkatopic-customer";
        BrokerHosts hosts = new ZkHosts(zkConnString);

        SpoutConfig kafkaSpoutConfig = new SpoutConfig(hosts, topic, "/" + topic,
                UUID.randomUUID().toString());

        kafkaSpoutConfig.scheme = new SchemeAsMultiScheme(new StringScheme());

        final TopologyBuilder topologyBuilder = new TopologyBuilder();

        topologyBuilder.setSpout("kafka-spout", new KafkaSpout(kafkaSpoutConfig), 1);
        topologyBuilder.setBolt("customer-normalizer-bolt", new CustomerNormalizerBolt()).shuffleGrouping("kafka-spout");

        // Submit topology to Local Cluster
        //Remove the below code when submitting topology to real storm cluster set up on your machine.
        final LocalCluster localCluster = new LocalCluster();
        localCluster.submitTopology("kafka-storm-topology", new HashMap < Object, Object > (), topologyBuilder.createTopology());
    }
}
