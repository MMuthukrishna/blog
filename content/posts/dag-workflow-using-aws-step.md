+++
title = "DAG Workflow Using AWS Step Functions and AWS Lambda"
slug = "dag-workflow-using-aws-step"
author = "M.Muthukrishna"
date = 2020-12-09T04:01:48+05:30
categories = ["aws"]
tags = ["aws", "step-functions"]
markup = "mmark"
katex = true
draft = false
+++

At Instamojo, we use Amazon Redshift as the data warehouse.

A typical requirement for analytics team is to aggregate new data
from multiple source tables (say raw events) that can later be used
in BI tools, dashboards, charts or other machine learning jobs.

For the sake of simplicity, let's assume these are the aggregate
operations performed

$$ f = MIN(x) $$  
$$ f = MAX(x) $$  
$$ f = COUNT(x) $$   
$$ f = SUM(x) $$

and that there are $$ N_{agg} $$ aggregate tasks which either append
or reload a table in aggregate_schema (example: `agg.table_one`).

These $$ N_{agg} $$ aggregate tasks have a hierarchy.

I will explain this with an example.

Consider Task $$ T_{i} $$ which updates `agg.table_i` by executing a SQL query, whose results are either appended to `agg.table_i` or truncated and appended to `agg.table_i` (reload).

Let the SQL query executed by Task $$ T_{i} $$ be

```sql
select
...
...
...
from agg.table_j
...
```

Here Task $$T_{i}$$ queries aggregate table `agg.table_j`.

The aggregate table `agg.table_j` will be updated by a Task $$T_{j}$$.  
So the task $$T_{j}$$ has to be executed before $$T_{i}$$.

This is a simple example, in reality there are aggregate tasks whose queries
depend of 12 other aggregate tables.

We can generate the task hierarchy by parsing the queries.

You can just run a simple script on each query  

```bash
grep -oP '(?<=agg.)\w+' {file} | tr -s ' ' | sort --unique
```

To get the list of tables and tasks that a given aggregate task (query executor) depends on

Running it on the above query, we get the output as

```bash
table_j
```

If we represent the task hierarchy using a Directed Acyclic Graph (DAG) then there will be a directed edge from Task $$T_{j}$$ to Task $$T_{i}$$.

$$T_{j}$$ ---> $$T_{i}$$

If we parse all $$N_{agg}$$ aggregate queries and plot the Directed Acyclic Graph using networkx and pyvis. It would look something like this

![original_dag](/image/dag-workflow-using-aws-step/original_dag.png)

I have replaced the task names with numbers as I'm not allowed to reveal the name of the tasks.

From the above directed acyclic graph, you can see that all nodes are connected to $$T_{27}$$, which is the end node $$fin:end$$. The reason for doing this will be revealed later.

### Transitive reduction

I will explain what transitive reduction of a Directed Acyclic Graph is, with an example

Consider the graph shown below

![example_dag_with_transitive_edges](/image/dag-workflow-using-aws-step/example_dag_with_transitive_edges.png)

Task $$T_4$$ depends on $$T_1$$, $$T_2$$ and $$T_6$$.  
The directed edge from $$T_1$$ to $$T_4$$ is redundant information.  
As we already have a directed edge from $$T_1$$ to $$T_2$$ and $$T_2$$ to $$T_4$$.  
It is implied that $$T_4$$ depends on $$T_1$$ and $$T_4$$ will be executed after $$T_1$$ even if we did not have that directed edge from $$T_1$$ to $$T_4$$.

To remove such edges, networkx has a method called nx.transitive_reduction
```python
REDUCED_G = nx.transitive_reduction(G)
```

Applying transitive reduction to the above simple example graph, we get

![example_dag_after_transitive_reduction](/image/dag-workflow-using-aws-step/example_dag_after_transitive_reduction.png)

The directed edge from $$T_1$$ to $$T_4$$ and $$T_1$$ to $$T_5$$ are removed after transitive reduction.

Applying transitive reduction on the original graph, we get

![original_dag_after_transitive_reduction](/image/dag-workflow-using-aws-step/original_dag_after_transitive_reduction.png)

At this point, you can either write a script that generates Apache Airflow code or do some more work to actually get it running in AWS Step.

If you observe the above graphs, they all seem to look like Multistage graphs, except they're not exactly Multistage graphs, as Mutistage graphs expects there to be edges only from one stage to the next stage.

There are edges here from stage 1 to stage 3, 4 ... N

After transitive reduction, only few nodes are connected to $$T_{27}$$, these are the tasks which populate the aggregate schema tables that isn't used by any other task. We could refer to them as unfruitful tasks.

Let's define few terminologies

### Level of a node

Level of a node is the length of the longest path from all root nodes to a specific node.

![level_graph_modified](/image/dag-workflow-using-aws-step/level_graph_modified.png)

$$ L_1 = {1} $$  
$$ L_2 = {2,3} $$  
$$ L_3 = {4} $$  
$$ L_4 = {5} $$  

We can further divide each level into groups based on the highest level of all child nodes of a given node

$$ N \in L_{ij} \implies N \in L_i \quad \land \quad min(k) = j \quad \forall M \in L_k , (N, M) \in E $$

I will explain this, with an example

![example_dag_after_transitive_reduction](/image/dag-workflow-using-aws-step/example_dag_after_transitive_reduction.png)

$$ L_{12} = {1} $$  
$$ L_{13} = {6} $$  
$$ L_{23} = {2} $$  
$$ L_{24} = {3} $$  
$$ L_{34} = {4} $$  
$$ L_{4E} = {5} $$  

In order to execute all such aggregate tasks, you can either do a simple level order traversal where tasks in each level can be executed using a Map state in AWS Step with desired MaxConcurrency.

### Simple Level Order

![simple_level_order](/image/dag-workflow-using-aws-step/simple_level_order.png)

The state machine definition shown above is using a pass state, which should be replaced by a Map state (which will execute all aggregate tasks in array $$L_{i}$$ with desired MaxConcurrency).

This is a simple level order traversal of the Directed Acyclic Graph

Or you could do this

### Parent Level Order

![divided_level_order](/image/dag-workflow-using-aws-step/divided_level_order.png)

In this approach we are doing a level order traversal of parent nodes of each level.

$$L_{12}$$ has all parents of $$L_{2}$$  
$$L_{13}$$ and $$L_{23}$$ has all parents of $$L_3$$  

$$L_{1E}$$ ... $$L_{5E}$$ are all unfruitful tasks.

Any of the above two approaches will obey the hierarchy defined by the Directed Acyclic Graph.

My intuition is that Parent Level Order traversal has higher parallelism.

It's left to you to choose any one of the techniques to execute the aggregate tasks defined in DAG.

The title says DAG Workflow Using AWS Step Functions and AWS Lambda
The aggregate tasks usually take longer than 900 seconds, so how would we execute it with AWS Lambda

You can use the newly introduced [Redshift Data API](https://aws.amazon.com/about-aws/whats-new/2020/09/announcing-data-api-for-amazon-redshift/) and a wait state loop.

![wait_state_loop](/image/dag-workflow-using-aws-step/wait_state_loop.png)

You can run UNLOAD asynchronously and transition to a wait state with predefined wait time in seconds (or you can go as far has having wait time defined in a config file for each aggregate task in S3 which is updated regularly at the end of the DAG workflow based on the actual time it took to run each aggregate task, that seems overkill, but possible, for now we will stick to constant wait time defined in a config file) and then check for the status of UNLOAD query execution.

Similarly, we execute COPY asynchronously to load data from S3 into agg schema tables.

The actual State Machine Defintion looks something like this

![actual_state_machine](/image/dag-workflow-using-aws-step/actual_state_machine.png)

where the Pass State is replaced with an Aggregate Task Map State.

### Sidenote

![sidenote](/image/dag-workflow-using-aws-step/side_note_image.png)

### Reasons for using AWS Step

- I completed this project before Managed Airflow was launched by AWS in reInvent 2020.
- AWS Step has a simple regulator, MaxConcurrency, which can set so as to ensure the total number of connections used is within the connection limit of Redshift (you can write a simple script to calculate the max number of connections used in parent level order traversal, it's not that hard).
