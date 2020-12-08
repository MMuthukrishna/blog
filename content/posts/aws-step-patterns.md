+++
title = "AWS Step Patterns"
slug = "aws-step-patterns"
author = "M.Muthukrishna"
date = 2021-01-01T13:14:36+05:30
categories = ["aws"]
tags = ["aws", "step-functions"]
markup = "mmark"
katex = true
draft = false
+++

### Introduction

This article will talk about few of the most frequently used patterns in AWS Step. It assumes that you are familiar with AWS Step, if you want to learn about it, I suggest creating an AWS account and check out the example blueprint state machine definitions available or reading [this](https://states-language.net/)

### AWS Step Patterns

#### Chunked Iterator

Consider this problem

A CRM tool is used by sales team (Pipedrive) needs new data from Redshift (Data Warehouse) once a day, to do this you can use Pipedrive API's to Create or Update Deals.

To learn more about Pipdrive API's. Click [here](https://developers.pipedrive.com/docs/api/v1/).

The easiest way to solve this problem is to execute a query that generates the leads from Redshift and then invoking 100's of slave lambda functions which will actually hit the Pipedrive API's

![master_slave_asynchronous](/image/aws-step-patterns/master-slave-asynchronous.png)

Why is this done?

If the master lambda actually hits the endpoint after executing the query and generating the array of request data, it may timeout, as AWS Lambda has timeout of 900 seconds.

So instead we invoke, 100's of slave lambdas asynchronously, the number of slave lambdas invoked is dependent on the total size of the request body array, as there is a hard limit of the size of event body for an asynchronous invocation in AWS Lambda (256 KB). Each slave lambda will receive a chunk of records (say 20).

This solution works as long as Pipedrive has no rate limit on their API's.

The reason why this fails is because there is no synchronization between slave lambdas.
All slave lambdas execute at the same time, and the requests will exceed rate limit.

To temporarily deal with this issue, you can delay each asynchronous invocation by $$t$$ seconds, where $$t$$ is an arbitrary value which you can solve for from this equation

$$ T_e + T_p + m*t $$ = 900

where  
$$T_e$$ is the time to execute the query  
$$T_p$$ is the time to preprocess the query result  
$$m$$ is the number of slave lambdas invoked  
$$t$$ is delay introduced to temporarily mitigate the rate limit issue

I did this to mitigate the rate limit issue temporarily.

But around 5% of the requests were still exceeding rate limit (Response Status Code: 429)

Lesson Learned: It is difficult to solve this problem with AWS Lambda alone.

AWS Lambda is meant to run one specific task, and to orchestrate them and run long running jobs AWS Step can/should be used.

##### Chunked Iterator State Machine

![chunked_iterator_state_machine](/image/aws-step-patterns/chunked_iterator_state_machine.png)

```json
{
  "Comment": "Blueprint for Chunked Iterator Pattern",
  "StartAt": "master-query-executor",
  "States": {
    "master-query-executor": {
      "Type": "Pass",
      "Next": "slave-map"
    },
    "slave-executor-map": {
      "Type": "Map",
      "MaxConcurrency": 1,
      "Iterator": {
          "StartAt": "slave-executor",
          "States": {
            "slave-executor": {
                "Type": "Pass",
                "End": true
            }
          }
      },
      "End": true
    }
  }
}
```

master-query-executor will execute the query and generate the request body array, master-query executor will then chunk the records into $$m$$ arrays and then dump it in S3.

$$ len([R_1, R_2, R_3, .... R_n]) = n $$

$$ len([[R_1, R2, ... R_l], [R_{l+1}, ... , R_{2l}], [..., R_{n}]]) = m $$

where $$ l $$ is the size of each chunk, which is calculated by finding the maximum number of records the slave-executor can process before timeout (900 seconds).

Then an array of S3 Object paths of length $$ m $$ is passed to the map state, which will then pass one S3 object path (the path where the chunk is stored in S3) to the slave-executor.

The slave-executor can then read the file from S3 and then hit the endpoint either sequentially or concurrently which can be rate limited using libraries like [antifuchs/governor](https://github.com/antifuchs/governor).

This is the solution that's currently in production at Instamojo to move data from Redshift to Pipedrive.

#### Wait State Loop

Consider this problem

We need to execute a long running query and run a task after this query is executed, but lambda functions have a timeout of 900 seconds.

So how would we solve this using managed services from AWS.

AWS has introduced [RedshiftDataAPI](https://aws.amazon.com/blogs/big-data/using-the-amazon-redshift-data-api-to-interact-with-amazon-redshift-clusters/) which allows running the query asynchronously.

The RedshiftDataAPI client initiates query execution and returns a statement id which can be used to check for the status of the query execution at a later point in time.

##### Wait State Loop State Machine

![wait_state_loop_state_machine](/image/aws-step-patterns/wait_state_loop_state_machine.png)


```json
{
  "Comment": "Blueprint for Chunked Iterator Pattern",
  "StartAt": "query-execution-initiator",
  "States": {
    "query-execution-initiator": {
      "Type": "Pass",
      "Comment": "Lambda function which will initiate query execution asychronously and return statement id",
      "Next": "update-query-execution-status"
    },
    "update-query-execution-status": {
        "Type": "Pass",
        "Comment": "Lambda function which will update the status of the query execution in the state json object", 
        "Next": "query-execution-status-choice"
    },
    "query-execution-status-choice": {
        "Type": "Choice",
        "Comment": "Branching flow based on the status of query execution",
        "Choices": [{
            "Variable": "$.status",
            "StringEquals": "FINISHED",
            "Next": "fin"
        }, {
            "Variable": "$.status",
            "StringEquals": "PICKED",
            "Next": "wait-for-completion"
        }, {
            "Variable": "$.status",
            "StringEquals": "STARTED",
            "Next": "wait-for-completion"
        }, {
            "Variable": "$.status",
            "StringEquals": "SUBMITTED",
            "Next": "wait-for-completion"
        }, {
            "Variable": "$.status",
            "StringEquals": "FAILED",
            "Next": "fin"
        }]
    },
    "wait-for-completion": {
        "Type": "Wait",
        "Comment": "A wait state to wait for completion of unload query execution",
        "Seconds": 10,
        "Next": "update-query-execution-status"
    },
    "fin": {
        "Type": "Pass",
        "End": true
    }
  }
}
```

This will keep polling for the status of the query execution using statement id and then transition to fin pass state when either the query execution FINISHED or FAILED.
