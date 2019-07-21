package com.tutorial.nrtonboarding;

import org.apache.storm.topology.BasicOutputCollector;
import org.apache.storm.topology.OutputFieldsDeclarer;
import org.apache.storm.topology.base.BaseBasicBolt;
import org.apache.storm.tuple.Tuple;

public class CustomerNormalizerBolt extends BaseBasicBolt {

    private static final long serialVersionUID = 1L;

    public void execute(Tuple input, BasicOutputCollector collector) { ;
        //Tuple input contains stream of message coming from kafka topic, configured in KafkaStormTopology Class
        //input.getValue(0) provides updates from MySQL table as JSON format via kafka-topic
        //Use log4j or any similar loggers to log messages in the console.
        //hint:JSON serializer can be written in main() class.
        //eg. Robert is a star member, final purchase amount is $1872.
        //Also create classes to store the information to a flux table.
        //Write your Business logic here.

        System.out.println(input.getValue(0));
    }

    public void declareOutputFields(OutputFieldsDeclarer declarer) {}
}
